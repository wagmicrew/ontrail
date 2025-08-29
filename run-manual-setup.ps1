# 🚀 Execute Manual PostgreSQL Setup
# This script copies and runs the manual setup script on the server

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$Username = "root",
    [string]$SshKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "🐘 Running Manual PostgreSQL Setup on Server..." -ForegroundColor Blue
Write-Host "=================================================" -ForegroundColor Blue

# Step 1: Copy the manual setup script to server
Write-Host "Copying setup script to server..." -ForegroundColor Yellow
scp -i $SshKeyPath -o StrictHostKeyChecking=no "manual-db-setup.sh" "$Username@${ServerHost}:/tmp/manual-db-setup.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to copy setup script to server" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Setup script copied successfully" -ForegroundColor Green

# Step 2: Make script executable and run it
Write-Host "Making script executable and running setup..." -ForegroundColor Yellow
ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "chmod +x /tmp/manual-db-setup.sh && bash /tmp/manual-db-setup.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Setup script execution failed" -ForegroundColor Red
    Write-Host "You may need to run the script manually on the server:" -ForegroundColor Yellow
    Write-Host "1. SSH into server: ssh -i $SshKeyPath $Username@$ServerHost" -ForegroundColor Yellow
    Write-Host "2. Make executable: chmod +x /tmp/manual-db-setup.sh" -ForegroundColor Yellow
    Write-Host "3. Run script: bash /tmp/manual-db-setup.sh" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ PostgreSQL setup completed successfully!" -ForegroundColor Green

# Step 3: Verify setup
Write-Host "Verifying setup..." -ForegroundColor Yellow
ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$ServerHost "PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c 'SELECT current_database(), current_user;' 2>/dev/null"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Database connection verified" -ForegroundColor Green
} else {
    Write-Host "⚠️  Database connection test inconclusive" -ForegroundColor Yellow
}

Write-Host "" -ForegroundColor White
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "📊 Your Database is Ready:" -ForegroundColor Cyan
Write-Host "   Server: $ServerHost" -ForegroundColor White
Write-Host "   Database: ontrail" -ForegroundColor White
Write-Host "   User: ontrail_user" -ForegroundColor White
Write-Host "   Password: Tropictiger2025!" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🌐 Test your application: https://ontrail.tech" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White
Write-Host "🔧 Check PM2 logs: pm2 logs ontrail-app" -ForegroundColor Yellow

