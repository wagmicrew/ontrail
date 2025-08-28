# Test script for SSH MCP connection
# This script tests the SSH connection and MCP server setup

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "Testing SSH MCP Connection..." -ForegroundColor Blue
Write-Host "=====================================" -ForegroundColor Blue

Write-Host "Server Host: $ServerHost" -ForegroundColor Cyan
Write-Host "Server User: $ServerUser" -ForegroundColor Cyan
Write-Host "SSH Key Path: $SSHKeyPath" -ForegroundColor Cyan

# Test 1: Check if SSH key exists
Write-Host "Test 1: Checking SSH key..." -ForegroundColor Yellow
if (Test-Path $SSHKeyPath) {
    Write-Host "SSH key found at $SSHKeyPath" -ForegroundColor Green

    # Check key permissions (should be restricted)
    $keyAcl = Get-Acl $SSHKeyPath
    $owner = $keyAcl.Owner
    Write-Host "   Key owner: $owner" -ForegroundColor Gray

} else {
    Write-Host "SSH key not found at $SSHKeyPath" -ForegroundColor Red
    Write-Host "   Please run the setup script first: .\setup-mcp-ssh.ps1" -ForegroundColor Yellow
    exit 1
}

# Test 2: Test SSH connection
Write-Host "`nTest 2: Testing SSH connection..." -ForegroundColor Yellow
try {
    $testCommand = "echo 'SSH connection test successful - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')'"
    $result = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" $testCommand 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SSH connection successful" -ForegroundColor Green
        Write-Host "   Server response: $result" -ForegroundColor Gray
    } else {
        Write-Host "SSH connection failed" -ForegroundColor Red
        Write-Host "   Exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host "SSH connection error: $_" -ForegroundColor Red
}

# Test 3: Check MCP directory and files
Write-Host "`nTest 3: Checking MCP setup..." -ForegroundColor Yellow
$MCP_DIR = "$env:USERPROFILE\.cursor-mcp"
$MCP_CONFIG = "$env:USERPROFILE\.cursor\mcp.json"

if (Test-Path $MCP_DIR) {
    Write-Host "MCP directory exists: $MCP_DIR" -ForegroundColor Green

    # Check if MCP server files exist
    $serverFile = "$MCP_DIR\mcp-server-ssh.js"
    $packageFile = "$MCP_DIR\package.json"

    if (Test-Path $serverFile) {
        Write-Host "MCP server file exists" -ForegroundColor Green
    } else {
        Write-Host "MCP server file missing: $serverFile" -ForegroundColor Red
    }

    if (Test-Path $packageFile) {
        Write-Host "Package.json exists" -ForegroundColor Green
    } else {
        Write-Host "Package.json missing: $packageFile" -ForegroundColor Red
    }

    # Check node_modules
    if (Test-Path "$MCP_DIR\node_modules") {
        Write-Host "Node modules installed" -ForegroundColor Green
    } else {
        Write-Host "Node modules not found. Run: cd $MCP_DIR; npm install" -ForegroundColor Yellow
    }

} else {
    Write-Host "MCP directory not found: $MCP_DIR" -ForegroundColor Red
}

# Test 4: Check MCP configuration
Write-Host "`nTest 4: Checking MCP configuration..." -ForegroundColor Yellow
if (Test-Path $MCP_CONFIG) {
    Write-Host "✅ MCP config file exists: $MCP_CONFIG" -ForegroundColor Green

    try {
        $config = Get-Content $MCP_CONFIG -Raw | ConvertFrom-Json
        if ($config."ssh-remote-manager") {
            Write-Host "✅ SSH remote manager configured" -ForegroundColor Green
            Write-Host "   Host: $($config."ssh-remote-manager".env.SSH_HOST)" -ForegroundColor Gray
            Write-Host "   User: $($config."ssh-remote-manager".env.SSH_USER)" -ForegroundColor Gray
        } else {
            Write-Host "❌ SSH remote manager not configured in MCP" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error reading MCP config: $_" -ForegroundColor Red
    }
} else {
    Write-Host "❌ MCP config file not found: $MCP_CONFIG" -ForegroundColor Red
}

# Test 5: Test Node.js and npm
Write-Host "`nTest 5: Checking Node.js setup..." -ForegroundColor Yellow
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Host "✅ Node.js installed: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "❌ Node.js not installed" -ForegroundColor Red
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    $npmVersion = npm --version
    Write-Host "✅ npm installed: $npmVersion" -ForegroundColor Green
} else {
    Write-Host "❌ npm not installed" -ForegroundColor Red
}

# Summary
Write-Host "`n📋 Test Summary" -ForegroundColor Blue
Write-Host "===============" -ForegroundColor Blue

$tests = @(
    @{ Name = "SSH Key"; Status = (Test-Path $SSHKeyPath) },
    @{ Name = "SSH Connection"; Status = ($LASTEXITCODE -eq 0) },
    @{ Name = "MCP Directory"; Status = (Test-Path $MCP_DIR) },
    @{ Name = "MCP Server File"; Status = (Test-Path "$MCP_DIR\mcp-server-ssh.js") },
    @{ Name = "Package.json"; Status = (Test-Path "$MCP_DIR\package.json") },
    @{ Name = "MCP Config"; Status = (Test-Path $MCP_CONFIG) },
    @{ Name = "Node.js"; Status = (Get-Command node -ErrorAction SilentlyContinue) },
    @{ Name = "npm"; Status = (Get-Command npm -ErrorAction SilentlyContinue) }
)

foreach ($test in $tests) {
    $status = if ($test.Status) { "✅" } else { "❌" }
    Write-Host ("{0,-20} {1}" -f $test.Name, $status)
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Green
Write-Host "1. If any tests failed, run: .\setup-mcp-ssh.ps1" -ForegroundColor White
Write-Host "2. Restart Cursor IDE" -ForegroundColor White
Write-Host "3. Test in Cursor: 'Check server status'" -ForegroundColor White
Write-Host "4. Try: 'Execute pm2 status on the server'" -ForegroundColor White

Write-Host "`nPro Tips:" -ForegroundColor Cyan
Write-Host "- Use natural language commands in Cursor" -ForegroundColor White
Write-Host "- The MCP server runs automatically with Cursor" -ForegroundColor White
Write-Host "- Check Cursor developer console for MCP logs" -ForegroundColor White
Write-Host "- All commands are executed securely over SSH" -ForegroundColor White
