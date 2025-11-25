# Offline AI CLI — Setup & Installation Guide (macOS + Windows)

This guide contains all commands needed to set up and run the Offline AI CLI. Fully offline and fully local.

---

## macOS Setup

### Optional: Run the macOS setup script
chmod +x setup_ollama_mac.sh
./setup_ollama_mac.sh

### Manual Install (if not using the script)
# Download Ollama manually:
# https://ollama.com/download

open /Applications/Ollama.app
curl http://localhost:11434/api/tags
ollama pull llama3

### Create the virtual environment
cd 2-offline-ai-cli
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

### Run the Offline AI CLI
python main.py

---

## Windows Setup

### Optional: Run the Windows setup script
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup_ollama_windows.ps1

### Manual Install (if not using the script)
# Download Ollama:
# https://ollama.com/download

curl http://localhost:11434/api/tags
ollama pull llama3

### Create the virtual environment
cd 2-offline-ai-cli
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt

### Run the Offline AI CLI
python main.py

---

## Quick Summary

### macOS
open /Applications/Ollama.app
ollama pull llama3
cd 2-offline-ai-cli
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py

### Windows
curl http://localhost:11434/api/tags
ollama pull llama3
cd 2-offline-ai-cli
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
python main.py

---

## Note
The CLI communicates only with:
http://localhost:11434
This is a fully offline local server provided by Ollama. No cloud requests are made.