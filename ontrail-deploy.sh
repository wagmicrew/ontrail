#!/bin/bash

# Ontrail Deployment and Management Script
# Connects to ontrail.tech server for deployment and remote management

set -e  # Exit on any error

# Configuration
SERVER_USER="root"  # Change this to your server user
SERVER_HOST="ontrail.tech"
APP_DIR="/var/www/ontrailapp"
NODE_ENV="production"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}$(printf '%.0s=' {1..50})${NC}"
}

# Function to run commands on remote server
run_remote() {
    local cmd="$1"
    print_status "Running on server: $cmd"
    ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_HOST} "$cmd"
}

# Function to copy files to server
copy_to_server() {
    local src="$1"
    local dest="$2"
    print_status "Copying $src to server:$dest"
    scp -o StrictHostKeyChecking=no -r "$src" ${SERVER_USER}@${SERVER_HOST}:"$dest"
}

# Function to setup SSH key for passwordless access
setup_ssh_key() {
    print_header "Setting up SSH Key for Passwordless Access"

    # Check if SSH key exists
    if [ ! -f ~/.ssh/id_rsa ]; then
        print_status "Generating SSH key pair..."
        ssh-keygen -t rsa -b 4096 -C "ontrail-deploy@$(hostname)" -f ~/.ssh/id_rsa -N ""
    fi

    # Copy public key to server
    print_status "Copying SSH public key to server..."
    ssh-copy-id -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_HOST}

    print_status "SSH key setup complete! You can now connect without password."
}

# Function to setup server directory structure
setup_server_directory() {
    print_header "Setting up Server Directory Structure"

    run_remote "mkdir -p $APP_DIR"
    run_remote "mkdir -p $APP_DIR/webApp"
    run_remote "mkdir -p $APP_DIR/logs"
    run_remote "mkdir -p $APP_DIR/backups"

    print_status "Server directory structure created at $APP_DIR"
}

# Function to setup nginx configuration
setup_nginx_config() {
    print_header "Setting up Nginx Configuration for ontrail.tech"

    # Create nginx configuration
    run_remote "cat > /etc/nginx/sites-available/ontrail.tech << 'EOF'
server {
    listen 80;
    server_name ontrail.tech www.ontrail.tech;

    # Security headers
    add_header X-Frame-Options \"SAMEORIGIN\" always;
    add_header X-XSS-Protection \"1; mode=block\" always;
    add_header X-Content-Type-Options \"nosniff\" always;
    add_header Referrer-Policy \"no-referrer-when-downgrade\" always;
    add_header Content-Security-Policy \"default-src 'self' http: https: data: blob: 'unsafe-inline'\" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;

    # Root directory
    root $APP_DIR/webApp;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # API routes (if using Next.js)
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 86400;
    }

    # Static files caching
    location /_next/static/ {
        expires 1y;
        add_header Cache-Control \"public, immutable\";
    }

    # Subdomain support for user profiles
    location ~ ^/([a-zA-Z0-9_-]+)$ {
        try_files /index.html =404;
    }
}

# Subdomain configuration for user profiles
server {
    listen 80;
    server_name *.ontrail.tech;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF"

    # Enable the site
    run_remote "ln -sf /etc/nginx/sites-available/ontrail.tech /etc/nginx/sites-enabled/"
    run_remote "nginx -t"
    run_remote "systemctl reload nginx"

    print_status "Nginx configuration created and enabled for ontrail.tech"
}

# Function to setup PostgreSQL database
setup_database() {
    print_header "Setting up PostgreSQL Database"

    # Install PostgreSQL if not present
    run_remote "apt update"
    run_remote "apt install -y postgresql postgresql-contrib"

    # Start PostgreSQL service
    run_remote "systemctl start postgresql"
    run_remote "systemctl enable postgresql"

    # Create database and user
    run_remote "sudo -u postgres psql << 'EOF'
CREATE USER ontrail_user WITH PASSWORD '\''secure_password_change_this_in_production'\'';
CREATE DATABASE ontrail_db OWNER ontrail_user;
GRANT ALL PRIVILEGES ON DATABASE ontrail_db TO ontrail_user;
\\c ontrail_db;
CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";
EOF"

    print_status "PostgreSQL database setup complete"
    print_status "Database: ontrail_db"
    print_status "User: ontrail_user"
    print_status "Password: secure_password_change_this_in_production"
}

# Function to deploy application
deploy_app() {
    print_header "Deploying Ontrail Application"

    # Copy application files
    print_status "Copying application files to server..."
    copy_to_server "./webapp" "$APP_DIR/webApp"

    # Install dependencies
    run_remote "cd $APP_DIR/webApp && npm install"

    # Copy environment file
    if [ -f "./webapp/.env.local" ]; then
        copy_to_server "./webapp/.env.local" "$APP_DIR/webApp/.env.local"
    fi

    # Run database migrations
    run_remote "cd $APP_DIR/webApp && npx drizzle-kit migrate"

    # Build application
    run_remote "cd $APP_DIR/webApp && npm run build"

    print_status "Application deployed successfully!"
}

# Function to start application with PM2
start_app() {
    print_header "Starting Application with PM2"

    # Install PM2 if not present
    run_remote "npm install -g pm2"

    # Create PM2 ecosystem file
    run_remote "cat > $APP_DIR/ecosystem.config.js << 'EOF'
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
EOF"

    # Start the application
    run_remote "cd $APP_DIR && pm2 start ecosystem.config.js"
    run_remote "pm2 save"
    run_remote "pm2 startup"

    print_status "Application started with PM2!"
    print_status "Check status: pm2 status"
    print_status "View logs: pm2 logs ontrail-app"
}

# Function to sync from git
sync_from_git() {
    print_header "Syncing from Git Repository"

    run_remote "cd $APP_DIR/webApp"

    # Check if git repository exists
    if run_remote "cd $APP_DIR/webApp && git status" 2>/dev/null; then
        print_status "Pulling latest changes..."
        run_remote "cd $APP_DIR/webApp && git pull origin main"
    else
        print_status "Initializing git repository..."
        run_remote "cd $APP_DIR/webApp && git init"
        run_remote "cd $APP_DIR/webApp && git remote add origin https://github.com/wagmicrew/ontrail.git"
        run_remote "cd $APP_DIR/webApp && git pull origin main"
    fi

    print_status "Git sync complete!"
}

# Function to run remote commands
run_command() {
    local cmd="$1"
    print_header "Running Remote Command: $cmd"
    run_remote "$cmd"
}

# Function to show server status
show_status() {
    print_header "Server Status"

    echo "Application Status:"
    run_remote "pm2 status" 2>/dev/null || echo "PM2 not running"

    echo -e "\nNginx Status:"
    run_remote "systemctl status nginx --no-pager" 2>/dev/null || echo "Nginx not running"

    echo -e "\nDatabase Status:"
    run_remote "systemctl status postgresql --no-pager" 2>/dev/null || echo "PostgreSQL not running"

    echo -e "\nDisk Usage:"
    run_remote "df -h $APP_DIR" 2>/dev/null || echo "Unable to check disk usage"
}

# Function to backup database
backup_database() {
    print_header "Creating Database Backup"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="ontrail_backup_$timestamp.sql"

    run_remote "mkdir -p $APP_DIR/backups"
    run_remote "pg_dump -U ontrail_user -h localhost ontrail_db > $APP_DIR/backups/$backup_file"

    print_status "Database backup created: $APP_DIR/backups/$backup_file"
}

# Function to show help
show_help() {
    echo "Ontrail Deployment and Management Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup-ssh       Setup SSH key for passwordless access"
    echo "  setup-server    Setup server directory and permissions"
    echo "  setup-nginx     Setup nginx configuration for ontrail.tech"
    echo "  setup-db        Setup PostgreSQL database"
    echo "  deploy          Deploy application to server"
    echo "  start           Start application with PM2"
    echo "  sync            Sync from git repository"
    echo "  status          Show server status"
    echo "  backup          Create database backup"
    echo "  run <command>   Run arbitrary command on server"
    echo "  full-setup      Run complete setup (ssh, server, nginx, db, deploy, start)"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup-ssh"
    echo "  $0 deploy"
    echo "  $0 run 'pm2 restart ontrail-app'"
    echo "  $0 full-setup"
}

# Main script logic
case "${1:-help}" in
    "setup-ssh")
        setup_ssh_key
        ;;
    "setup-server")
        setup_server_directory
        ;;
    "setup-nginx")
        setup_nginx_config
        ;;
    "setup-db")
        setup_database
        ;;
    "deploy")
        deploy_app
        ;;
    "start")
        start_app
        ;;
    "sync")
        sync_from_git
        ;;
    "status")
        show_status
        ;;
    "backup")
        backup_database
        ;;
    "run")
        if [ -z "$2" ]; then
            print_error "Please provide a command to run"
            echo "Usage: $0 run <command>"
            exit 1
        fi
        run_command "$2"
        ;;
    "full-setup")
        print_header "Running Complete Ontrail Setup"
        setup_ssh_key
        setup_server_directory
        setup_nginx_config
        setup_database
        deploy_app
        start_app
        print_status "Complete setup finished! Your Ontrail app should be running at https://ontrail.tech"
        ;;
    "help"|*)
        show_help
        ;;
esac

