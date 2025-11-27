import os
import time
import random
import math

# ANSI colours
BLUE = "\033[34m"
RED = "\033[31m"
MAGENTA = "\033[35m"
DIM = "\033[2m"
RESET = "\033[0m"

CURSOR_HOME = "\033[H"     # move cursor to top-left
CLEAR_SCREEN = "\033[2J"   # clear whole screen once


def project_point(x: float, z: float, width: int, height: int):
    """
    Simple 'fake 3D' projection onto an ASCII grid (x–z slice of Bloch sphere).
    x in [-1, 1] -> horizontal
    z in [-1, 1] -> vertical (up/down => |0>/|1>)
    """
    cx = width // 2
    cy = height // 2

    sx = int(round(cx + x * (width // 3)))
    sy = int(round(cy - z * (height // 3)))  # z up -> smaller row index
    return sx, sy


def draw_line(x0, y0, x1, y1, grid, char):
    """
    Bresenham-style line drawing on the ASCII grid.
    Draws from (x0, y0) to (x1, y1) using 'char'.
    """
    dx = abs(x1 - x0)
    dy = -abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx + dy
    x, y = x0, y0

    while True:
        if 0 <= x < len(grid[0]) and 0 <= y < len(grid):
            grid[y][x] = char
        if x == x1 and y == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x += sx
        if e2 <= dx:
            err += dx
            y += sy


def run_bloch_ascii_sphere(prob_one: float = 0.5, frames: int = 250, delay: float = 0.05):
    """
    ASCII Bloch sphere cross-section with flicking and stabilising arrows.

    - Blue arrow: current measurement (|0> => arrow to top, |1> => arrow to bottom)
    - Red arrow: running average of Z (stabilises over time)

    Everything is redrawn in a single "scene" like a terminal window.
    """
    width = 61   # columns
    height = 29  # rows

    count_zero = 0
    count_one = 0
    total = 0

    # Precompute sphere outline in x–z plane
    sphere_points = []
    for angle in [i * 2 * math.pi / 360 for i in range(360)]:
        x = math.cos(angle)
        z = math.sin(angle)
        sx, sy = project_point(x, z, width, height)
        sphere_points.append((sx, sy))

    # Clear screen once up-front
    print(CLEAR_SCREEN, end="")

    for step in range(frames):
        # --- 1) Simulate one measurement ---
        outcome = 1 if random.random() < prob_one else 0
        total += 1
        if outcome == 1:
            count_one += 1
        else:
            count_zero += 1

        # Map outcomes to Bloch Z expectation: 0 -> +1, 1 -> -1
        z_current = 1.0 if outcome == 0 else -1.0
        z_avg = (count_zero * 1.0 + count_one * -1.0) / total

        # --- 2) Build empty screen for this frame ---
        screen = [[" " for _ in range(width)] for _ in range(height)]

        # Draw sphere outline (faint 'o')
        for sx, sy in sphere_points:
            if 0 <= sx < width and 0 <= sy < height:
                if screen[sy][sx] == " ":
                    screen[sy][sx] = DIM + "o" + RESET

        # Sphere centre in grid coords
        cx, cy = project_point(0.0, 0.0, width, height)

        # --- 3) Compute arrow tip positions in x–z plane ---
        x_tip = 0.0

        # Current reading arrow (blue) – pure |0> or |1>
        z_tip_current = z_current
        sx_c, sy_c = project_point(x_tip, z_tip_current, width, height)

        # Average arrow (red) – somewhere between +1 and -1
        z_tip_avg = max(-1.0, min(1.0, z_avg))
        sx_a, sy_a = project_point(x_tip, z_tip_avg, width, height)

        # --- 4) Draw average arrow as red line ---
        draw_line(cx, cy, sx_a, sy_a, screen, RED + "|" + RESET)

        # --- 5) Draw current arrow as blue line ---
        draw_line(cx, cy, sx_c, sy_c, screen, BLUE + "|" + RESET)

        # Overwrite tips with markers
        if 0 <= sx_a < width and 0 <= sy_a < height:
            screen[sy_a][sx_a] = RED + "+" + RESET
        if 0 <= sx_c < width and 0 <= sy_c < height:
            if sx_c == sx_a and sy_c == sy_a:
                screen[sy_c][sx_c] = MAGENTA + "*" + RESET
            else:
                screen[sy_c][sx_c] = BLUE + "*" + RESET

        # --- 6) Compose text output ---
        lines = []
        lines.append(" ASCII Bloch sphere cross-section (x–z plane)")
        lines.append("   top of sphere ≈ |0> (z=+1), bottom ≈ |1> (z=-1)")
        lines.append("   blue '|' & * = current measurement arrow (flicking)")
        lines.append("   red  '|' & + = running average arrow (stabilising)")
        lines.append("")

        for row in screen:
            lines.append("  " + "".join(row))

        p0 = count_zero / total
        p1 = count_one / total

        lines.append("")
        lines.append(f" step {step + 1}/{frames}")
        lines.append(f" last outcome: {outcome}  (0 => |0>, 1 => |1>)")
        lines.append(f" counts: 0 -> {count_zero}, 1 -> {count_one}, total -> {total}")
        lines.append(f" estimated P(0) ≈ {p0:.3f}, P(1) ≈ {p1:.3f}")
        lines.append(f" current z: {z_current:+.3f}, running <Z>: {z_avg:+.3f}")

        # Move cursor to top-left and redraw whole scene in-place
        print(CURSOR_HOME + "\n".join(lines), end="", flush=True)

        time.sleep(delay)


if __name__ == "__main__":
    # 50/50 like measuring |+> in the Z basis
    run_bloch_ascii_sphere(prob_one=0.5, frames=250, delay=0.05)