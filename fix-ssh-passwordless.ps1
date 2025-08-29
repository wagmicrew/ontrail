# Fix SSH Passwordless Access
# Ensures SSH works without passwords

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "🔧 Fixing SSH Passwordless Access..." -ForegroundColor Blue
Write-Host "=====================================" -ForegroundColor Blue

# Check if SSH key exists
Write-Host "1. Checking SSH key..." -ForegroundColor Yellow
if (Test-Path $SSHKeyPath) {
    Write-Host "   ✅ SSH key found: $SSHKeyPath" -ForegroundColor Green
} else {
    Write-Host "   ❌ SSH key not found: $SSHKeyPath" -ForegroundColor Red
    Write-Host "   Creating SSH key..." -ForegroundColor Yellow
    ssh-keygen -t rsa -b 4096 -f $SSHKeyPath -N '""'
    Write-Host "   ✅ SSH key created" -ForegroundColor Green
}

# Check if public key exists
$publicKeyPath = "$SSHKeyPath.pub"
if (Test-Path $publicKeyPath) {
    Write-Host "   ✅ Public key found: $publicKeyPath" -ForegroundColor Green
    $publicKey = Get-Content $publicKeyPath -Raw
} else {
    Write-Host "   ❌ Public key not found: $publicKeyPath" -ForegroundColor Red
    exit 1
}

# Copy public key to server
Write-Host "`n2. Setting up SSH key on server..." -ForegroundColor Yellow

# Method 1: Using ssh-copy-id (if available)
Write-Host "   Trying ssh-copy-id..." -ForegroundColor Gray
try {
    $result = ssh-copy-id -i $SSHKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ ssh-copy-id successful" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  ssh-copy-id failed, trying manual method..." -ForegroundColor Yellow
        # Method 2: Manual setup
        Write-Host "   Setting up manually..." -ForegroundColor Gray
        $remoteCommands = @"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '$publicKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sort ~/.ssh/authorized_keys | uniq > ~/.ssh/authorized_keys.tmp
mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
echo 'SSH key setup complete'
"@

        try {
            $result = ssh -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" $remoteCommands 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Manual SSH key setup successful" -ForegroundColor Green
            } else {
                Write-Host "   ❌ Manual setup failed" -ForegroundColor Red
                Write-Host "   Result: $result" -ForegroundColor Gray
                exit 1
            }
        } catch {
            Write-Host "   ❌ Manual setup error: $_" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "   ❌ ssh-copy-id error: $_" -ForegroundColor Red
    Write-Host "   Trying manual method..." -ForegroundColor Yellow

    # Manual setup as fallback
    $remoteCommands = @"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '$publicKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sort ~/.ssh/authorized_keys | uniq > ~/.ssh/authorized_keys.tmp
mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
echo 'SSH key setup complete'
"@

    try {
        $result = ssh -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" $remoteCommands 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Manual SSH key setup successful" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Manual setup failed" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "   ❌ Manual setup error: $_" -ForegroundColor Red
        exit 1
    }
}

# Test SSH connection
Write-Host "`n3. Testing SSH connection..." -ForegroundColor Yellow
try {
    $testResult = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o PasswordAuthentication=no "$ServerUser@$ServerHost" "echo 'SSH test successful - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')'" 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ SSH connection successful (passwordless)" -ForegroundColor Green
        Write-Host "   📄 Server response: $testResult" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ SSH connection failed or requires password" -ForegroundColor Red
        Write-Host "   💡 Try: ssh -v -i $SSHKeyPath $ServerUser@$ServerHost" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   ❌ SSH connection error: $_" -ForegroundColor Red
    exit 1
}

# Verify SSH key on server
Write-Host "`n4. Verifying SSH key on server..." -ForegroundColor Yellow
try {
    $verifyResult = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" "cat ~/.ssh/authorized_keys | grep -c '$($publicKey.Split()[0..1] -join ' ')'" 2>$null

    if ($LASTEXITCODE -eq 0 -and [int]$verifyResult -gt 0) {
        Write-Host "   ✅ SSH key verified on server" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  SSH key not found on server" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Verification error: $_" -ForegroundColor Red
}

# Create SSH config for easier connections
Write-Host "`n5. Setting up SSH config..." -ForegroundColor Yellow
$sshConfigPath = "$env:USERPROFILE\.ssh\config"

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

Set-Content -Path $sshConfigPath -Value $sshConfig -Force
Write-Host "   ✅ SSH config created" -ForegroundColor Green

# Final test
Write-Host "`n6. Final verification..." -ForegroundColor Yellow
try {
    $finalTest = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" "whoami && echo 'Passwordless SSH: SUCCESS' && date" 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Passwordless SSH fully configured!" -ForegroundColor Green
        Write-Host "   👤 Connected as: $($finalTest -split '`n' | Select-Object -First 1)" -ForegroundColor Gray
        Write-Host "   📅 Server time: $($finalTest -split '`n' | Select-Object -Last 1)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Final test failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Final test error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 SSH Passwordless Access Fixed!" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Blue
Write-Host "• SSH Key: $SSHKeyPath" -ForegroundColor Cyan
Write-Host "• Server: $ServerHost" -ForegroundColor Cyan
Write-Host "• User: $ServerUser" -ForegroundColor Cyan
Write-Host "• Status: Passwordless authentication ready" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "• Direct SSH: ssh -i $SSHKeyPath $ServerUser@$ServerHost" -ForegroundColor White
Write-Host "• Config SSH: ssh ontrail-server" -ForegroundColor White
Write-Host "• Deployment: .\ontrail-deploy.ps1 -Command <command>" -ForegroundColor White
Write-Host "" -ForegroundColor Yellow
Write-Host "All connections from Cursor to server are now passwordless!" -ForegroundColor Green

