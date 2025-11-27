import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D  # needed for 3D projection (even if unused directly)


def state_to_bloch(alpha: complex, beta: complex):
    """
    Convert a 1-qubit pure state |ψ> = α|0> + β|1> into a Bloch vector (x, y, z).

    x = 2 Re(α* β)
    y = 2 Im(α* β)
    z = |α|^2 - |β|^2
    """
    # Normalize just in case
    norm = np.sqrt(np.abs(alpha) ** 2 + np.abs(beta) ** 2)
    alpha = alpha / norm
    beta = beta / norm

    x = 2 * np.real(np.conj(alpha) * beta)
    y = 2 * np.imag(np.conj(alpha) * beta)
    z = np.abs(alpha) ** 2 - np.abs(beta) ** 2
    return float(x), float(y), float(z)


def create_bloch_animation():
    # Set up 3D figure
    fig = plt.figure()
    ax = fig.add_subplot(111, projection="3d")

    # Draw a sphere (the Bloch sphere surface)
    u = np.linspace(0, np.pi, 50)
    v = np.linspace(0, 2 * np.pi, 50)
    xs = np.outer(np.sin(u), np.cos(v))
    ys = np.outer(np.sin(u), np.sin(v))
    zs = np.outer(np.cos(u), np.ones_like(v))

    ax.plot_surface(xs, ys, zs, alpha=0.1, linewidth=0)

    # Axes labels
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_zlabel("Z")
    ax.set_title("Bloch Sphere: Arrow Moving Under R_y(θ)")

    # Fix aspect ratio to make it look like a sphere
    max_range = 1.0
    for axis in "xyz":
        getattr(ax, f"set_{axis}lim")([-max_range, max_range])

    # Initial arrow: start at |0> => Bloch vector (0, 0, 1)
    arrow_line, = ax.plot([0, 0], [0, 0], [0, 1], linewidth=3)

    # Number of frames in the animation
    n_frames = 60

    def update(frame):
        # θ goes from 0 to π/2 (rotate around Y axis)
        theta = (frame / (n_frames - 1)) * (np.pi / 2)

        # R_y(θ) applied to |0> gives:
        # |ψ(θ)> = cos(θ/2)|0> + sin(θ/2)|1>
        alpha = np.cos(theta / 2)
        beta = np.sin(theta / 2)

        x, y, z = state_to_bloch(alpha, beta)

        # Update arrow from origin to (x, y, z)
        arrow_line.set_data([0, x], [0, y])
        arrow_line.set_3d_properties([0, z])

        # Optional: update title to show θ
        ax.set_title(f"Bloch Sphere: R_y(θ) |0>,  θ = {theta:.2f} rad")

        return arrow_line,

    anim = FuncAnimation(fig, update, frames=n_frames, interval=100, blit=False)

    plt.show()

    # If you want to save as GIF later:
    # anim.save("bloch_animation.gif", writer="pillow")


if __name__ == "__main__":
    create_bloch_animation()