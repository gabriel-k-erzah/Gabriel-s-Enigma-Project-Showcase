# Quantum ASCII Bloch Sphere Visualiser
A lot of people talk about qubits, but they don’t understand them.
So I built a live terminal visualiser that shows quantum measurement
in real-time, the Bloch sphere, the flicker of collapse,
and the stabilising expectation value, all animated in ASCII,
all from scratch.

This project documents my journey building a **real-time terminal-based Bloch sphere visualiser** in Python. The goal:

**Visualise how a qubit collapses when measured, animated live in a terminal using ASCII.**

Most quantum visualisations rely on static plots or heavy libraries. I wanted something different:

### ❇️ A dynamic ASCII representation of a qubit inside a Bloch sphere.

This project is still in progress (this README will grow with it).

---

## 🎯 Project Description

The simulator repeatedly measures a qubit in the Z-basis:

- **Outcome 0** → arrow points **up** (|0⟩)
- **Outcome 1** → arrow points **down** (|1⟩)

The visualiser displays:

### 🔵 Blue Arrow —> *Current Measurement*
Flicks instantly up or down, showing collapse.

### 🔴 Red Arrow —> *Running Average*
Moves gradually, stabilising over time according to the probability distribution.

### 🟢 ASCII Sphere Outline
A resizable ASCII "Bloch sphere" cross-section is rendered each frame, with arrows drawn inside.

The entire scene refreshes **in-place**, without scrolling. (sensitive for now but this will improve over time)

---

## 🧠 Why I Built This

I wanted to gain intuition for qubit behaviour, especially measurement collapse, but without diving straight into advanced maths.

The question was:

> "Can I show quantum "ghost-path" collapse in real time using only ASCII?"

This project helped me build intuition around:

- Bloch vectors  
- Measurement collapse  
- Expectation values  
- Real-time rendering  
- Terminal control sequences  

This is an honest learning project. I used AI prompting heavily due to time constraints, but this 
project can only be considered as a wireframe for now as I plan to 
implement this in C++, as I had seen a previous repo 
where a similar 3D rendering was achieved to a much higher 
standard.:

- I understood the architecture  
- I adjusted the logic myself  
- I shaped the behaviour frame-by-frame  
- I iterated the design intentionally  


The README will expand as the project evolves.

---

## 🧪 How to Run the Visualiser

```bash
python3 experiments/bloch_flicker_ascii.py