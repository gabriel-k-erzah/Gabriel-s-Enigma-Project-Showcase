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

    Extra Windows note:
    On some systems, Ollama installs under:
        %LOCALAPPDATA%\Programs\Ollama
    but does NOT add itself to PATH.
    This script now detects that and adds it, so `ollama`
    is available everywhere (this was exactly the issue I hit).
#>

$ErrorActionPreference = "Stop"

Write-Host "== Setting up Ollama on Windows =="

# [1/7] Check if the Ollama CLI exists
Write-Host "[1/7] Checking for 'ollama' command..."
$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

# Special case: Ollama is installed in the user-local Programs folder but not on PATH.
# This is very common on Windows and was the exact cause of the earlier confusion.
if (-not $ollamaCmd) {
    $userOllamaDir = Join-Path $env:LOCALAPPDATA "Programs\Ollama"
    $userOllamaExe = Join-Path $userOllamaDir "ollama.exe"

    if (Test-Path $userOllamaExe) {
        Write-Host "[INFO] Found ollama.exe at:"
        Write-Host "       $userOllamaExe"
        Write-Host "[INFO] But it's not on PATH yet. Adding it so 'ollama' works everywhere..."

        # Append to the user PATH persistently
        $newPath = "$($env:PATH);$userOllamaDir"
        setx PATH $newPath | Out-Null

        # Also update the current session so this script can keep going
        $env:PATH = $newPath

        # Try again to resolve the command
        $ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue

        if ($ollamaCmd) {
            Write-Host "[INFO] 'ollama' is now available in this session."
        } else {
            Write-Host "[WARNING] Tried to add Ollama to PATH but the command still isn't resolving."
            Write-Host "You may need to open a NEW PowerShell window after this script finishes."
        }
    }
}

# -----------------------------
# If Ollama STILL isn't found:
# Try to download + install it
# -----------------------------
if (-not $ollamaCmd) {

    Write-Host "[2/7] Ollama not found. Attempting to download installer..."

    $installerUrl = "https://ollama.com/download/OllamaSetup.exe"
    $installerPath = Join-Path $env:TEMP "OllamaSetup.exe"

    try {
        # Prefer curl.exe for reliability over the PowerShell alias
        $curlCmd = Get-Command curl.exe -ErrorAction SilentlyContinue

        if ($curlCmd) {
            Write-Host "Using curl.exe to download Ollama..."
            & curl.exe -L $installerUrl -o $installerPath
        } else
            {
            Write-Host "Using Invoke-WebRequest (with timeout)..."
            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing -TimeoutSec 60
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
    Start-Process -FilePath "C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama\ollama.exe" -ArgumentList "serve" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
}

# [5/7] Check if the local API is responding
Write-Host "[5/7] Checking Ollama local API..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 5
    Write-Host "Ollama server is responding. Perfect."
}
catch {
    Write-Host ""
    Write-Host "[WARNING] Ollama server did not respond."
    Write-Host "Try launching manually with:"
    Write-Host '    & "C:\Users\<YourUser>\AppData\Local\Programs\Ollama\ollama.exe" serve'
    Write-Host "Then re-run this script or pull the model manually:"
    Write-Host "    ollama pull llama3"
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
Write-Host "All done! You can test with:"
Write-Host "    ollama run llama3"
Write-Host ""
Write-Host "You're ready to use the Offline AI CLI."