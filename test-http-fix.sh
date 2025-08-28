#!/bin/bash
# Test HTTP/2 Fix Results

echo "🔍 Testing HTTP/2 Fix Results" > /tmp/test-results.txt
echo "================================" >> /tmp/test-results.txt

# Test nginx configuration
echo "" >> /tmp/test-results.txt
echo "1. Nginx Configuration Status:" >> /tmp/test-results.txt
nginx -t >> /tmp/test-results.txt 2>&1

# Test nginx service
echo "" >> /tmp/test-results.txt
echo "2. Nginx Service Status:" >> /tmp/test-results.txt
systemctl status nginx --no-pager >> /tmp/test-results.txt 2>&1

# Test SSL certificates
echo "" >> /tmp/test-results.txt
echo "3. SSL Certificates:" >> /tmp/test-results.txt
certbot certificates >> /tmp/test-results.txt 2>&1

# Test local applications
echo "" >> /tmp/test-results.txt
echo "4. Local Applications:" >> /tmp/test-results.txt
curl -I --max-time 5 http://localhost:3000/ 2>/dev/null | head -3 >> /tmp/test-results.txt || echo "Port 3000: FAILED" >> /tmp/test-results.txt
curl -I --max-time 5 http://localhost:3001/ 2>/dev/null | head -3 >> /tmp/test-results.txt || echo "Port 3001: FAILED" >> /tmp/test-results.txt
curl -I --max-time 5 http://localhost:3002/ 2>/dev/null | head -3 >> /tmp/test-results.txt || echo "Port 3002: FAILED" >> /tmp/test-results.txt

# Test HTTPS connections
echo "" >> /tmp/test-results.txt
echo "5. HTTPS Tests:" >> /tmp/test-results.txt
echo "Testing dintrafikskolahlm.se..." >> /tmp/test-results.txt
curl -I --max-time 10 https://dintrafikskolahlm.se 2>/dev/null | head -5 >> /tmp/test-results.txt || echo "❌ dintrafikskolahlm.se FAILED" >> /tmp/test-results.txt

echo "Testing dev.dintrafikskolahlm.se..." >> /tmp/test-results.txt
curl -I --max-time 10 https://dev.dintrafikskolahlm.se 2>/dev/null | head -5 >> /tmp/test-results.txt || echo "❌ dev.dintrafikskolahlm.se FAILED" >> /tmp/test-results.txt

echo "Testing ontrail.tech..." >> /tmp/test-results.txt
curl -I --max-time 10 https://ontrail.tech 2>/dev/null | head -5 >> /tmp/test-results.txt || echo "❌ ontrail.tech FAILED" >> /tmp/test-results.txt

# Check nginx configuration
echo "" >> /tmp/test-results.txt
echo "6. Nginx Sites Configuration:" >> /tmp/test-results.txt
ls -la /etc/nginx/sites-enabled/ >> /tmp/test-results.txt 2>&1

echo "" >> /tmp/test-results.txt
echo "7. PM2 Status:" >> /tmp/test-results.txt
pm2 list >> /tmp/test-results.txt 2>&1

echo "" >> /tmp/test-results.txt
echo "🎯 TEST COMPLETE - Check /tmp/test-results.txt" >> /tmp/test-results.txt

echo "✅ Test script completed. Results saved to /tmp/test-results.txt"
