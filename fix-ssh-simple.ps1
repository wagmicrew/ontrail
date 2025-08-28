# Simple SSH Fix
# Fix SSH passwordless access

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "🔧 Fixing SSH Passwordless Access..." -ForegroundColor Blue

# Check SSH key
if (Test-Path $SSHKeyPath) {
    Write-Host "✅ SSH key exists" -ForegroundColor Green
} else {
    Write-Host "❌ SSH key missing, creating..." -ForegroundColor Red
    ssh-keygen -t rsa -b 4096 -f $SSHKeyPath -N '""'
}

# Read public key
$publicKeyPath = "$SSHKeyPath.pub"
if (Test-Path $publicKeyPath) {
    $publicKey = Get-Content $publicKeyPath -Raw
    Write-Host "✅ Public key loaded" -ForegroundColor Green
} else {
    Write-Host "❌ Public key not found" -ForegroundColor Red
    exit 1
}

# Create remote commands
$remoteCommands = @"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '$publicKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sort ~/.ssh/authorized_keys | uniq > ~/.ssh/authorized_keys.tmp
mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
echo 'SSH key setup complete'
"@

Write-Host "Setting up SSH key on server..." -ForegroundColor Yellow

# Execute remote commands
try {
    $result = ssh -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" $remoteCommands 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH key setup successful" -ForegroundColor Green
    } else {
        Write-Host "❌ SSH setup failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ SSH error: $_" -ForegroundColor Red
    exit 1
}

# Test connection
Write-Host "Testing SSH connection..." -ForegroundColor Yellow
try {
    $testResult = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" "echo 'SSH test successful'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Passwordless SSH working!" -ForegroundColor Green
    } else {
        Write-Host "❌ SSH test failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ SSH test error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 SSH Passwordless Access Fixed!" -ForegroundColor Green
