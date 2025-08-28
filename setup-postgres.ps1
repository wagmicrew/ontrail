# 🚀 PostgreSQL Setup Script for Ontrail Social-Fi Application
# This script sets up PostgreSQL on the remote server and configures everything for Ontrail

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$Username = "root",
    [string]$SshKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

# Configuration
$SetupScript = "ubuntu_postgres_setup.sh"
$LocalScriptPath = "$PSScriptRoot\$SetupScript"
$RemoteScriptPath = "/tmp/$SetupScript"

Write-Host "🐘 Setting up PostgreSQL for Ontrail Social-Fi Application..." -ForegroundColor Blue
Write-Host "============================================================" -ForegroundColor Blue

# Colors for output
$Blue = "Blue"
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Step 1: Test SSH connection
Write-Status "Testing SSH connection to $ServerHost..."
try {
    $testResult = ssh -i $SshKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 $Username@$ServerHost "echo 'SSH connection successful'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SSH connection successful!"
    } else {
        throw "SSH connection failed"
    }
} catch {
    Write-Error "Cannot connect to server $ServerHost. Please check your SSH configuration."
    Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "1. Verify SSH key exists: $SshKeyPath" -ForegroundColor Yellow
    Write-Host "2. Check server IP address: $ServerHost" -ForegroundColor Yellow
    Write-Host "3. Ensure server is running and accessible" -ForegroundColor Yellow
    exit 1
}

# Step 2: Upload setup script to server
Write-Status "Uploading PostgreSQL setup script to server..."
try {
    scp -i $SshKeyPath -o StrictHostKeyChecking=no $LocalScriptPath $Username@${ServerHost}:$RemoteScriptPath
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Setup script uploaded successfully!"
    } else {
        throw "Failed to upload setup script"
    }
} catch {
    Write-Error "Failed to upload setup script to server."
    exit 1
}

# Step 3: Make script executable and run it
Write-Status "Making setup script executable and running PostgreSQL setup..."
try {
    $setupCommand = @"
chmod +x $RemoteScriptPath && bash $RemoteScriptPath
"@

    ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost $setupCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Success "PostgreSQL setup completed successfully!"
    } else {
        throw "PostgreSQL setup failed"
    }
} catch {
    Write-Error "PostgreSQL setup failed on the server."
    Write-Host "You may need to run the setup script manually on the server:" -ForegroundColor Yellow
    Write-Host "1. SSH into the server: ssh -i $SshKeyPath $Username@$ServerHost" -ForegroundColor Yellow
    Write-Host "2. Make script executable: chmod +x $RemoteScriptPath" -ForegroundColor Yellow
    Write-Host "3. Run the script: bash $RemoteScriptPath" -ForegroundColor Yellow
    exit 1
}

# Step 4: Verify setup
Write-Status "Verifying PostgreSQL setup..."
try {
    $verifyCommand = "PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c 'SELECT current_database(), current_user;'"
    ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost $verifyCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Database connection verification successful!"
    }
} catch {
    Write-Warning "Could not verify database connection automatically."
}

# Step 5: Clean up
Write-Status "Cleaning up temporary files..."
try {
    ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "rm -f $RemoteScriptPath"
    Write-Success "Cleanup completed!"
} catch {
    Write-Warning "Could not clean up remote temporary files (non-critical)."
}

Write-Host ""
Write-Host "🎉 PostgreSQL Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Database Configuration:" -ForegroundColor Cyan
Write-Host "   Server: $ServerHost" -ForegroundColor White
Write-Host "   Database: ontrail" -ForegroundColor White
Write-Host "   User: ontrail_user" -ForegroundColor White
Write-Host "   Password: Tropictiger2025!" -ForegroundColor White
Write-Host "   Port: 5432" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Database URL: postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Green
Write-Host "1. Run database migrations on the server:" -ForegroundColor White
Write-Host "   cd /var/www/ontrailapp/webApp" -ForegroundColor White
Write-Host "   npm run db:migrate" -ForegroundColor White
Write-Host ""
Write-Host "2. Restart the Ontrail application:" -ForegroundColor White
Write-Host "   pm2 restart ontrail-app" -ForegroundColor White
Write-Host ""
Write-Host "3. Test the application at: https://ontrail.tech" -ForegroundColor White
Write-Host ""
Write-Host "🔐 Security Notes:" -ForegroundColor Yellow
Write-Host "- Change the default password in production" -ForegroundColor Yellow
Write-Host "- Update OAuth credentials in .env.local" -ForegroundColor Yellow
Write-Host "- Configure proper firewall rules for PostgreSQL" -ForegroundColor Yellow
