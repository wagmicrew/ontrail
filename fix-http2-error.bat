@echo off
echo Fixing HTTP/2 Protocol Error for dintrafikskolahlm.se...
echo ====================================================

REM Test SSH connection
echo Testing SSH connection...
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@85.208.51.194 "echo 'SSH OK'" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo SSH connection successful
) else (
    echo SSH connection failed
    exit /b 1
)

REM Create diagnostic script on server
echo Creating diagnostic script...
(
echo #!/bin/bash
echo echo "=== HTTP/2 Protocol Error Diagnosis ==="
echo echo ""
echo echo "Checking nginx status..."
echo systemctl status nginx --no-pager -l ^| head -10
echo echo ""
echo echo "Checking nginx configuration..."
echo nginx -t 2^>^&1
echo echo ""
echo echo "Checking SSL certificates..."
echo certbot certificates
echo echo ""
echo echo "Checking nginx sites..."
echo ls -la /etc/nginx/sites-enabled/
echo echo ""
echo echo "Testing local connections..."
echo curl -I --max-time 5 http://localhost:3000/ 2^>/dev/null ^| head -5 ^|^| echo "Port 3000: FAILED"
echo curl -I --max-time 5 http://localhost:3001/ 2^>/dev/null ^| head -5 ^|^| echo "Port 3001: FAILED"
echo curl -I --max-time 5 http://localhost:3002/ 2^>/dev/null ^| head -5 ^|^| echo "Port 3002: FAILED"
echo echo ""
echo echo "=== Diagnosis Complete ==="
) > temp_diagnose.sh

REM Upload and run diagnostic script
echo Uploading diagnostic script...
scp -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no temp_diagnose.sh root@85.208.51.194:/tmp/diagnose.sh >nul 2>&1
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "chmod +x /tmp/diagnose.sh && /tmp/diagnose.sh"

REM Create fix script
echo Creating fix script...
(
echo #!/bin/bash
echo echo "Applying HTTP/2 Protocol Error Fixes..."
echo echo ""
echo # Backup original config
echo cp /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf.backup 2^>/dev/null ^|^| true
echo echo "Creating HTTP/1.1 only configuration..."
echo # Create HTTP/1.1 configuration
echo cat ^> /etc/nginx/sites-enabled/dintrafikskolahlm_all_http1.conf ^<^< 'EOF'
echo # HTTP to HTTPS redirect
echo server {
echo     listen 80;
echo     server_name dintrafikskolahlm.se www.dintrafikskolahlm.se dev.dintrafikskolahlm.se;
echo     return 301 https://$host$request_uri;
echo }
echo # HTTPS server for dev.dintrafikskolahlm.se
echo server {
echo     listen 443 ssl;
echo     server_name dev.dintrafikskolahlm.se;
echo     ssl_certificate /etc/letsencrypt/live/dev.dintrafikskolahlm.se/fullchain.pem;
echo     ssl_certificate_key /etc/letsencrypt/live/dev.dintrafikskolahlm.se/privkey.pem;
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
echo     ssl_prefer_server_ciphers off;
echo     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
echo     client_max_body_size 50m;
echo     location / {
echo         proxy_pass http://localhost:3001;
echo         proxy_http_version 1.1;
echo         proxy_set_header Upgrade $http_upgrade;
echo         proxy_set_header Connection 'upgrade';
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo         proxy_cache_bypass $http_upgrade;
echo         proxy_read_timeout 86400;
echo         proxy_connect_timeout 30s;
echo         proxy_send_timeout 30s;
echo     }
echo }
echo # HTTPS server for dintrafikskolahlm.se
echo server {
echo     listen 443 ssl;
echo     server_name dintrafikskolahlm.se www.dintrafikskolahlm.se;
echo     ssl_certificate /etc/letsencrypt/live/dintrafikskolahlm.se/fullchain.pem;
echo     ssl_certificate_key /etc/letsencrypt/live/dintrafikskolahlm.se/privkey.pem;
echo     ssl_protocols TLSv1.2 TLSv1.3;
echo     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
echo     ssl_prefer_server_ciphers off;
echo     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
echo     client_max_body_size 50m;
echo     location / {
echo         proxy_pass http://localhost:3002;
echo         proxy_http_version 1.1;
echo         proxy_set_header Upgrade $http_upgrade;
echo         proxy_set_header Connection 'upgrade';
echo         proxy_set_header Host $host;
echo         proxy_set_header X-Real-IP $remote_addr;
echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo         proxy_set_header X-Forwarded-Proto $scheme;
echo         proxy_cache_bypass $http_upgrade;
echo         proxy_read_timeout 86400;
echo         proxy_connect_timeout 30s;
echo         proxy_send_timeout 30s;
echo     }
echo }
echo EOF
echo # Replace problematic config
echo mv /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf.disabled 2^>/dev/null ^|^| true
echo mv /etc/nginx/sites-enabled/dintrafikskolahlm_all_http1.conf /etc/nginx/sites-enabled/dintrafikskolahlm_all.conf
echo echo "HTTP/1.1 configuration created"
echo # Test and reload nginx
echo nginx -t ^&^& systemctl reload nginx
echo if [ $? -eq 0 ]; then
echo     echo "Nginx reloaded successfully"
echo     echo "Testing connections..."
echo     curl -I --max-time 10 https://dintrafikskolahlm.se 2^>/dev/null ^| head -3 ^|^| echo "dintrafikskolahlm.se: FAILED"
echo     curl -I --max-time 10 https://dev.dintrafikskolahlm.se 2^>/dev/null ^| head -3 ^|^| echo "dev.dintrafikskolahlm.se: FAILED"
echo else
echo     echo "Nginx reload failed"
echo fi
) > temp_fix.sh

REM Upload and run fix script
echo Uploading fix script...
scp -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no temp_fix.sh root@85.208.51.194:/tmp/fix.sh >nul 2>&1
ssh -i "%USERPROFILE%\.ssh\id_rsa_ontrail" -o StrictHostKeyChecking=no root@85.208.51.194 "chmod +x /tmp/fix.sh && /tmp/fix.sh"

REM Clean up temp files
del temp_diagnose.sh temp_fix.sh >nul 2>&1

echo.
echo HTTP/2 Protocol Error Fix Complete!
echo.
echo The issue should now be resolved. Try accessing:
echo https://dintrafikskolahlm.se
echo https://dev.dintrafikskolahlm.se
echo.
echo If you still have issues, the original HTTP/2 config is backed up as:
echo dintrafikskolahlm_all.conf.disabled

