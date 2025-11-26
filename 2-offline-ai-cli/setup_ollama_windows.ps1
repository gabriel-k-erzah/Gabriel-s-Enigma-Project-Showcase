<#
    setup_ollama_windows.ps1

    NOTE — PLEASE READ
    If you prefer not to run scripts on your machine:
    No problem at all. You can install Ollama manually instead:
      1. Go to https://ollama.com/download
      2. Install it normally
      3. Open a NEW PowerShell window and run:
             ollama pull llama3

    These setup scripts are optional helpers.
    Everything stays fully offline once installed.

    Development note:
    Tested on clean Windows installs.
#>

$ErrorActionPreference = "Stop"

Write-Host "== Setting up Ollama on Windows =="

# [1/7] Check if the Ollama CLI exists
Write-Host "[1/7] Checking for 'ollama' command..."
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

# -----------------------------
# If Ollama is NOT installed:
# Try downloading it safely
# -----------------------------
if (-not $ollamaCmd) {

    Write-Host "[2/7] Ollama not found. Attempting to download installer..."

    $installerUrl = "https://ollama.com/download/OllamaSetup.exe"
    $installerPath = Join-Path $env:TEMP "OllamaSetup.exe"

    try {
        # Prefer curl.exe for reliability
        $curlCmd = Get-Command curl.exe -ErrorAction SilentlyContinue

        if ($curlCmd) {
            Write-Host "Using curl.exe to download Ollama..."
            & curl.exe -L $installerUrl -o $installerPath
        } else {
            Write-Host "Using Invoke-WebRequest (with timeout + no proxy)..."
            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing -TimeoutSec 60 -NoProxy
        }

        if (-not (Test-Path $installerPath)) {
            throw "Download failed — installer file not created."
        }

        Write-Host "Installer downloaded: $installerPath"
    }
    catch {
        Write-Host ""
        Write-Host "[WARNING] Could not download Ollama automatically."
        Write-Host "Network restrictions, proxy, or firewall may be blocking it."
        Write-Host ""
        Write-Host "Please install it manually from:"
        Write-Host "    https://ollama.com/download"
        Write-Host ""
        Write-Host "After installing, open a NEW PowerShell window and run:"
        Write-Host "    ollama pull llama3"
        exit 0
    }

    Write-Host "[3/7] Running the Ollama installer..."
    Start-Process -FilePath $installerPath -Wait
    Write-Host "Installer finished. You may need to restart PowerShell."
}

# Refresh PATH after install
$env:PATH = [Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
            [Environment]::GetEnvironmentVariable("PATH","User")

# Recheck for ollama
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

if (-not $ollamaCmd) {
    Write-Host ""
    Write-Host "[WARNING] 'ollama' command still not available."
    Write-Host "Open a NEW PowerShell window and run:"
    Write-Host "    ollama pull llama3"
    exit 0
}

# [4/7] Ensure Ollama server/service is running
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
    Write-Host "Ollama service not found or cannot be controlled."
    Write-Host "Trying to launch server manually..."
    Start-Process -FilePath "C:\Program Files\Ollama\ollama.exe" -ArgumentList "serve"
    Start-Sleep -Seconds 5
}

# [5/7] Check if the local API is responding (avoids hanging!)
Write-Host "[5/7] Checking Ollama local API..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 5 -NoProxy
    Write-Host "Ollama server is responding. Perfect."
}
catch {
    Write-Host ""
    Write-Host "[WARNING] Ollama server did not respond."
    Write-Host "Try launching manually:"
    Write-Host '    & "C:\Program Files\Ollama\ollama.exe" serve'
    exit 0
}

# [6/7] Pull llama3 model
Write-Host "[6/7] Pulling the 'llama3' model..."

try {
    ollama pull llama3
    Write-Host "Model pull complete (or already installed)."
}
catch {
    Write-Host ""
    Write-Host "[WARNING] Could not pull llama3 automatically."
    Write-Host "Try manually:"
    Write-Host "    ollama pull llama3"
    exit 0
}

# [7/7] Done!
Write-Host ""
Write-Host "All done! Test with:"
Write-Host "    ollama run llama3"
Write-Host ""
Write-Host "You're ready to use the Offline AI CLI."