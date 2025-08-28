# Simple PostgreSQL Setup Script
Write-Host "Starting PostgreSQL setup..." -ForegroundColor Green

# Test SSH connection
Write-Host "Testing SSH connection..." -ForegroundColor Yellow
ssh -i "$env:USERPROFILE\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@85.208.51.194 "echo 'SSH OK'" 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "SSH connection failed!" -ForegroundColor Red
    exit 1
}

Write-Host "SSH connection successful!" -ForegroundColor Green

# Copy setup script to server
Write-Host "Copying setup script..." -ForegroundColor Yellow
scp -i "$env:USERPROFILE\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no "manual-db-setup.sh" root@85.208.51.194:/tmp/ 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to copy script!" -ForegroundColor Red
    exit 1
}

Write-Host "Setup script copied!" -ForegroundColor Green

# Execute setup script
Write-Host "Executing PostgreSQL setup..." -ForegroundColor Yellow
ssh -i "$env:USERPROFILE\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "chmod +x /tmp/manual-db-setup.sh && /tmp/manual-db-setup.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Setup script failed!" -ForegroundColor Red
    exit 1
}

Write-Host "PostgreSQL setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Database Configuration:" -ForegroundColor Cyan
Write-Host "  Database: ontrail"
Write-Host "  User: ontrail_user"
Write-Host "  Password: Tropictiger2025!"
Write-Host "  URL: postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail"
Write-Host ""
Write-Host "Application: https://ontrail.tech" -ForegroundColor Cyan
