<#
    setup_ollama_windows.ps1

    This script is a helper for setting up Ollama on Windows
    for the Offline AI CLI project.

    What it does:
    - Checks if the `ollama` command is available
    - If not, checks the common user install path:
        %LOCALAPPDATA%\Programs\Ollama
      and adds it to PATH if found
    - Tries to start the Ollama server
    - Checks the local API
    - Pulls the `llama3` model

    If you do not want to run this script:
    - Install Ollama from: https://ollama.com/download
    - Open a NEW PowerShell window
    - Run: ollama pull llama3
#>

$ErrorActionPreference = "Stop"

Write-Host "== Setting up Ollama on Windows =="

# [1/6] Check if the Ollama CLI exists
Write-Host "[1/6] Checking for 'ollama' command..."
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

if (-not $ollamaCmd) {
    Write-Host "[INFO] 'ollama' is not on PATH. Checking common install location..."

    $userOllamaDir = Join-Path $env:LOCALAPPDATA "Programs\Ollama"
    $userOllamaExe = Join-Path $userOllamaDir "ollama.exe"

    if (Test-Path $userOllamaExe) {
        Write-Host "[INFO] Found ollama.exe at:"
        Write-Host "       $userOllamaExe"
        Write-Host "[INFO] Adding this folder to PATH so 'ollama' works everywhere..."

        # Get the current user PATH
        $currentUserPath = [Environment]::GetEnvironmentVariable("PATH","User")

        if ($currentUserPath -notlike "*$userOllamaDir*") {
            $newUserPath = "$currentUserPath;$userOllamaDir"
            setx PATH $newUserPath | Out-Null
        }

        # Also update this session so the rest of the script can use `ollama`
        $machinePath = [Environment]::GetEnvironmentVariable("PATH","Machine")
        $env:PATH = "$machinePath;$currentUserPath;$userOllamaDir"

        # Try again to resolve the command
        $ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

        if ($ollamaCmd) {
            Write-Host "[INFO] 'ollama' is now available in this session."
        } else {
            Write-Host "[WARNING] Added Ollama to PATH but the command still is not resolving."
            Write-Host "You may need to open a NEW PowerShell window after this script finishes."
        }
    } else {
        Write-Host "[WARNING] Could not find Ollama in the common user path:"
        Write-Host "         $userOllamaDir"
        Write-Host ""
        Write-Host "Please install Ollama manually from:"
        Write-Host "    https://ollama.com/download"
        Write-Host ""
        Write-Host "Then open a NEW PowerShell window and run:"
        Write-Host "    ollama pull llama3"
        exit 0
    }
}

# If we STILL do not have ollama, stop here
if (-not $ollamaCmd) {
    Write-Host ""
    Write-Host "[ERROR] 'ollama' command is still not available after PATH fix."
    Write-Host "Please restart PowerShell and try again, or reinstall Ollama."
    exit 1
}

# [2/6] Try to ensure the server is running
Write-Host "[2/6] Checking if the Ollama server is running..."

try {
    $svc = Get-Service ollama -ErrorAction Stop
    if ($svc.Status -ne "Running") {
        Write-Host "[INFO] Ollama service is stopped. Starting it..."
        Start-Service ollama
        Start-Sleep -Seconds 3
    }
}
catch {
    Write-Host "[INFO] Ollama service not found or cannot be controlled."
    Write-Host "[INFO] Trying to launch the server directly from the common user path..."
    $userOllamaDir = Join-Path $env:LOCALAPPDATA "Programs\Ollama"
    $userOllamaExe = Join-Path $userOllamaDir "ollama.exe"

    if (Test-Path $userOllamaExe) {
        Start-Process -FilePath $userOllamaExe -ArgumentList "serve"
        Start-Sleep -Seconds 5
    } else {
        Write-Host "[WARNING] Could not find ollama.exe to start the server."
    }
}

# [3/6] Check if the local API is responding
Write-Host "[3/6] Checking Ollama local API..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 5
    Write-Host "[INFO] Ollama server is responding."
}
catch {
    Write-Host ""
    Write-Host "[WARNING] Ollama server did not respond."
    Write-Host "You can try starting it manually with:"
    Write-Host "    ollama serve"
    Write-Host "Then re-run this script or pull the model manually:"
    Write-Host "    ollama pull llama3"
    exit 0
}

# [4/6] Pull llama3 model
Write-Host "[4/6] Pulling the 'llama3' model..."

try {
    ollama pull llama3
    Write-Host "[INFO] Model pull complete (or already installed)."
}
catch {
    Write-Host ""
    Write-Host "[WARNING] Could not pull llama3 automatically."
    Write-Host "Try manually:"
    Write-Host "    ollama pull llama3"
    exit 0
}

# [5/6] Show final check
Write-Host ""
Write-Host "[5/6] Quick check: installed models:"
try {
    ollama list
} catch {
    Write-Host "[WARNING] Could not list models, but pull did not throw an error."
}

# [6/6] Done
Write-Host ""
Write-Host "All done! You can test Ollama with:"
Write-Host "    ollama run llama3"
Write-Host ""
Write-Host "You're ready to use the Offline AI CLI."
