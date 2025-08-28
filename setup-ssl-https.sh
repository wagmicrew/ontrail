#!/bin/bash

# Ontrail SSL/HTTPS Setup Script
# Sets up Let's Encrypt SSL certificate for ontrail.tech

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOMAIN="ontrail.tech"
EMAIL="admin@ontrail.tech"

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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

print_header "Setting up HTTPS/SSL for $DOMAIN"

# Update package list
print_status "Updating package list..."
apt update

# Install certbot and nginx plugin
print_status "Installing Certbot and nginx plugin..."
apt install -y certbot python3-certbot-nginx

# Check if domain resolves to this server
print_status "Checking domain resolution..."
SERVER_IP=$(curl -s ifconfig.me)
DOMAIN_IP=$(dig +short $DOMAIN)

if [[ "$DOMAIN_IP" != "$SERVER_IP" ]]; then
    print_warning "Domain $DOMAIN does not resolve to this server IP ($SERVER_IP)"
    print_warning "Current DNS resolution: $DOMAIN_IP"
    print_warning "Please update your DNS records to point $DOMAIN to $SERVER_IP"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Stop nginx temporarily for certbot standalone mode
print_status "Stopping nginx temporarily..."
systemctl stop nginx

# Obtain SSL certificate
print_status "Obtaining SSL certificate from Let's Encrypt..."
certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    -d $DOMAIN \
    -d www.$DOMAIN

# Start nginx again
print_status "Starting nginx..."
systemctl start nginx

# Update nginx configuration for SSL
print_status "Updating nginx configuration for SSL..."

# Backup current config
cp /etc/nginx/sites-available/ontrail.tech /etc/nginx/sites-available/ontrail.tech.backup

# Create SSL-enabled configuration
cat > /etc/nginx/sites-available/ontrail.tech << 'EOF'
server {
    listen 80;
    server_name ontrail.tech www.ontrail.tech;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ontrail.tech www.ontrail.tech;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/ontrail.tech/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ontrail.tech/privkey.pem;

    # SSL security settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;

    # Root directory
    root /var/www/ontrailapp/webApp;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # API routes (if using Next.js)
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }

    # Static files caching
    location /_next/static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security: Don't serve dotfiles
    location ~ /\. {
        deny all;
    }
}

# Subdomain configuration for user profiles
server {
    listen 443 ssl http2;
    server_name *.ontrail.tech;

    # SSL configuration (same as main domain)
    ssl_certificate /etc/letsencrypt/live/ontrail.tech/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ontrail.tech/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Test nginx configuration
print_status "Testing nginx configuration..."
if nginx -t; then
    print_status "Nginx configuration is valid"
else
    print_error "Nginx configuration has errors"
    # Restore backup
    cp /etc/nginx/sites-available/ontrail.tech.backup /etc/nginx/sites-available/ontrail.tech
    systemctl reload nginx
    exit 1
fi

# Reload nginx
print_status "Reloading nginx with SSL configuration..."
systemctl reload nginx

# Set up automatic certificate renewal
print_status "Setting up automatic certificate renewal..."
cat > /etc/cron.d/certbot-renew << 'EOF'
# Renew Let's Encrypt certificates every Monday at 2:30 AM
30 2 * * 1 root certbot renew --quiet && systemctl reload nginx
EOF

# Test the SSL setup
print_status "Testing SSL setup..."
sleep 2

if curl -s -I https://$DOMAIN | grep -q "HTTP/2 200"; then
    print_status "SSL setup successful! HTTPS is working."
else
    print_warning "SSL test failed. This might be normal if the application isn't running yet."
fi

# Set up firewall for HTTPS
print_status "Configuring firewall for HTTPS..."
ufw allow 443/tcp
ufw --force enable

print_header "SSL/HTTPS Setup Complete!"

echo ""
echo -e "${GREEN}✅ SSL Certificate obtained from Let's Encrypt${NC}"
echo -e "${GREEN}✅ HTTPS enabled for $DOMAIN${NC}"
echo -e "${GREEN}✅ HTTP to HTTPS redirect configured${NC}"
echo -e "${GREEN}✅ Automatic renewal scheduled${NC}"
echo -e "${GREEN}✅ Firewall configured for HTTPS${NC}"
echo ""
echo -e "${BLUE}🔗 Your site is now available at:${NC}"
echo -e "${BLUE}   https://$DOMAIN${NC}"
echo -e "${BLUE}   https://www.$DOMAIN${NC}"
echo ""
echo -e "${YELLOW}📋 Important Notes:${NC}"
echo "• HTTP traffic is automatically redirected to HTTPS"
echo "• Certificates auto-renew every Monday at 2:30 AM"
echo "• Check certificate status: certbot certificates"
echo "• Manual renewal: certbot renew"
echo ""
echo -e "${GREEN}🎉 HTTPS setup complete!${NC}"
