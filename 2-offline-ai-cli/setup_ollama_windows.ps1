<#
    setup_ollama_windows.ps1

    NOTE — PLEASE READ
    If you prefer not to run scripts on your machine:
    No problem at all. You can install Ollama manually instead:
      1. Go to https://ollama.com/download
      2. Download the Windows installer
      3. Run it normally
      4. Then open a NEW PowerShell window and run:
             ollama pull llama3

    Once the model is installed locally, the CLI works exactly the same.
    This script is just here to make life easier, it's fully optional.

    Development note:
    I used a venv during development but also tested everything on clean machines.
#>

$ErrorActionPreference = "Stop"

Write-Host "== Setting up Ollama on Windows =="

# Simple setup script for Windows.
# Downloads the official Ollama installer if needed,
# starts the local server, and checks whether the 'ollama' command is available.

# [1/6] Check if Ollama is already installed
Write-Host "[1/6] Checking for existing Ollama installation..."
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

if ($ollamaCmd) {
    Write-Host "Ollama already installed at: $($ollamaCmd.Source)"
} else {
    Write-Host "[2/6] Ollama not found. Downloading the official installer..."

    $installerUrl = "https://ollama.com/download/OllamaSetup.exe"
    $installerPath = Join-Path $env:TEMP "OllamaSetup.exe"

    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

    Write-Host "[3/6] Running the Ollama installer..."
    Start-Process -FilePath $installerPath -Wait

    Write-Host "Installer finished."
    Write-Host "You may need to restart PowerShell so the 'ollama' command is available."
}

# Refresh PATH for this session in case it was just installed
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "[4/6] Checking if the 'ollama' command is available in this session..."

$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

if (-not $ollamaCmd) {
    Write-Host ""
    Write-Host "[WARNING] The 'ollama' command is not available in this PowerShell session yet."
    Write-Host "This is normal right after installation."
    Write-Host ""
    Write-Host "-> Please OPEN A NEW POWERSHELL window and run:"
    Write-Host "       ollama pull llama3"
    Write-Host ""
    Write-Host "Once the model is pulled, your Offline AI CLI is ready to use."
    exit 0
}

Write-Host "[5/6] Checking if the local Ollama server is responding..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 5
    Write-Host "Ollama server is running locally. Perfect."
} catch {
    Write-Host "Hmm... can't reach the Ollama server yet."
    Write-Host "It might still be starting. Try launching it manually from the Start Menu (search for 'Ollama')"
    Write-Host "Then try again with:"
    Write-Host "    curl http://localhost:11434/api/tags"
}

Write-Host "[6/6] Attempting to pull the 'llama3' model so the offline AI is ready to go..."

try {
    ollama pull llama3
    Write-Host ""
    Write-Host "All done! You can test with:"
    Write-Host "    ollama run llama3"
    Write-Host ""
    Write-Host "You're ready to use the Offline AI CLI."
} catch {
    Write-Host ""
    Write-Host "[WARNING] The model pull did not complete."
    Write-Host "You can try manually with:"
    Write-Host "    ollama pull llama3"
    Write-Host ""
    Write-Host "Once the model is pulled, you're ready to use the Offline AI CLI."
}