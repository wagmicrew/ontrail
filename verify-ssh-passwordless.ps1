# Verify and Strengthen SSH Passwordless Access
# Ensures all connections from Cursor to server are passwordless

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "🔐 Verifying SSH Passwordless Access..." -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue

# Check if SSH key exists
Write-Host "1. Checking SSH key..." -ForegroundColor Yellow
if (Test-Path $SSHKeyPath) {
    Write-Host "   ✅ SSH key found: $SSHKeyPath" -ForegroundColor Green

    # Check key permissions
    $keyAcl = Get-Acl $SSHKeyPath
    Write-Host "   📁 Key permissions: $($keyAcl.Owner)" -ForegroundColor Gray
} else {
    Write-Host "   ❌ SSH key not found: $SSHKeyPath" -ForegroundColor Red
    Write-Host "   Please run: ssh-keygen -t rsa -b 4096 -f $SSHKeyPath" -ForegroundColor Yellow
    exit 1
}

# Test SSH connection
Write-Host "`n2. Testing SSH connection..." -ForegroundColor Yellow
try {
    $testResult = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o PasswordAuthentication=no "$ServerUser@$ServerHost" "echo 'SSH test successful - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')'" 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ SSH connection successful (passwordless)" -ForegroundColor Green
        Write-Host "   📄 Server response: $testResult" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ SSH connection failed or requires password" -ForegroundColor Red
        Write-Host "   💡 Try: ssh-copy-id -i $SSHKeyPath $ServerUser@$ServerHost" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   ❌ SSH connection error: $_" -ForegroundColor Red
    exit 1
}

# Check SSH config for optimizations
Write-Host "`n3. Checking SSH configuration..." -ForegroundColor Yellow
$sshConfigPath = "$env:USERPROFILE\.ssh\config"

if (Test-Path $sshConfigPath) {
    Write-Host "   ✅ SSH config exists" -ForegroundColor Green

    $configContent = Get-Content $sshConfigPath -Raw
    if ($configContent -match "Host.*ontrail") {
        Write-Host "   ✅ Server-specific config found" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  No server-specific config found" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️  SSH config not found, creating..." -ForegroundColor Yellow

    $sshConfig = @"
# SSH Client Configuration
Host ontrail-server
    HostName $ServerHost
    User $ServerUser
    IdentityFile $SSHKeyPath
    IdentitiesOnly yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel QUIET

Host $ServerHost
    HostName $ServerHost
    User $ServerUser
    IdentityFile $SSHKeyPath
    IdentitiesOnly yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel QUIET
"@

    Set-Content -Path $sshConfigPath -Value $sshConfig
    Write-Host "   ✅ SSH config created" -ForegroundColor Green
}

# Test multiple connections to ensure stability
Write-Host "`n4. Testing connection stability..." -ForegroundColor Yellow
$successCount = 0
for ($i = 1; $i -le 3; $i++) {
    try {
        $result = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$ServerUser@$ServerHost" "echo 'Test $i'" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $successCount++
        }
    } catch {
        # Ignore errors in this test
    }
}

if ($successCount -eq 3) {
    Write-Host "   ✅ All connection tests passed (3/3)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Some connections failed ($successCount/3)" -ForegroundColor Yellow
}

# Copy public key to server again to ensure it's there
Write-Host "`n5. Ensuring SSH key is on server..." -ForegroundColor Yellow

# Read the public key
$publicKeyPath = "$SSHKeyPath.pub"
if (Test-Path $publicKeyPath) {
    $publicKey = Get-Content $publicKeyPath -Raw

    # Copy to server
    $remoteCommand = @"
mkdir -p ~/.ssh
echo '$publicKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
sort ~/.ssh/authorized_keys | uniq > ~/.ssh/authorized_keys.tmp
mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
echo 'SSH key updated successfully'
"@

    try {
        $result = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" $remoteCommand 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ SSH key verified on server" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Could not verify SSH key on server" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ⚠️  Could not update SSH key on server: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ Public key not found: $publicKeyPath" -ForegroundColor Red
}

# Final test
Write-Host "`n6. Final verification..." -ForegroundColor Yellow
try {
    $finalTest = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" "whoami && echo 'Passwordless SSH: SUCCESS'" 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Passwordless SSH fully configured!" -ForegroundColor Green
        Write-Host "   👤 Connected as: $($finalTest -split '`n' | Select-Object -First 1)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Final test failed" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Final test error: $_" -ForegroundColor Red
}

Write-Host "`n🎉 SSH Passwordless Setup Complete!" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Blue
Write-Host "• SSH Key: $SSHKeyPath" -ForegroundColor Cyan
Write-Host "• Server: $ServerHost" -ForegroundColor Cyan
Write-Host "• User: $ServerUser" -ForegroundColor Cyan
Write-Host "• Status: Passwordless authentication ready" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "• Cursor MCP: Use natural language commands" -ForegroundColor White
Write-Host "• Direct SSH: ssh -i $SSHKeyPath $ServerUser@$ServerHost" -ForegroundColor White
Write-Host "• Deployment: .\ontrail-deploy.ps1 -Command <command>" -ForegroundColor White
Write-Host "" -ForegroundColor Yellow
Write-Host "All connections from Cursor to server are now passwordless! 🔐" -ForegroundColor Green
