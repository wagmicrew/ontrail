# Simple test for SSH MCP connection

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "Testing SSH MCP Connection..." -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue

# Test 1: SSH Key
Write-Host "Test 1: Checking SSH key..." -ForegroundColor Yellow
if (Test-Path $SSHKeyPath) {
    Write-Host "PASS: SSH key found" -ForegroundColor Green
} else {
    Write-Host "FAIL: SSH key not found" -ForegroundColor Red
}

# Test 2: SSH Connection
Write-Host "Test 2: Testing SSH connection..." -ForegroundColor Yellow
try {
    $result = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" "echo 'test'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PASS: SSH connection successful" -ForegroundColor Green
    } else {
        Write-Host "FAIL: SSH connection failed" -ForegroundColor Red
    }
} catch {
    Write-Host "FAIL: SSH connection error" -ForegroundColor Red
}

# Test 3: MCP Directory
Write-Host "Test 3: Checking MCP directory..." -ForegroundColor Yellow
$MCP_DIR = "$env:USERPROFILE\.cursor-mcp"
if (Test-Path $MCP_DIR) {
    Write-Host "PASS: MCP directory exists" -ForegroundColor Green

    $files = @(
        "$MCP_DIR\mcp-server-ssh.js",
        "$MCP_DIR\package.json"
    )

    foreach ($file in $files) {
        if (Test-Path $file) {
            Write-Host "PASS: $(Split-Path $file -Leaf) exists" -ForegroundColor Green
        } else {
            Write-Host "FAIL: $(Split-Path $file -Leaf) missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "FAIL: MCP directory not found" -ForegroundColor Red
}

# Test 4: MCP Config
Write-Host "Test 4: Checking MCP config..." -ForegroundColor Yellow
$MCP_CONFIG = "$env:USERPROFILE\.cursor\mcp.json"
if (Test-Path $MCP_CONFIG) {
    Write-Host "PASS: MCP config exists" -ForegroundColor Green

    try {
        $config = Get-Content $MCP_CONFIG -Raw | ConvertFrom-Json
        if ($config."ssh-remote-manager") {
            Write-Host "PASS: SSH remote manager configured" -ForegroundColor Green
        } else {
            Write-Host "FAIL: SSH remote manager not configured" -ForegroundColor Red
        }
    } catch {
        Write-Host "FAIL: Error reading MCP config" -ForegroundColor Red
    }
} else {
    Write-Host "FAIL: MCP config not found" -ForegroundColor Red
}

# Test 5: Node.js
Write-Host "Test 5: Checking Node.js..." -ForegroundColor Yellow
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "PASS: Node.js installed" -ForegroundColor Green
} else {
    Write-Host "FAIL: Node.js not installed" -ForegroundColor Red
}

Write-Host "`nSetup Summary:" -ForegroundColor Blue
Write-Host "Server: $ServerHost" -ForegroundColor Cyan
Write-Host "User: $ServerUser" -ForegroundColor Cyan
Write-Host "SSH Key: $SSHKeyPath" -ForegroundColor Cyan

Write-Host "`nNext Steps:" -ForegroundColor Green
Write-Host "1. Fix any FAILED tests above" -ForegroundColor White
Write-Host "2. Run setup script if needed: .\setup-mcp-ssh.ps1" -ForegroundColor White
Write-Host "3. Restart Cursor IDE" -ForegroundColor White
Write-Host "4. Test in Cursor: Ask 'Check server status'" -ForegroundColor White


