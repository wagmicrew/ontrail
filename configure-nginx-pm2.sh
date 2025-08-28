#!/bin/bash

# Ontrail Nginx & PM2 Configuration Script
# Sets up production-ready nginx with SSL and PM2 for Node.js application

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

print_header "Configuring Nginx & PM2 for $DOMAIN"

# Install PM2 globally if not installed
print_step "Installing PM2..."
if ! command -v pm2 &> /dev/null; then
    print_status "Installing PM2..."
    npm install -g pm2
else
    print_status "PM2 is already installed"
fi

# Create PM2 ecosystem file
print_step "Creating PM2 ecosystem configuration..."
cat > /var/www/ontrailapp/webApp/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'ontrail-app',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/var/www/ontrailapp/logs/pm2-error.log',
    out_file: '/var/www/ontrailapp/logs/pm2-out.log',
    log_file: '/var/www/ontrailapp/logs/pm2.log',
    merge_logs: true,
    time: true,
    autorestart: true,
    max_memory_restart: '1G',
    watch: false,
    cwd: '/var/www/ontrailapp/webApp'
  }]
};
EOF

# Create Next.js server.js if it doesn't exist
print_step "Creating Next.js production server..."
if [ ! -f "/var/www/ontrailapp/webApp/server.js" ]; then
    cat > /var/www/ontrailapp/webApp/server.js << 'EOF'
const { createServer } = require('http')
const { parse } = require('url')
const next = require('next')

const dev = process.env.NODE_ENV !== 'production'
const hostname = 'localhost'
const port = parseInt(process.env.PORT, 10) || 3000

const app = next({ dev, hostname, port })
const handle = app.getRequestHandler()

app.prepare().then(() => {
  createServer(async (req, res) => {
    try {
      const parsedUrl = parse(req.url, true)
      const { pathname, query } = parsedUrl

      if (pathname === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' })
        res.end(JSON.stringify({
          status: 'healthy',
          timestamp: new Date().toISOString(),
          uptime: process.uptime()
        }))
        return
      }

      await handle(req, res, parsedUrl)
    } catch (err) {
      console.error('Error occurred handling', req.url, err)
      res.statusCode = 500
      res.end('Internal server error')
    }
  })
  .once('error', (err) => {
    console.error(err)
    process.exit(1)
  })
  .listen(port, (err) => {
    if (err) throw err
    console.log(`> Ready on http://${hostname}:${port}`)
  })
})
EOF
fi

# Install dependencies if needed
print_step "Installing Node.js dependencies..."
cd /var/www/ontrailapp/webApp
if [ -f "package.json" ]; then
    npm install --production
fi

# Build Next.js application
print_step "Building Next.js application..."
if [ -f "package.json" ]; then
    npm run build
fi

# Stop existing PM2 processes
print_step "Stopping existing PM2 processes..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Start application with PM2
print_step "Starting application with PM2..."
pm2 start ecosystem.config.js --env production

# Save PM2 configuration
print_step "Saving PM2 configuration..."
pm2 save

# Create PM2 startup script
print_step "Creating PM2 startup script..."
pm2 startup
pm2 startup systemd -u root --hp /root

# Create comprehensive nginx configuration
print_step "Creating nginx configuration for SSL and PM2..."
cat > /etc/nginx/sites-available/ontrail.tech << 'EOF'
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name ontrail.tech www.ontrail.tech;
    return 301 https://$server_name$request_uri;
}

# HTTPS server with SSL
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

    # SSL session cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

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

    # API routes - proxy to Node.js
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
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
    }

    # Next.js _next static files with caching
    location /_next/static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Frame-Options "SAMEORIGIN";
        proxy_pass http://localhost:3000;
    }

    # Static files
    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Frame-Options "SAMEORIGIN";
        try_files $uri @proxy;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3000;
        access_log off;
    }

    # Main application routes
    location / {
        try_files $uri $uri/ /index.html;
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

    # Security: Don't serve dotfiles
    location ~ /\. {
        deny all;
    }

    # Error pages
    error_page 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
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

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

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
print_step "Testing nginx configuration..."
if nginx -t; then
    print_status "Nginx configuration is valid"
else
    print_error "Nginx configuration has errors"
    exit 1
fi

# Reload nginx
print_step "Reloading nginx with new configuration..."
systemctl reload nginx

# Create logs directory
print_step "Creating logs directory..."
mkdir -p /var/www/ontrailapp/logs

# Set proper permissions
print_step "Setting proper permissions..."
chown -R www-data:www-data /var/www/ontrailapp/webApp
chmod -R 755 /var/www/ontrailapp/webApp

# Create logrotate configuration for PM2 logs
print_step "Setting up log rotation..."
cat > /etc/logrotate.d/pm2-root << 'EOF'
/var/www/ontrailapp/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        pm2 reloadLogs
    endscript
}
EOF

# Create monitoring script
print_step "Creating monitoring script..."
cat > /usr/local/bin/ontrail-monitor.sh << 'EOF'
#!/bin/bash
# Ontrail Application Monitoring Script

LOG_FILE="/var/www/ontrailapp/logs/monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] === Ontrail Application Monitor ===" >> $LOG_FILE

# Check PM2 status
echo "[$TIMESTAMP] PM2 Status:" >> $LOG_FILE
pm2 jlist >> $LOG_FILE 2>&1

# Check nginx status
echo "[$TIMESTAMP] Nginx Status:" >> $LOG_FILE
systemctl is-active nginx >> $LOG_FILE 2>&1

# Check application health
echo "[$TIMESTAMP] Application Health:" >> $LOG_FILE
curl -s -f http://localhost:3000/health >> $LOG_FILE 2>&1
if [ $? -eq 0 ]; then
    echo "[$TIMESTAMP] Health check: PASSED" >> $LOG_FILE
else
    echo "[$TIMESTAMP] Health check: FAILED" >> $LOG_FILE
fi

# Check SSL certificate expiry
echo "[$TIMESTAMP] SSL Certificate:" >> $LOG_FILE
openssl x509 -in /etc/letsencrypt/live/ontrail.tech/fullchain.pem -text -noout | grep "Not After" >> $LOG_FILE 2>&1

echo "[$TIMESTAMP] === Monitor Complete ===" >> $LOG_FILE
echo "" >> $LOG_FILE
EOF

chmod +x /usr/local/bin/ontrail-monitor.sh

# Set up monitoring cron job
print_step "Setting up monitoring cron job..."
cat > /etc/cron.d/ontrail-monitor << 'EOF'
# Ontrail monitoring every 5 minutes
*/5 * * * * root /usr/local/bin/ontrail-monitor.sh
EOF

# Create status check script
print_step "Creating status check script..."
cat > /usr/local/bin/ontrail-status.sh << 'EOF'
#!/bin/bash
# Ontrail Application Status Check

echo "=== Ontrail Application Status ==="
echo ""

echo "🔧 PM2 Status:"
pm2 status
echo ""

echo "🌐 Nginx Status:"
systemctl status nginx --no-pager -l
echo ""

echo "🔒 SSL Certificate Info:"
openssl x509 -in /etc/letsencrypt/live/ontrail.tech/fullchain.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
echo ""

echo "📊 Application Health:"
curl -s http://localhost:3000/health | jq '.' 2>/dev/null || curl -s http://localhost:3000/health
echo ""

echo "📈 System Resources:"
echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
echo ""

echo "🔄 Recent Logs:"
echo "--- PM2 Logs (last 10 lines) ---"
tail -10 /var/www/ontrailapp/logs/pm2.log 2>/dev/null || echo "No PM2 logs found"
echo ""

echo "🚀 Application is running on:"
echo "  • HTTP:  http://localhost:3000"
echo "  • HTTPS: https://ontrail.tech"
echo "  • Health: https://ontrail.tech/health"
EOF

chmod +x /usr/local/bin/ontrail-status.sh

print_header "Configuration Complete!"

echo ""
echo -e "${GREEN}✅ Nginx configured with SSL and PM2 proxy${NC}"
echo -e "${GREEN}✅ PM2 application started in cluster mode${NC}"
echo -e "${GREEN}✅ Automatic startup configured${NC}"
echo -e "${GREEN}✅ Log rotation configured${NC}"
echo -e "${GREEN}✅ Monitoring system set up${NC}"
echo ""
echo -e "${BLUE}🔗 Your application is available at:${NC}"
echo -e "${BLUE}   HTTPS: https://ontrail.tech${NC}"
echo -e "${BLUE}   Health: https://ontrail.tech/health${NC}"
echo ""
echo -e "${YELLOW}📋 Management Commands:${NC}"
echo "• Check status: ontrail-status.sh"
echo "• View logs: pm2 logs"
echo "• Restart app: pm2 restart ontrail-app"
echo "• Monitor: tail -f /var/www/ontrailapp/logs/monitor.log"
echo ""
echo -e "${GREEN}🎉 Production setup complete!${NC}"

# Test the configuration
print_step "Testing configuration..."
sleep 3

if curl -s -I https://$DOMAIN | grep -q "HTTP/2 200"; then
    print_status "✅ HTTPS configuration working!"
else
    print_warning "⚠️  HTTPS test failed - application may not be ready yet"
fi

if curl -s http://localhost:3000/health > /dev/null; then
    print_status "✅ Application health check passed!"
else
    print_warning "⚠️  Application health check failed - check PM2 logs"
fi

echo ""
echo -e "${GREEN}🎊 All systems configured and ready!${NC}"
