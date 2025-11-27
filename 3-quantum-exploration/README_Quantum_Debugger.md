# Quantum Debugger — Concept & Vision

This document outlines the vision, design goals, and long-term direction for the **Quantum Debugger** project — an ASCII-based, real-time, interactive quantum program visualiser.

This is not just a side project. It is intended to become a **full debugging environment** for quantum circuits, built from scratch with intuition, clarity, and education in mind.

The Quantum Debugger is a sister project to the ASCII Bloch Sphere visualiser.

Disclaimer, I am NOT a mathematician, however I do understand how to "read maths from code" I am planing to improve my maths however that will take time.

---

## 🎯 Goal of the Quantum Debugger

To build a **real-time, terminal-based quantum debugging tool** that allows you to:

- Step through quantum circuits  
- Visualise gate effects on qubit states  
- Watch superposition evolve  
- See Bloch vectors update live  
- Observe measurement collapse  
- Understand expectation values  
- Monitor entanglement  
- Replay or inspect state histories  

The debugger acts like a visual REPL for quantum programs.

---

## 🧩 Why This Matters

Quantum programming is notoriously abstract. Even experienced developers struggle to *see* what a qubit is doing.

Most tools show either:
- pure math, or  
- static graphs  

The Quantum Debugger instead provides:

### **Immediate visual intuition**
A live ASCII rendering of the Bloch sphere and state evolution.

### **Interactive exploration**
Step through gates. Inspect internal qubit states.

### **No heavy dependencies**
Runs in any terminal. No GUI frameworks required.

### **Ultra-accessible education**
Perfect for beginners to see quantum behaviour come alive.

This tool bridges the gap between theory and intuition.

---

## 🖥️ Core Features (Planned)

### 🔹 1. ASCII Bloch Sphere View
- Live arrows representing qubit state  
- Flickering collapse arrow (blue)  
- Stabilising expectation arrow (red)  
- Supports Z, X, and Y basis views  

### 🔹 2. Gate-By-Gate Stepping
Visualise what each gate does:
- H: superposition  
- X: bit flip  
- Z: phase flip  
- RX/RY/RZ: rotations  
- CNOT/CZ: entanglement creation  

### 🔹 3. Quantum Measurement Inspector
- Collapse events shown visually  
- Running probability estimates  
- Measurement logs  

### 🔹 4. Circuit Viewer
ASCII circuit diagram:
q0 ─ H ─ RY(pi/3) ─ X ─ M
Updates as you step.

### 🔹 5. Entanglement Map
Simple indicators:
Entanglement:
q0 <–> q1   (0.98)
Or a small ASCII graph.

### 🔹 6. Multi-View Panel Layout
Terminal window split into:
Bloch Sphere     Probability Panel
Circuit View     Measurement History

Updated every frame.

### 🔹 7. Real Backend Integration
- Qiskit Statevector Simulator  
- Qiskit QASM Simulator  
- Optional: other simulators  

---

## 🏗️ Architecture Overview (Initial Draft)

### 1. **Core Engine**
Handles:
- Qubit amplitudes  
- Gate transformations  
- Rotations  
- Collapse  
- State history  

### 2. **ASCII Renderer**
Responsible for:
- Drawing Bloch spheres  
- Multi-panel layout  
- Arrow projection  
- Terminal cursor movement  
- Redrawing in-place  

### 3. **Circuit Executor**
Provides:
- `step`  
- `continue`  
- `reset`  
- `inspect`  
- `run_to_measure`  

### 4. **Backend Connector** (planned)
- Connects Python qubit classes to Qiskit  
- Validates behaviour with real simulators  

### 5. **UI Loop**
- Fixed FPS redraw  
- Keypress handling  
- State transition animations  

---

## 🚀 Why This Project Is Unique

- No one else has a **terminal-based quantum debugger**.  
- It combines low-level rendering with high-level physics.  
- It is educational, intuitive, and original.  
- Perfect for students, researchers, and newcomers.  
- A killer portfolio piece.  

This project isn’t just code — it’s a new kind of quantum teaching tool.

---

## 📘 Future Directions

- Multi-qubit Bloch spheres  
- Quantum state timeline viewer  
- ASCII phase-disk visualisation  
- Density matrix debugger  
- Noise model simulation  
- Plugin system for custom gates  

---

## 📌 Notes

This is a living README. Features will be added as the debugger is designed and implemented.

If you're reading this in the future: this was the blueprint.

More details, modules, and demos will be added soon.
