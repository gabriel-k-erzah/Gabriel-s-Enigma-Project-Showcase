import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 (needed for 3D projection)


def create_bloch_flicker_animation(
    prob_one: float = 0.5,
    n_frames: int = 100,
    shots_per_frame: int = 1,
):
    """
    Animate a Bloch-sphere-style arrow flicking between |0> (up) and |1> (down)
    based on simulated measurement results.

    - Blue arrow: current measurement result (instant collapse).
    - Red arrow: running average (stabilises over time).

    prob_one:      P(measurement result = 1)
    n_frames:      number of animation frames (time steps)
    shots_per_frame: how many measurements to simulate per frame
                     (kept small so you can "see" the flickering)
    """
    # Set up 3D figure
    fig = plt.figure()
    ax = fig.add_subplot(111, projection="3d")

    # Draw sphere surface (Bloch sphere)
    u = np.linspace(0, np.pi, 50)
    v = np.linspace(0, 2 * np.pi, 50)
    xs = np.outer(np.sin(u), np.cos(v))
    ys = np.outer(np.sin(u), np.sin(v))
    zs = np.outer(np.cos(u), np.ones_like(v))

    ax.plot_surface(xs, ys, zs, alpha=0.08, linewidth=0)

    # Label axes
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_zlabel("Z")

    # Make it look like a sphere
    max_range = 1.0
    for axis in ("x", "y", "z"):
        getattr(ax, f"set_{axis}lim")([-max_range, max_range])

    # Blue arrow: current measurement result (flicks)
    blue_arrow, = ax.plot(
        [0, 0],
        [0, 0],
        [0, 1],
        linewidth=3,
        color="blue",
        label="Current measurement",
    )

    # Red arrow: running average (stabilises)
    red_arrow, = ax.plot(
        [0, 0],
        [0, 0],
        [0, 1],
        linewidth=3,
        color="red",
        label="Running average",
    )

    # Legend
    ax.legend(loc="upper right")

    # Keep running counts
    count_zero = 0
    count_one = 0
    total_shots = 0

    # We'll store these in a dict so the closure can modify them
    stats = {
        "count_zero": count_zero,
        "count_one": count_one,
        "total_shots": total_shots,
    }

    def update(frame):
        # Simulate some measurements this frame
        for _ in range(shots_per_frame):
            outcome = 1 if np.random.rand() < prob_one else 0
            stats["total_shots"] += 1
            if outcome == 1:
                stats["count_one"] += 1
            else:
                stats["count_zero"] += 1

        # Blue arrow: last outcome
        last_outcome = 1 if stats["count_one"] + stats["count_zero"] > 0 and outcome == 1 else 0
        # For |0> we use z = +1, for |1> z = -1
        z_current = 1.0 if last_outcome == 0 else -1.0

        blue_arrow.set_data([0, 0], [0, 0])
        blue_arrow.set_3d_properties([0, z_current])

        # Red arrow: running average (expectation of Z)
        # Map outcome to z: 0 -> +1, 1 -> -1
        if stats["total_shots"] > 0:
            z_avg = (
                stats["count_zero"] * 1.0 + stats["count_one"] * (-1.0)
            ) / stats["total_shots"]
        else:
            z_avg = 1.0

        red_arrow.set_data([0, 0], [0, 0])
        red_arrow.set_3d_properties([0, z_avg])

        # Update title with stats
        p_est_zero = stats["count_zero"] / stats["total_shots"]
        p_est_one = stats["count_one"] / stats["total_shots"]
        ax.set_title(
            f"Flicking measurements on Z\n"
            f"shots = {stats['total_shots']}, "
            f"P_est(0) = {p_est_zero:.2f}, P_est(1) = {p_est_one:.2f}"
        )

        return blue_arrow, red_arrow

    anim = FuncAnimation(fig, update, frames=n_frames, interval=150, blit=False)

    plt.show()

    # If you ever want to save it as a GIF:
    # anim.save('bloch_flicker.gif', writer='pillow', fps=10)


if __name__ == "__main__":
    # Try a fair 50/50 qubit first (like |+> measured in Z)
    create_bloch_flicker_animation(prob_one=0.5, n_frames=120, shots_per_frame=1)