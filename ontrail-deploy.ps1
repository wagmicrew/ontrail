# Ontrail Deployment and Management Script for Windows
# Connects to ontrail.tech server for deployment and remote management

param(
    [string]$Command = "help",
    [string]$RemoteCommand = ""
)

# Configuration - Update these values for your server
$SERVER_USER = "root"  # Change this to your server user
$SERVER_HOST = "85.208.51.194"
$APP_DIR = "/var/www/ontrailapp"
$NODE_ENV = "production"

# Colors for output
$GREEN = "Green"
$YELLOW = "Yellow"
$RED = "Red"
$BLUE = "Blue"
$NC = "White"

function Write-Status {
    param([string]$Message)
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $GREEN
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] WARNING: $Message" -ForegroundColor $YELLOW
}

function Write-Error {
    param([string]$Message)
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] ERROR: $Message" -ForegroundColor $RED
}

function Write-Header {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor $BLUE
    Write-Host ("=" * 50) -ForegroundColor $BLUE
}

function Invoke-RemoteCommand {
    param([string]$Command)
    Write-Status "Running on server: $Command"
    try {
        $result = ssh -i "$env:USERPROFILE\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" $Command 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Remote command failed with exit code $LASTEXITCODE"
            Write-Error $result
            exit 1
        }
        return $result
    }
    catch {
        Write-Error "Failed to execute remote command: $_"
        exit 1
    }
}

function Copy-ToServer {
    param([string]$Source, [string]$Destination)
    Write-Status "Copying $Source to server:$Destination"
    try {
        $result = scp -i "$env:USERPROFILE\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no -r $Source "$SERVER_USER@$SERVER_HOST`:$Destination" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "SCP failed with exit code $LASTEXITCODE"
            Write-Error $result
            exit 1
        }
    }
    catch {
        Write-Error "Failed to copy files: $_"
        exit 1
    }
}

function New-SSHKey {
    Write-Header "Setting up SSH Key for Passwordless Access"

    $sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"

    # Check if SSH key exists
    if (-not (Test-Path $sshKeyPath)) {
        Write-Status "Generating SSH key pair..."
        ssh-keygen -t rsa -b 4096 -C "ontrail-deploy@$env:COMPUTERNAME" -f $sshKeyPath -N ""
    }

    # Copy public key to server
    Write-Status "Copying SSH public key to server..."
    $publicKey = Get-Content "$sshKeyPath.pub"
    $remoteCommand = "mkdir -p ~/.ssh && echo '$publicKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh"
    Invoke-RemoteCommand $remoteCommand

    Write-Status "SSH key setup complete! You can now connect without password."
    Write-Status "SSH Key location: $sshKeyPath"
}

function New-ServerDirectory {
    Write-Header "Setting up Server Directory Structure"

    Invoke-RemoteCommand "mkdir -p $APP_DIR"
    Invoke-RemoteCommand "mkdir -p $APP_DIR/webApp"
    Invoke-RemoteCommand "mkdir -p $APP_DIR/logs"
    Invoke-RemoteCommand "mkdir -p $APP_DIR/backups"

    Write-Status "Server directory structure created at $APP_DIR"
}

function New-NginxConfig {
    Write-Header "Setting up Nginx Configuration for ontrail.tech"

    $nginxConfig = @"
server {
    listen 80;
    server_name ontrail.tech www.ontrail.tech;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Root directory
    root $APP_DIR/webApp;
    index index.html index.htm;

    location / {
        try_files `$uri `$uri/ /index.html;
    }

    # API routes (if using Next.js)
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade `$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_cache_bypass `$http_upgrade;
        proxy_read_timeout 86400;
    }

    # Static files caching
    location /_next/static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# Subdomain configuration for user profiles
server {
    listen 80;
    server_name *.ontrail.tech;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade `$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_cache_bypass `$http_upgrade;
    }
}
"@

    $remoteCommand = @"
cat > /etc/nginx/sites-available/ontrail.tech << 'EOF'
$nginxConfig
EOF
"@
    Invoke-RemoteCommand $remoteCommand

    # Enable the site
    Invoke-RemoteCommand "ln -sf /etc/nginx/sites-available/ontrail.tech /etc/nginx/sites-enabled/"
    Invoke-RemoteCommand "nginx -t"
    Invoke-RemoteCommand "systemctl reload nginx"

    Write-Status "Nginx configuration created and enabled for ontrail.tech"
}

function New-Database {
    Write-Header "Setting up PostgreSQL Database"

    # Update package list
    Invoke-RemoteCommand "apt update"

    # Install PostgreSQL
    Invoke-RemoteCommand "apt install -y postgresql postgresql-contrib"

    # Start PostgreSQL service
    Invoke-RemoteCommand "systemctl start postgresql"
    Invoke-RemoteCommand "systemctl enable postgresql"

    # Create database and user
    $dbSetupCommand = @"
sudo -u postgres psql << 'EOF'
CREATE USER ontrail_user WITH PASSWORD 'secure_password_change_this_in_production';
CREATE DATABASE ontrail_db OWNER ontrail_user;
GRANT ALL PRIVILEGES ON DATABASE ontrail_db TO ontrail_user;
\c ontrail_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
EOF
"@

    Invoke-RemoteCommand $dbSetupCommand

    Write-Status "PostgreSQL database setup complete"
    Write-Status "Database: ontrail_db"
    Write-Status "User: ontrail_user"
    Write-Status "Password: secure_password_change_this_in_production"
}

function Invoke-GitDeployment {
    Write-Header "Deploying Ontrail Application via Git"

    # Push local changes to git first
    Write-Status "Committing and pushing local changes..."
    git add .
    git commit -m "Deploy to ontrail.tech - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>$null
    git push origin master

    # Pull changes on server (in the correct webApp directory)
    Write-Status "Pulling changes on server..."
    Invoke-RemoteCommand "cd /var/www/ontrailapp/webApp && git pull origin master"

    # Install dependencies
    Invoke-RemoteCommand "cd /var/www/ontrailapp/webApp && npm install"

    # Copy environment file if it exists locally
    if (Test-Path ".env.local") {
        Copy-ToServer ".env.local" "/var/www/ontrailapp/webApp/.env.local"
    }

    # Run database migrations
    Invoke-RemoteCommand "cd /var/www/ontrailapp/webApp && npx drizzle-kit migrate"

    # Build application
    Invoke-RemoteCommand "cd /var/www/ontrailapp/webApp && npm run build"

    # Restart PM2 process
    Invoke-RemoteCommand "pm2 restart ontrail-app"

    Write-Status "Application deployed successfully via Git!"
}

function Invoke-AppDeployment {
    Write-Header "Deploying Ontrail Application (Legacy SCP Method)"

    # Copy application files
    Write-Status "Copying application files to server..."
    Copy-ToServer "." "/var/www/ontrailapp/webApp"

    # Install dependencies
    Invoke-RemoteCommand "cd /var/www/ontrailapp/webApp && npm install"

    # Copy environment file if it exists
    if (Test-Path ".env.local") {
        Copy-ToServer ".env.local" "/var/www/ontrailapp/webApp/.env.local"
    }

    # Run database migrations
    Invoke-RemoteCommand "cd /var/www/ontrailapp/webApp && npx drizzle-kit migrate"

    # Build application
    Invoke-RemoteCommand "cd /var/www/ontrailapp/webApp && npm run build"

    # Restart PM2 process
    Invoke-RemoteCommand "pm2 restart ontrail-app"

    Write-Status "Application deployed successfully!"
}

function Start-App {
    Write-Header "Starting Application with PM2"

    # Install PM2 if not present
    Invoke-RemoteCommand "npm install -g pm2"

    # Create PM2 ecosystem file
    $pm2Config = @"
module.exports = {
  apps: [{
    name: 'ontrail-app',
    script: 'npm start',
    cwd: '$APP_DIR/webApp',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      DATABASE_URL: 'postgresql://ontrail_user:secure_password_change_this_in_production@localhost:5432/ontrail_db'
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000,
      DATABASE_URL: 'postgresql://ontrail_user:secure_password_change_this_in_production@localhost:5432/ontrail_db'
    },
    error_file: '$APP_DIR/logs/ontrail-error.log',
    out_file: '$APP_DIR/logs/ontrail-out.log',
    log_file: '$APP_DIR/logs/ontrail.log',
    merge_logs: true,
    time: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G'
  }]
};
"@

    $remoteCommand = @"
cat > $APP_DIR/ecosystem.config.js << 'EOF'
$pm2Config
EOF
"@
    Invoke-RemoteCommand $remoteCommand

    # Start the application
    Invoke-RemoteCommand "cd $APP_DIR && pm2 start ecosystem.config.js"
    Invoke-RemoteCommand "pm2 save"
    Invoke-RemoteCommand "pm2 startup"

    Write-Status "Application started with PM2!"
    Write-Status "Check status: pm2 status"
    Write-Status "View logs: pm2 logs ontrail-app"
}

function Sync-FromGit {
    Write-Header "Syncing from Git Repository"

    # Check if git repository exists and pull latest changes
    $gitCheckCommand = @"
cd $APP_DIR/webApp
if git status &>/dev/null; then
    echo "PULLING"
    git pull origin main
else
    echo "INIT"
    git init
    git remote add origin https://github.com/wagmicrew/ontrail.git
    git pull origin main
fi
"@

    $result = Invoke-RemoteCommand $gitCheckCommand
    if ($result -match "PULLING") {
        Write-Status "Pulled latest changes from git"
    } elseif ($result -match "INIT") {
        Write-Status "Initialized git repository and pulled latest changes"
    }

    Write-Status "Git sync complete!"
}

function Invoke-ArbitraryCommand {
    param([string]$Command)
    Write-Header "Running Remote Command: $Command"
    Invoke-RemoteCommand $Command
}

function Show-ServerStatus {
    Write-Header "Server Status"

    Write-Host "`nApplication Status:" -ForegroundColor $BLUE
    try {
        Invoke-RemoteCommand "pm2 status"
    } catch {
        Write-Host "PM2 not running or not accessible" -ForegroundColor $YELLOW
    }

    Write-Host "`nNginx Status:" -ForegroundColor $BLUE
    try {
        Invoke-RemoteCommand "systemctl status nginx --no-pager"
    } catch {
        Write-Host "Nginx not running or not accessible" -ForegroundColor $YELLOW
    }

    Write-Host "`nDatabase Status:" -ForegroundColor $BLUE
    try {
        Invoke-RemoteCommand "systemctl status postgresql --no-pager"
    } catch {
        Write-Host "PostgreSQL not running or not accessible" -ForegroundColor $YELLOW
    }

    Write-Host "`nDisk Usage:" -ForegroundColor $BLUE
    try {
        Invoke-RemoteCommand "df -h $APP_DIR"
    } catch {
        Write-Host "Unable to check disk usage" -ForegroundColor $YELLOW
    }
}

function New-DatabaseBackup {
    Write-Header "Creating Database Backup"

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "ontrail_backup_$timestamp.sql"

    Invoke-RemoteCommand "mkdir -p $APP_DIR/backups"
    Invoke-RemoteCommand "pg_dump -U ontrail_user -h localhost ontrail_db > $APP_DIR/backups/$backupFile"

    Write-Status "Database backup created: $APP_DIR/backups/$backupFile"
}

function Show-Help {
    Write-Host "Ontrail Deployment and Management Script (PowerShell)" -ForegroundColor $BLUE
    Write-Host ""
    Write-Host "Usage: .\ontrail-deploy.ps1 -Command <command>" -ForegroundColor $BLUE
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor $BLUE
    Write-Host "  setup-ssh       Setup SSH key for passwordless access"
    Write-Host "  setup-server    Setup server directory and permissions"
    Write-Host "  setup-nginx     Setup nginx configuration for ontrail.tech"
    Write-Host "  setup-db        Setup PostgreSQL database"
    Write-Host "  deploy          Deploy application to server"
    Write-Host "  start           Start application with PM2"
    Write-Host "  sync            Sync from git repository"
    Write-Host "  status          Show server status"
    Write-Host "  backup          Create database backup"
    Write-Host "  run <command>   Run arbitrary command on server"
    Write-Host "  full-setup      Run complete setup (ssh, server, nginx, db, deploy, start)"
    Write-Host "  help            Show this help message"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $BLUE
    Write-Host "  .\ontrail-deploy.ps1 -Command setup-ssh"
    Write-Host "  .\ontrail-deploy.ps1 -Command deploy"
    Write-Host "  .\ontrail-deploy.ps1 -Command run -RemoteCommand 'pm2 restart ontrail-app'"
    Write-Host "  .\ontrail-deploy.ps1 -Command full-setup"
}

# Main script logic
switch ($Command) {
    "setup-ssh" {
        New-SSHKey
    }
    "setup-server" {
        New-ServerDirectory
    }
    "setup-nginx" {
        New-NginxConfig
    }
    "setup-db" {
        New-Database
    }
    "deploy" {
        Invoke-GitDeployment
    }
    "deploy-scp" {
        Invoke-AppDeployment
    }
    "start" {
        Start-App
    }
    "sync" {
        Sync-FromGit
    }
    "status" {
        Show-ServerStatus
    }
    "backup" {
        New-DatabaseBackup
    }
    "run" {
        if ([string]::IsNullOrEmpty($RemoteCommand)) {
            Write-Error "Please provide a command to run"
            Write-Host "Usage: .\ontrail-deploy.ps1 -Command run -RemoteCommand '<command>'" -ForegroundColor $YELLOW
            exit 1
        }
        Invoke-ArbitraryCommand $RemoteCommand
    }
    "full-setup" {
        Write-Header "Running Complete Ontrail Setup"
        New-SSHKey
        New-ServerDirectory
        New-NginxConfig
        New-Database
        Invoke-AppDeployment
        Start-App
        Write-Status "Complete setup finished! Your Ontrail app should be running at https://ontrail.tech"
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-Help
        exit 1
    }
}

