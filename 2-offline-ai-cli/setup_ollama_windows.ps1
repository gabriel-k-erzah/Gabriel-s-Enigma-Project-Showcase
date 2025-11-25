<#
    setup_ollama_windows.ps1

    NOTE — PLEASE READ
    If you prefer not to run scripts on your machine:
    No problem at all. You can install Ollama manually instead:
      1. Go to https://ollama.com/download
      2. Install it normally
      3. Open a NEW PowerShell window and run:
             ollama pull llama3

    The setup scripts are optional helpers. Everything is fully offline.

    Development note:
    Tested on clean Windows installs.
#>

$ErrorActionPreference = "Stop"

Write-Host "== Setting up Ollama on Windows =="

# [1/7] Check if Ollama is already installed
Write-Host "[1/7] Checking for existing Ollama installation..."
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

if ($ollamaCmd) {
    Write-Host "Ollama already installed at: $($ollamaCmd.Source)"
} else {
    Write-Host "[2/7] Ollama not found. Downloading the official installer..."

    $installerUrl = "https://ollama.com/download/OllamaSetup.exe"
    $installerPath = Join-Path $env:TEMP "OllamaSetup.exe"

    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

    Write-Host "[3/7] Running the Ollama installer..."
    Start-Process -FilePath $installerPath -Wait

    Write-Host "Installer finished."
    Write-Host "You may need to restart PowerShell so the 'ollama' command is available."
}

# Refresh PATH
$env:PATH = [Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
            [Environment]::GetEnvironmentVariable("PATH","User")

# Re-check
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

if (-not $ollamaCmd) {
    Write-Host ""
    Write-Host "[WARNING] The 'ollama' command is not available yet."
    Write-Host "Open a NEW PowerShell window and run:"
    Write-Host "       ollama pull llama3"
    exit 0
}

# [4/7] Ensure the Ollama server/service is running
Write-Host "[4/7] Checking if the Ollama server is running..."

try {
    $svc = Get-Service ollama -ErrorAction Stop
    if ($svc.Status -ne "Running") {
        Write-Host "Ollama service is stopped. Starting it..."
        Start-Service ollama
        Start-Sleep -Seconds 3
    }
}
catch {
    Write-Host "Ollama service not found or can't be controlled. Trying direct server launch..."
    Write-Host "Launching server with: ollama.exe serve"
    Start-Process -FilePath "C:\Program Files\Ollama\ollama.exe" -ArgumentList "serve"
    Start-Sleep -Seconds 5
}

# [5/7] Check server readiness (prevents 'Writing web request...' hang)
Write-Host "[5/7] Checking Ollama local API..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 5
    Write-Host "Ollama server is running locally. Perfect."
} catch {
    Write-Host ""
    Write-Host "[WARNING] Ollama server did not respond."
    Write-Host "Try launching it manually:"
    Write-Host '   & "C:\Program Files\Ollama\ollama.exe" serve'
    Write-Host ""
    exit 0
}

# [6/7] Pull the llama3 model
Write-Host "[6/7] Pulling the 'llama3' model..."

try {
    ollama pull llama3
    Write-Host "Model pull complete."
}
catch {
    Write-Host ""
    Write-Host "[WARNING] Could not pull 'llama3'. Try manually:"
    Write-Host "    ollama pull llama3"
    exit 0
}

# [7/7] Done
Write-Host ""
Write-Host "All done! Test with:"
Write-Host "    ollama run llama3"
Write-Host ""
Write-Host "You're ready to use the Offline AI CLI."