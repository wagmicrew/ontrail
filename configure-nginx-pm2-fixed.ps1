# Configure Nginx & PM2 for Ontrail Production Setup (Fixed)
# Sets up HTTPS with SSL and PM2 for Node.js application

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "🚀 Configuring Nginx & PM2 for Production..." -ForegroundColor Blue
Write-Host "=============================================" -ForegroundColor Blue

# Test SSH connection
Write-Host "Testing SSH connection..." -ForegroundColor Yellow
try {
    $testResult = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" "echo 'SSH connection successful'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH connection successful" -ForegroundColor Green
    } else {
        Write-Host "❌ SSH connection failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ SSH connection error: $_" -ForegroundColor Red
    exit 1
}

# Copy configuration script to server
Write-Host "Copying configuration script to server..." -ForegroundColor Yellow
scp -i $SSHKeyPath -o StrictHostKeyChecking=no "configure-nginx-pm2.sh" "root@${ServerHost}:/root/"

# Execute configuration script on server
Write-Host "Executing configuration script on server..." -ForegroundColor Yellow
Write-Host "This will:" -ForegroundColor Cyan
Write-Host "  • Install and configure PM2" -ForegroundColor White
Write-Host "  • Create Next.js production server" -ForegroundColor White
Write-Host "  • Build and start application with PM2" -ForegroundColor White
Write-Host "  • Configure nginx with SSL proxy" -ForegroundColor White
Write-Host "  • Set up monitoring and logging" -ForegroundColor White
Write-Host "  • Configure automatic startup" -ForegroundColor White
Write-Host ""

ssh -i $SSHKeyPath -o StrictHostKeyChecking=no "root@${ServerHost}" "chmod +x /root/configure-nginx-pm2.sh && /root/configure-nginx-pm2.sh"

Write-Host "`n🎉 Nginx & PM2 Configuration Complete!" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "Your application is now running in production mode:" -ForegroundColor Blue
Write-Host "  • HTTPS: https://ontrail.tech" -ForegroundColor Blue
Write-Host "  • Health: https://ontrail.tech/health" -ForegroundColor Blue
Write-Host "" -ForegroundColor Blue
Write-Host "Management Commands:" -ForegroundColor Yellow
Write-Host "• Check status: ssh -i $SSHKeyPath root@$ServerHost 'ontrail-status.sh'" -ForegroundColor White
Write-Host "• View logs: ssh -i $SSHKeyPath root@$ServerHost 'pm2 logs'" -ForegroundColor White
Write-Host "• Restart app: ssh -i $SSHKeyPath root@$ServerHost 'pm2 restart ontrail-app'" -ForegroundColor White
Write-Host "• Monitor: ssh -i $SSHKeyPath root@$ServerHost 'tail -f /var/www/ontrailapp/logs/monitor.log'" -ForegroundColor White
Write-Host "" -ForegroundColor Yellow
Write-Host "🎊 Production setup complete!" -ForegroundColor Green

