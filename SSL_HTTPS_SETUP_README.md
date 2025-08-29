# 🔒 SSL/HTTPS & Passwordless SSH Setup Guide

This guide explains how to set up HTTPS with Let's Encrypt SSL certificates and ensure passwordless SSH access for your Ontrail server.

## 📋 Prerequisites

- **Ubuntu Server** with root access
- **Domain**: `ontrail.tech` pointing to your server IP (`85.208.51.194`)
- **SSH Access**: Working SSH connection to server
- **Administrator Rights**: Root/sudo access on server

## 🛠️ Quick Setup (Recommended)

### Step 1: Verify SSH Passwordless Access
```powershell
cd C:\projects\ontrail
.\verify-ssh-passwordless.ps1
```

### Step 2: Set up SSL Certificate
```powershell
.\setup-ssl-certificate.ps1
```

### Step 3: Verify Everything Works
```powershell
# Test HTTPS access
curl -I https://ontrail.tech

# Test passwordless SSH
ssh root@85.208.51.194 "echo 'SSH works!'"
```

---

## 🔐 Passwordless SSH Setup

### Option 1: Automated Setup (Recommended)
```powershell
cd C:\projects\ontrail
.\verify-ssh-passwordless.ps1
```

### Option 2: Manual Setup
```powershell
# 1. Generate SSH key (if not exists)
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\id_rsa_ontrail

# 2. Copy public key to server
ssh-copy-id -i $env:USERPROFILE\.ssh\id_rsa_ontrail root@85.208.51.194

# 3. Test connection
ssh -i $env:USERPROFILE\.ssh\id_rsa_ontrail root@85.208.51.194 "echo 'Success!'"
```

### Option 3: Direct Server Setup
```bash
# On server, create authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add your public key to authorized_keys
echo "your-public-key-here" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

## 🔒 SSL/HTTPS Setup

### Automated Setup (Recommended)
```powershell
cd C:\projects\ontrail
.\setup-ssl-certificate.ps1
```

### What the SSL Setup Does

The automated script will:
- ✅ Install Certbot and nginx plugin
- ✅ Obtain SSL certificate from Let's Encrypt
- ✅ Configure nginx for HTTPS
- ✅ Set up HTTP to HTTPS redirect
- ✅ Configure automatic certificate renewal
- ✅ Update firewall for HTTPS traffic

### Manual SSL Setup

If you prefer manual setup:

```bash
# 1. Install Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# 2. Stop nginx temporarily
sudo systemctl stop nginx

# 3. Obtain certificate
sudo certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email admin@ontrail.tech \
    -d ontrail.tech \
    -d www.ontrail.tech

# 4. Start nginx
sudo systemctl start nginx

# 5. Configure nginx for SSL (see setup-ssl-https.sh for full config)
```

---

## 🔧 Configuration Files

### SSH Configuration (`$env:USERPROFILE\.ssh\config`)
```bash
# SSH Client Configuration
Host ontrail-server
    HostName 85.208.51.194
    User root
    IdentityFile ~/.ssh/id_rsa_ontrail
    IdentitiesOnly yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel QUIET

Host 85.208.51.194
    HostName 85.208.51.194
    User root
    IdentityFile ~/.ssh/id_rsa_ontrail
    IdentitiesOnly yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel QUIET
```

### Nginx SSL Configuration (`/etc/nginx/sites-available/ontrail.tech`)
```nginx
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
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:...;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Root directory
    root /var/www/ontrailapp/webApp;
    # ... rest of config
}
```

---

## 🧪 Testing Your Setup

### Test HTTPS
```bash
# Test HTTPS access
curl -I https://ontrail.tech

# Should return HTTP/2 200 or redirect from HTTP
curl -I http://ontrail.tech
```

### Test SSH Passwordless
```powershell
# Test passwordless SSH
ssh root@85.208.51.194 "echo 'SSH works without password!'"

# Test with deployment script
.\ontrail-deploy.ps1 -Command run -RemoteCommand "echo 'MCP test'"
```

### Test Certificate
```bash
# Check certificate status
ssh root@85.208.51.194 "certbot certificates"

# Test certificate expiry
ssh root@85.208.51.194 "openssl s_client -connect ontrail.tech:443 -servername ontrail.tech < /dev/null 2>/dev/null | openssl x509 -noout -dates"
```

---

## 🔄 Certificate Management

### Automatic Renewal
Certificates are set to auto-renew every Monday at 2:30 AM via cron:
```bash
# Check renewal cron job
ssh root@85.208.51.194 "crontab -l | grep certbot"
```

### Manual Renewal
```bash
# Renew certificates manually
ssh root@85.208.51.194 "certbot renew"

# Test renewal
ssh root@85.208.51.194 "certbot renew --dry-run"
```

### Certificate Information
```bash
# View certificate details
ssh root@85.208.51.194 "certbot certificates"

# Check certificate files
ssh root@85.208.51.194 "ls -la /etc/letsencrypt/live/ontrail.tech/"
```

---

## 🚨 Troubleshooting

### SSH Issues
```powershell
# Test SSH with verbose output
ssh -v -i $env:USERPROFILE\.ssh\id_rsa_ontrail root@85.208.51.194

# Check SSH key permissions
icacls $env:USERPROFILE\.ssh\id_rsa_ontrail

# Regenerate SSH key if needed
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\id_rsa_ontrail
```

### SSL Issues
```bash
# Check nginx configuration
ssh root@85.208.51.194 "nginx -t"

# Check certificate files
ssh root@85.208.51.194 "ls -la /etc/letsencrypt/live/ontrail.tech/"

# View nginx error logs
ssh root@85.208.51.194 "tail -f /var/log/nginx/error.log"
```

### DNS Issues
```bash
# Check domain resolution
nslookup ontrail.tech

# Check if domain points to correct IP
ping ontrail.tech
```

---

## 🔐 Security Best Practices

### SSH Security
- ✅ Use strong SSH keys (4096-bit RSA minimum)
- ✅ Disable password authentication
- ✅ Use non-standard SSH ports (optional)
- ✅ Configure fail2ban for brute force protection
- ✅ Regularly rotate SSH keys

### SSL Security
- ✅ Use strong SSL protocols (TLS 1.2/1.3 only)
- ✅ Configure security headers (HSTS, CSP, X-Frame-Options)
- ✅ Regular certificate renewal
- ✅ Monitor certificate expiry

### Server Security
- ✅ Keep system updated: `apt update && apt upgrade`
- ✅ Configure firewall (UFW)
- ✅ Use fail2ban for protection
- ✅ Regular security audits

---

## 📊 Monitoring & Maintenance

### Certificate Monitoring
```bash
# Certificate expiry check
ssh root@85.208.51.194 "openssl x509 -in /etc/letsencrypt/live/ontrail.tech/fullchain.pem -text -noout | grep 'Not After'"

# Certificate validation
ssh root@85.208.51.194 "certbot certificates"
```

### SSL Test Tools
```bash
# SSL Labs test
curl -s "https://www.ssllabs.com/ssltest/analyze.html?d=ontrail.tech"

# Test SSL connection
openssl s_client -connect ontrail.tech:443 -servername ontrail.tech
```

---

## 🎯 Final Verification

After setup, verify everything works:

### 1. HTTPS Access
```bash
curl -I https://ontrail.tech
# Should return: HTTP/2 200

curl -I http://ontrail.tech
# Should return: HTTP/1.1 301 (redirect to HTTPS)
```

### 2. Passwordless SSH
```powershell
ssh root@85.208.51.194 "whoami"
# Should connect without password prompt
```

### 3. Application Access
```bash
curl -I https://ontrail.tech
# Should return application response
```

---

## 🚀 Your Setup is Complete!

**Your ontrail.tech domain now has:**
- ✅ **Free SSL Certificate** from Let's Encrypt
- ✅ **Automatic HTTPS** redirect
- ✅ **Passwordless SSH** access
- ✅ **Security Headers** configured
- ✅ **Automatic Renewal** scheduled

**Access your site at:** https://ontrail.tech

**Manage your server with:**
- Cursor MCP: Natural language commands
- Deployment scripts: `.\ontrail-deploy.ps1`
- Direct SSH: `ssh root@85.208.51.194`

**🎉 Production-ready and secure!** 🔐✨

