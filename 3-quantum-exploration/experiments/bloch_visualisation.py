# experiments/bloch_visualisation.py

from qiskit import QuantumCircuit
from qiskit.quantum_info import Statevector
from qiskit.visualization import plot_bloch_multivector, plot_histogram
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def sample_counts_from_state(qc: QuantumCircuit, shots: int = 1024):
    """
    Simulate measurement results from a circuit *without* needing Aer.
    Uses Statevector (pure Python) to get probabilities, then samples with numpy.
    """
    # Get the statevector for the circuit
    sv = Statevector.from_instruction(qc)
    probs = np.abs(sv.data) ** 2

    # All possible bitstrings for n qubits
    n = qc.num_qubits
    outcomes = [format(i, f"0{n}b") for i in range(2 ** n)]

    samples = np.random.choice(outcomes, size=shots, p=probs)
    counts = Counter(samples)

    # plot_histogram expects a normal dict
    return dict(counts)


def bloch_for_superposition():
    # 1 qubit, no classical bits (we don't need to measure yet)
    qc = QuantumCircuit(1)

    # Put the qubit into a ghost-path superposition
    qc.h(0)

    print("Circuit (no measurement):")
    print(qc.draw())

    # --- Bloch sphere from the statevector ---
    state = Statevector.from_instruction(qc)
    plot_bloch_multivector(state)
    plt.title("Bloch sphere: |+> state (superposition of |0> and |1>)")
    plt.show()

    # --- Measurement histogram ---
    # Same circuit (still just H), but we'll *simulate* measurement:
    counts = sample_counts_from_state(qc, shots=1024)

    print("Simulated measurement counts:", counts)
    plot_histogram(counts)
    plt.title("Measurement probabilities for |+> state")
    plt.show()


if __name__ == "__main__":
    bloch_for_superposition()