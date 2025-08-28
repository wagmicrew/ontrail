# Diagnose and Fix HTTP/2 Protocol Error
# Script to identify and resolve ERR_HTTP2_PROTOCOL_ERROR

param(
    [string]$ServerHost = "85.208.51.194",
    [string]$ServerUser = "root",
    [string]$SSHKeyPath = "$env:USERPROFILE\.ssh\id_rsa_ontrail"
)

Write-Host "🔍 Diagnosing HTTP/2 Protocol Error..." -ForegroundColor Blue
Write-Host "======================================" -ForegroundColor Blue

# Test SSH connection
Write-Host "1. Testing SSH connection..." -ForegroundColor Yellow
try {
    $testResult = ssh -i $SSHKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$ServerUser@$ServerHost" "echo 'SSH OK'" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ SSH connection successful" -ForegroundColor Green
    } else {
        Write-Host "   ❌ SSH connection failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ SSH connection error: $_" -ForegroundColor Red
    exit 1
}

# Create diagnostic script
$diagnosticScript = @"
#!/bin/bash
echo "=== HTTP/2 Protocol Error Diagnosis ==="
echo ""

echo "🔍 Checking nginx status..."
systemctl status nginx --no-pager -l | head -10
echo ""

echo "🔍 Checking nginx configuration..."
nginx -t 2>&1
echo ""

echo "🔍 Checking SSL certificates..."
certbot certificates
echo ""

echo "🔍 Checking nginx sites configuration..."
ls -la /etc/nginx/sites-enabled/
echo ""

echo "🔍 Testing local connections..."
curl -I --max-time 5 http://localhost:3000/ 2>/dev/null | head -5 || echo "Port 3000: FAILED"
curl -I --max-time 5 http://localhost:3001/ 2>/dev/null | head -5 || echo "Port 3001: FAILED"  
curl -I --max-time 5 http://localhost:3002/ 2>/dev/null | head -5 || echo "Port 3002: FAILED"
echo ""

echo "🔍 Testing SSL connections locally..."
curl -I --max-time 5 https://localhost/ 2>/dev/null | head -5 || echo "SSL localhost: FAILED"
echo ""

echo "🔍 Checking firewall status..."
ufw status | head -10
echo ""

echo "=== Diagnosis Complete ==="
"@

# Upload and run diagnostic script
Write-Host "`n2. Running diagnostic script..." -ForegroundColor Yellow
try {
    # Create diagnostic script on server
    ssh -i $SSHKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" "cat > /tmp/diagnose_http2.sh << 'EOF'
$diagnosticScript
EOF"

    # Make it executable and run it
    ssh -i $SSHKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" "chmod +x /tmp/diagnose_http2.sh && /tmp/diagnose_http2.sh"
} catch {
    Write-Host "   ❌ Diagnostic script failed: $_" -ForegroundColor Red
    exit 1
}

# Create fix script for HTTP/2 issues
Write-Host "`n3. Creating HTTP/2 fix script..." -ForegroundColor Yellow

$fixScript = @"
#!/bin/bash
echo "🔧 Applying HTTP/2 Protocol Error Fixes..."
echo ""

# Fix 1: Disable HTTP/2 temporarily to test
echo "Fix 1: Creating HTTP/1.1 only configuration..."
cp /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf.backup 2>/dev/null || true

# Create a temporary HTTP/1.1 only configuration
cat > /etc/nginx/sites-enabled/dintrafikskolahlm_all_http1.conf << 'EOF'
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
}
EOF

# Backup and replace the problematic configuration
mv /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf.disabled 2>/dev/null || true
mv /etc/nginx/sites-enabled/dintrafikskolahlm_all_http1.conf /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf

echo "✅ HTTP/1.1 configuration created"
echo ""

# Fix 2: Test nginx configuration
echo "Fix 2: Testing nginx configuration..."
if nginx -t; then
    echo "✅ Nginx configuration is valid"
else
    echo "❌ Nginx configuration has errors"
    exit 1
fi

# Fix 3: Reload nginx
echo "Fix 3: Reloading nginx..."
systemctl reload nginx

if [ $? -eq 0 ]; then
    echo "✅ Nginx reloaded successfully"
else
    echo "❌ Nginx reload failed"
    exit 1
fi

echo ""
echo "🔍 Testing fixes..."
sleep 2

# Test the fixes
echo "Testing dintrafikskolahlm.se..."
curl -I --max-time 10 https://dintrafikskolahlm.se 2>/dev/null | head -3 || echo "❌ dintrafikskolahlm.se failed"

echo "Testing dev.dintrafikskolahlm.se..."
curl -I --max-time 10 https://dev.dintrafikskolahlm.se 2>/dev/null | head -3 || echo "❌ dev.dintrafikskolahlm.se failed"

echo ""
echo "🎉 HTTP/2 Protocol Error Fixes Applied!"
echo ""
echo "If this resolves the issue, you can:"
echo "1. Keep using HTTP/1.1 configuration (recommended for now)"
echo "2. Or re-enable HTTP/2 with: mv /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf.disabled /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf"
echo "3. Then reload nginx: systemctl reload nginx"
"@

# Upload and run fix script
Write-Host "`n4. Applying HTTP/2 fixes..." -ForegroundColor Yellow
try {
    # Create fix script on server
    ssh -i $SSHKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" "cat > /tmp/fix_http2.sh << 'EOF'
$fixScript
EOF"

    # Make it executable and run it
    ssh -i $SSHKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerHost" "chmod +x /tmp/fix_http2.sh && /tmp/fix_http2.sh"
} catch {
    Write-Host "   ❌ Fix script failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 HTTP/2 Protocol Error Diagnosis and Fix Complete!" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "The HTTP/2 protocol error should now be resolved." -ForegroundColor Cyan
Write-Host "Try accessing https://dintrafikskolahlm.se again." -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "If you still have issues, the fix script created backups:" -ForegroundColor Yellow
Write-Host "• Original config: dintrafikskolahlm_all.conf.disabled" -ForegroundColor White
Write-Host "• HTTP/1.1 config: dintrafikskolahlm_all.conf (current)" -ForegroundColor White
