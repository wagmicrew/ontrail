#!/bin/bash

# Ontrail Social-Fi Application - Ubuntu Server Setup Script
# This script sets up PostgreSQL database, nginx, and pm2 for the Ontrail application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
DB_NAME="ontrail_db"
DB_USER="ontrail_user"
DB_PASSWORD="secure_password_change_this_in_production"
APP_DOMAIN="ontrail.tech"
APP_PORT="3000"
NODE_ENV="production"

echo -e "${BLUE}🚀 Starting Ontrail Ubuntu Server Setup${NC}"
echo -e "${BLUE}================================================${NC}"

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

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt install -y curl wget gnupg2 software-properties-common

# Install Node.js 18 LTS
print_status "Installing Node.js 18 LTS..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL
print_status "Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

# Start and enable PostgreSQL service
print_status "Starting PostgreSQL service..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Set up PostgreSQL database and user
print_status "Setting up PostgreSQL database and user..."
sudo -u postgres psql << EOF
-- Create database user
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';

-- Create database
CREATE DATABASE $DB_NAME OWNER $DB_USER;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

-- Set up extensions
\c $DB_NAME;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
EOF

# Configure PostgreSQL for remote connections (for development)
print_status "Configuring PostgreSQL for remote connections..."
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf

# Update pg_hba.conf to allow connections from any IP (for development)
sudo bash -c "cat >> /etc/postgresql/14/main/pg_hba.conf << EOF
# Ontrail application connections
host    $DB_NAME    $DB_USER    0.0.0.0/0    md5
host    $DB_NAME    $DB_USER    ::/0         md5
EOF"

# Restart PostgreSQL to apply changes
print_status "Restarting PostgreSQL..."
sudo systemctl restart postgresql

# Install nginx
print_status "Installing nginx..."
sudo apt install -y nginx

# Create nginx configuration for Ontrail
print_status "Creating nginx configuration..."
sudo tee /etc/nginx/sites-available/ontrail << EOF
server {
    listen 80;
    server_name $APP_DOMAIN www.$APP_DOMAIN;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;

    location / {
        proxy_pass http://localhost:$APP_PORT;
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
        add_header Cache-Control "public, immutable";
    }

    # API routes
    location /api/ {
        proxy_pass http://localhost:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# Subdomain configuration for user profiles
server {
    listen 80;
    server_name *.ontrail.tech;

    location / {
        proxy_pass http://localhost:$APP_PORT;
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
EOF

# Enable the site
print_status "Enabling nginx site..."
sudo ln -s /etc/nginx/sites-available/ontrail /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Install PM2
print_status "Installing PM2..."
sudo npm install -g pm2

# Create PM2 ecosystem file
print_status "Creating PM2 ecosystem configuration..."
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'ontrail-app',
    script: 'npm start',
    cwd: '/var/www/ontrail/webApp',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: $APP_PORT,
      DATABASE_URL: 'postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME'
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: $APP_PORT,
      DATABASE_URL: 'postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME'
    },
    error_file: '/var/log/pm2/ontrail-error.log',
    out_file: '/var/log/pm2/ontrail-out.log',
    log_file: '/var/log/pm2/ontrail.log',
    merge_logs: true,
    time: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G'
  }]
};
EOF

# Create log directory for PM2
print_status "Creating PM2 log directory..."
sudo mkdir -p /var/log/pm2
sudo chown -R $USER:$USER /var/log/pm2

# Install certbot for SSL (optional)
print_status "Installing certbot for SSL certificates..."
sudo apt install -y certbot python3-certbot-nginx

# Create application directory structure
print_status "Creating application directory structure..."
sudo mkdir -p /var/www/ontrail
sudo chown -R $USER:$USER /var/www/ontrail

# Set up firewall
print_status "Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Create environment variables file template
print_status "Creating environment variables template..."
cat > /var/www/ontrail/.env.example << EOF
# Database
DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"

# NextAuth.js
NEXTAUTH_URL="https://$APP_DOMAIN"
NEXTAUTH_SECRET="your-nextauth-secret-key-change-this-in-production"

# Google OAuth
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"

# Facebook OAuth
FACEBOOK_CLIENT_ID="your-facebook-client-id"
FACEBOOK_CLIENT_SECRET="your-facebook-client-secret"

# Solana RPC
SOLANA_RPC_URL="https://api.mainnet-beta.solana.com"
SOLANA_NETWORK="mainnet-beta"

# File Upload (if using cloud storage)
CLOUDINARY_CLOUD_NAME=""
CLOUDINARY_API_KEY=""
CLOUDINARY_API_SECRET=""

# Email (for notifications)
SMTP_HOST=""
SMTP_PORT=""
SMTP_USER=""
SMTP_PASS=""

# Redis (optional - for caching)
REDIS_URL="redis://localhost:6379"
EOF

# Create database migration script
print_status "Creating database migration script..."
cat > /var/www/ontrail/migrate-db.sh << EOF
#!/bin/bash
cd /var/www/ontrail/webApp
npm run db:generate
npm run db:migrate
EOF
chmod +x /var/www/ontrail/migrate-db.sh

print_status "Setting up log rotation..."
sudo tee /etc/logrotate.d/ontrail << EOF
/var/log/pm2/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 0644 $USER $USER
    postrotate
        pm2 reloadLogs
    endscript
}
EOF

print_status "Creating backup script..."
cat > /var/www/ontrail/backup-db.sh << EOF
#!/bin/bash
BACKUP_DIR="/var/backups/ontrail"
DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="\$BACKUP_DIR/ontrail_backup_\$DATE.sql"

mkdir -p \$BACKUP_DIR

pg_dump -U $DB_USER -h localhost $DB_NAME > \$BACKUP_FILE

# Keep only last 7 backups
cd \$BACKUP_DIR
ls -t *.sql | tail -n +8 | xargs -r rm --

echo "Backup completed: \$BACKUP_FILE"
EOF
chmod +x /var/www/ontrail/backup-db.sh

# Set up cron job for daily backups
print_status "Setting up daily backup cron job..."
(crontab -l ; echo "0 2 * * * /var/www/ontrail/backup-db.sh") | crontab -

print_status "Creating deployment script..."
cat > /var/www/ontrail/deploy.sh << EOF
#!/bin/bash
cd /var/www/ontrail/webApp

# Pull latest changes
git pull origin main

# Install dependencies
npm install

# Run database migrations
npm run db:migrate

# Build application
npm run build

# Restart PM2 process
pm2 restart ecosystem.config.js

echo "Deployment completed successfully!"
EOF
chmod +x /var/www/ontrail/deploy.sh

echo ""
echo -e "${GREEN}🎉 Ubuntu server setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Copy your application code to /var/www/ontrail/webApp/"
echo "2. Update the .env file with your actual credentials"
echo "3. Run database migrations: ./migrate-db.sh"
echo "4. Start the application: pm2 start ecosystem.config.js"
echo "5. Set up SSL certificate: sudo certbot --nginx -d $APP_DOMAIN"
echo ""
echo -e "${YELLOW}Database connection details:${NC}"
echo "Host: localhost"
echo "Port: 5432"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Password: $DB_PASSWORD"
echo ""
echo -e "${YELLOW}For local development, you can connect using:${NC}"
echo "DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "- Check PM2 status: pm2 status"
echo "- View logs: pm2 logs ontrail-app"
echo "- Restart app: pm2 restart ontrail-app"
echo "- Check nginx status: sudo systemctl status nginx"
echo "- Backup database: ./backup-db.sh"
echo ""
echo -e "${GREEN}Setup complete! 🚀${NC}"
