#!/bin/bash
# Final HTTP/2 Protocol Error Fix

echo "🔧 Final HTTP/2 Protocol Error Fix"
echo "=================================="

# Check current nginx status
echo "1. Checking nginx status..."
systemctl status nginx --no-pager

# Check current configuration
echo -e "\n2. Checking current nginx sites..."
ls -la /etc/nginx/sites-enabled/

# Check certificates
echo -e "\n3. Checking SSL certificates..."
certbot certificates

# Test local connections
echo -e "\n4. Testing local connections..."
curl -I --max-time 5 http://localhost:3000/ 2>/dev/null | head -3 || echo "Port 3000: FAILED"
curl -I --max-time 5 http://localhost:3001/ 2>/dev/null | head -3 || echo "Port 3001: FAILED"
curl -I --max-time 5 http://localhost:3002/ 2>/dev/null | head -3 || echo "Port 3002: FAILED"

# Backup current config
echo -e "\n5. Backing up current configuration..."
cp /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Create completely new configuration without HTTP/2
echo -e "\n6. Creating new HTTP/1.1 only configuration..."

cat > /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf << 'EOF'
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name dintrafikskolahlm.se www.dintrafikskolahlm.se dev.dintrafikskolahlm.se;
    return 301 https://$host$request_uri;
}

# HTTPS server for dev.dintrafikskolahlm.se (HTTP/1.1 only)
server {
    listen 443 ssl;
    server_name dev.dintrafikskolahlm.se;

    ssl_certificate /etc/letsencrypt/live/dev.dintrafikskolahlm.se/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dev.dintrafikskolahlm.se/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    client_max_body_size 50m;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300;
        proxy_connect_timeout 30;
        proxy_send_timeout 30;
    }

    # Error page
    error_page 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}

# HTTPS server for dintrafikskolahlm.se (HTTP/1.1 only)
server {
    listen 443 ssl;
    server_name dintrafikskolahlm.se www.dintrafikskolahlm.se;

    ssl_certificate /etc/letsencrypt/live/dintrafikskolahlm.se/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dintrafikskolahlm.se/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    client_max_body_size 50m;

    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300;
        proxy_connect_timeout 30;
        proxy_send_timeout 30;
    }

    # Error page
    error_page 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF

echo "✅ New configuration created"

# Test configuration
echo -e "\n7. Testing nginx configuration..."
if nginx -t 2>&1; then
    echo "✅ Configuration is valid"
else
    echo "❌ Configuration has errors"
    exit 1
fi

# Reload nginx
echo -e "\n8. Reloading nginx..."
if systemctl reload nginx; then
    echo "✅ Nginx reloaded successfully"
else
    echo "❌ Nginx reload failed"
    exit 1
fi

# Test the configuration
echo -e "\n9. Testing the fix..."
sleep 2

echo "Testing dintrafikskolahlm.se..."
curl -I --max-time 10 https://dintrafikskolahlm.se 2>/dev/null | head -3 || echo "❌ dintrafikskolahlm.se failed"

echo "Testing dev.dintrafikskolahlm.se..."
curl -I --max-time 10 https://dev.dintrafikskolahlm.se 2>/dev/null | head -3 || echo "❌ dev.dintrafikskolahlm.se failed"

echo "Testing ontrail.tech..."
curl -I --max-time 10 https://ontrail.tech 2>/dev/null | head -3 || echo "❌ ontrail.tech failed"

echo -e "\n🎉 HTTP/2 Protocol Error Fix Complete!"
echo ""
echo "Try accessing the sites now:"
echo "  https://dintrafikskolahlm.se"
echo "  https://dev.dintrafikskolahlm.se"
echo "  https://ontrail.tech"
echo ""
echo "If still having issues:"
echo "1. Clear browser cache (Ctrl+Shift+R)"
echo "2. Try incognito mode"
echo "3. Try different browser"
echo "4. Try from different network"
