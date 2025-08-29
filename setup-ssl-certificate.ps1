# Ontrail SSL/HTTPS Setup Script for Windows
# Sets up Let's Encrypt SSL certificate for ontrail.tech

param(
    [string]$Domain = "ontrail.tech",
    [string]$Email = "admin@ontrail.tech",
    [string]$ServerHost = "85.208.51.194",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "🔒 Setting up HTTPS/SSL for $Domain..." -ForegroundColor Blue
Write-Host "=============================================" -ForegroundColor Blue

# Test SSH connection first
Write-Host "Testing SSH connection..." -ForegroundColor Yellow
try {
    $testResult = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" "echo 'SSH connection test successful'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH connection successful" -ForegroundColor Green
    } else {
        Write-Host "❌ SSH connection failed" -ForegroundColor Red
        Write-Host "Please ensure SSH key is properly configured" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ SSH connection error: $_" -ForegroundColor Red
    exit 1
}

# Copy the SSL setup script to server
Write-Host "Copying SSL setup script to server..." -ForegroundColor Yellow
scp -i $SSHKeyPath -o StrictHostKeyChecking=no setup-ssl-https.sh root@$ServerHost:/root/

# Execute the SSL setup script on server
Write-Host "Executing SSL setup script on server..." -ForegroundColor Yellow
Write-Host "This will:" -ForegroundColor Cyan
Write-Host "  • Install Certbot and nginx plugin" -ForegroundColor White
Write-Host "  • Obtain SSL certificate from Let's Encrypt" -ForegroundColor White
Write-Host "  • Configure nginx for HTTPS" -ForegroundColor White
Write-Host "  • Set up automatic certificate renewal" -ForegroundColor White
Write-Host "  • Configure firewall for HTTPS" -ForegroundColor White
Write-Host ""

ssh -i $SSHKeyPath -o StrictHostKeyChecking=no root@$ServerHost "chmod +x /root/setup-ssl-https.sh && /root/setup-ssl-https.sh"

Write-Host "`n🎉 SSL/HTTPS Setup Complete!" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "Your site is now available at:" -ForegroundColor Blue
Write-Host "  https://$Domain" -ForegroundColor Blue
Write-Host "  https://www.$Domain" -ForegroundColor Blue
Write-Host "" -ForegroundColor Blue
Write-Host "HTTP traffic is automatically redirected to HTTPS" -ForegroundColor Cyan
Write-Host "Certificates auto-renew every Monday at 2:30 AM" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "To check certificate status on server:" -ForegroundColor Yellow
Write-Host "  ssh root@$ServerHost 'certbot certificates'" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Yellow
Write-Host "To manually renew certificate:" -ForegroundColor Yellow
Write-Host "  ssh root@$ServerHost 'certbot renew'" -ForegroundColor Yellow

