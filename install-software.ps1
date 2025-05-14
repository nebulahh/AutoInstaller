param (
    [switch]$Uninstall
)

$installsoftwareFile = ".\install-software-list.txt"
$uninstallsoftwareFile = ".\uninstall-software-list.txt"
if (-not (Test-Path $softwareFile)) {
    Write-Host "ERROR: install-software-list.txt not found."
    exit
}
$apps = Get-Content $softwareFile
$uninstallapps = Get-Content $uninstallsoftwareFile

$logPath = ".\logs"
if (-not (Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath
}
$logFile = "$logPath\install-log.txt"

function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
}

function Is-Installed {
    param($packageName)
    choco list --localonly | Select-String "^$packageName" > $null
    return $?
}

if (-not $Uninstall) {
    foreach ($app in $apps) {
        if (Is-Installed $app) {
            Log "$app is already installed. Skipping."
        } else {
            Log "Installing $app..."
            choco install $app -y | Out-Null
            if ($?) {
                Log "$app installed successfully."
            } else {
                Log "Failed to install $app."
            }
        }
    }
}
else {
    foreach ($app in $uninstallapps) {
        if (Is-Installed $app) {
            Log "Uninstalling $app..."
            choco uninstall $app -y | Out-Null
            if ($?) {
                Log "$app uninstalled successfully."
            } else {
                Log "Failed to uninstall $app."
            }
        } else {
            Log "$app is not installed. Skipping."
        }
    }
}
