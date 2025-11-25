#!/usr/bin/env bash

# NOTE — PLEASE READ
# If you prefer not to run scripts on your machine:
# No problem at all. You can install Ollama manually instead:
#   1. Go to https://ollama.com/download
#   2. Download the installer for your OS
#   3. Open it normally
#   4. Then run:
#        ollama pull llama3
# Once the model is installed locally, the CLI works exactly the same.
# These setup scripts just make life easier, they are fully optional.

# Development note:
# I used a venv during development but tested everything on clean machines too.

# setup_ollama_mac.sh
# Simple setup script for macOS.
# Installs Ollama WITHOUT Homebrew, starts the local server,
# and then checks whether the 'ollama' command is available.

set -e

echo "== Setting up Ollama on macOS =="

# Download the official Ollama installer archive
echo "[1/6] Downloading Ollama..."
curl -L https://ollama.com/download/Ollama-darwin.zip -o ollama.zip

echo "[2/6] Unzipping..."
unzip -q ollama.zip

# Move the app if it exists
if [ -d "Ollama.app" ]; then
  echo "[3/6] Moving Ollama.app to /Applications (may ask for password)..."
  mv Ollama.app /Applications/ || {
    echo "Couldn't move the app automatically. Please move it manually.";
    exit 1;
  }
else
  echo "Couldn't find Ollama.app after unzipping. Something went wrong."
  exit 1
fi

# Open the app to start the local server
echo "[4/6] Launching Ollama..."
open /Applications/Ollama.app
sleep 5  # give the server a moment to start up

# Check the local Ollama server
echo "[5/6] Checking if the local Ollama server is responding..."
if curl -s http://localhost:11434/api/tags > /dev/null; then
  echo "Ollama server is running locally. Perfect."
else
  echo "Hmm... can't reach the Ollama server yet."
  echo "It might still be starting. Try again with:"
  echo "    curl http://localhost:11434/api/tags"
fi

echo "[6/6] Checking if the 'ollama' command is available..."

if ! command -v ollama >/dev/null 2>&1; then
  echo ""
  echo "[WARNING] The 'ollama' command is not available in this terminal session yet."
  echo "This is normal right after installation."
  echo ""
  echo "-> Please OPEN A NEW TERMINAL window and run:"
  echo "       ollama pull llama3"
  echo ""
  echo "Once the model is pulled, your Offline AI CLI is ready to use."
  exit 0
fi

echo "Pulling the 'llama3' model so the offline AI is ready to go..."
ollama pull llama3 || {
  echo ""
  echo "[WARNING] The model pull did not complete."
  echo "You can try manually with:"
  echo "    ollama pull llama3"
  exit 0
}

echo ""
echo "All done! You can test with:"
echo "    ollama run llama3"
echo ""
echo "You're ready to use the Offline AI CLI."