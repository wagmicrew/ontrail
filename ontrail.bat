@echo off
REM Ontrail.tech Management Script
REM Usage: ontrail <command> [args...]

powershell.exe -ExecutionPolicy Bypass -File "%~dp0ontrail.ps1" %*
