# Ontrail.tech Management Script
# Usage: ontrail <command> [args...]
# Example: ontrail deploy
#          ontrail logs
#          ontrail reset-db

param(
    [string]$Command = "help",
    [string]$RemoteCommand = ""
)

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DeployScript = Join-Path $ScriptDir "ontrail-deploy.ps1"

# Execute the main deployment script with the provided arguments
& $DeployScript -Command $Command -RemoteCommand $RemoteCommand
