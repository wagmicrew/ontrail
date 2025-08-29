# 🚀 Server Setup Documentation - Multi-Domain Production Environment

## 📋 Server Overview

**Server:** `85.208.51.194` (Ubuntu Linux)  
**Purpose:** Multi-domain web hosting with SSL, PM2 process management, and nginx reverse proxy  
**Domains:** 3 active domains with separate Node.js applications  
**SSL:** Let's Encrypt certificates (auto-renewal)  
**Architecture:** nginx (port 80/443) → PM2 applications (ports 3000-3001)

---

## 🌐 Domain Configuration

### **Active Domains & Routing**

| Domain | Application | PM2 Process | Port | Directory |
|--------|-------------|-------------|------|-----------|
| **dintrafikskolahlm.se** | Trafikskola Production | trafikskolax-prod | 3001 | `/var/www/dintrafikskolax_prod` |
| **dev.dintrafikskolahlm.se** | Trafikskola Development | trafikskolax-dev | 3000 | `/var/www/dintrafikskolax_dev` |
| **ontrail.tech** | Ontrail Social-Fi | ontrail-app | 3000 | `/var/www/ontrailapp/webApp` |

### **SSL Certificates**

| Domain | Certificate Path | Expiry Date | Status |
|--------|------------------|-------------|--------|
| **dintrafikskolahlm.se** | `/etc/letsencrypt/live/dintrafikskolahlm.se/` | Nov 4, 2025 | ✅ Valid |
| **dev.dintrafikskolahlm.se** | `/etc/letsencrypt/live/dev.dintrafikskolahlm.se/` | Nov 22, 2025 | ✅ Valid |
| **ontrail.tech** | `/etc/letsencrypt/live/ontrail.tech/` | Nov 26, 2025 | ✅ Valid |

---

## 🏗️ Server Architecture

### **Request Flow**
```
Internet Request → Cloudflare/Registrar → Server (85.208.51.194)
                                      ↓
                                 Nginx (Port 80/443)
                                      ↓
                        ┌─────────────┴─────────────┐
                        │                          │
                SSL Termination           HTTP → HTTPS Redirect
                        │                          │
                        ↓                          ↓
                Reverse Proxy → PM2 Applications (3000-3001)
                                      ↓
                             Node.js Applications
                                      ↓
                               Database/Redis/API
```

### **File System Structure**
```
/var/www/
├── dintrafikskolax_dev/          # Development trafikskola
│   ├── app/                      # Next.js app directory
│   ├── components/               # React components
│   ├── public/                   # Static files
│   ├── package.json              # Dependencies
│   ├── ecosystem.config.js       # PM2 config
│   └── .env.local                # Environment variables
│
├── dintrafikskolax_prod/         # Production trafikskola
│   ├── app/                      # Next.js app directory
│   ├── components/               # React components
│   ├── public/                   # Static files
│   ├── package.json              # Dependencies
│   ├── ecosystem.config.js       # PM2 config
│   ├── .next/                    # Built application
│   └── .env.local                # Environment variables
│
└── ontrailapp/                   # Ontrail application
    └── webApp/                   # Next.js application
        ├── src/                  # Source code
        ├── public/               # Static files
        ├── package.json          # Dependencies
        ├── ecosystem.config.js   # PM2 config
        └── .env.local            # Environment variables

/etc/nginx/sites-enabled/
├── dintrafikskolahlm_all.conf    # Trafikskola domains config
└── ontrail.tech                  # Ontrail domain config

/etc/letsencrypt/live/
├── dintrafikskolahlm.se/         # SSL certificates
├── dev.dintrafikskolahlm.se/     # SSL certificates
└── ontrail.tech/                 # SSL certificates
```

---

## ⚙️ PM2 Process Management

### **Current PM2 Status**
```bash
$ pm2 list

┌────┬──────────────────────┬─────────────┬─────────┬─────────┬──────────┬─────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id │ name                 │ namespace   │ version │ mode    │ pid      │ uptime  │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├────┼──────────────────────┼─────────────┼─────────┼─────────┼──────────┼─────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0  │ trafikskolax-prod    │ default     │ 15.2.4  │ cluster │ 544134   │ ~23h    │ 2260 │ online    │ 0%       │ 329.6mb  │ root     │ disabled │
│ 1  │ trafikskolax-prod    │ default     │ 15.2.4  │ cluster │ 544135   │ ~23h    │ 2259 │ online    │ 0%       │ 342.7mb  │ root     │ disabled │
│ 2  │ trafikskolax-dev     │ default     │ 15.2.4  │ fork    │ 544166   │ ~23h    │ 61   │ online    │ 0%       │ 64.7mb   │ root     │ disabled │
│ 3  │ ontrail-app          │ default     │ 0.1.0   │ cluster │ 750654   │ ~1h     │ 930  │ online    │ 0%       │ 80.3mb   │ root     │ disabled │
│ 4  │ ontrail-app          │ default     │ 0.1.0   │ cluster │ 750760   │ ~1h     │ 928  │ online    │ 0%       │ 65.0mb   │ root     │ disabled │
└────┴──────────────────────┴─────────────┴─────────┴─────────┴──────────┴─────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
```

### **PM2 Ecosystem Configuration**

#### **File:** `/var/www/dintrafikskolax_prod/ecosystem.config.js**
```javascript
module.exports = {
  apps: [
    {
      name: 'dintrafikskolax-prod',
      cwd: '/var/www/dintrafikskolax_prod',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,                    // ← PRODUCTION PORT
        NEXTAUTH_URL: 'https://dintrafikskolahlm.se',
        NEXT_PUBLIC_APP_URL: 'https://dintrafikskolahlm.se',
        DATABASE_URL: process.env.DATABASE_URL,
        // ... other environment variables
      },
      instances: 1,
      exec_mode: 'fork',
      watch: false,
      max_memory_restart: '1G',
      error_file: '/var/log/pm2/dintrafikskolax-prod-error.log',
      out_file: '/var/log/pm2/dintrafikskolax-prod-out.log',
      log_file: '/var/log/pm2/dintrafikskolax-prod-combined.log'
    }
  ]
};
```

#### **File:** `/var/www/dintrafikskolax_dev/ecosystem.config.js**
```javascript
module.exports = {
  apps: [
    {
      name: 'dintrafikskolax-dev',
      cwd: '/var/www/dintrafikskolax_dev',
      script: 'npm',
      args: 'run dev',
      env: {
        NODE_ENV: 'development',
        PORT: 3000,                    // ← DEVELOPMENT PORT
        NEXTAUTH_URL: 'https://dev.dintrafikskolahlm.se',
        NEXT_PUBLIC_APP_URL: 'https://dev.dintrafikskolahlm.se',
        // ... other environment variables
      },
      instances: 1,
      exec_mode: 'fork',
      // ... other config
    }
  ]
};
```

#### **File:** `/var/www/ontrailapp/webApp/ecosystem.config.js**
```javascript
module.exports = {
  apps: [{
    name: 'ontrail-app',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000                     // ← ONTRAIL PORT
    },
    error_file: '/var/www/ontrailapp/logs/pm2-error.log',
    out_file: '/var/www/ontrailapp/logs/pm2-out.log',
    log_file: '/var/www/ontrailapp/logs/pm2.log'
  }]
};
```

---

## 🌐 Nginx Configuration

### **Trafikskola Domains Configuration**

#### **File:** `/etc/nginx/sites-enabled/dintrafikskolahlm_all.conf**
```nginx
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
        proxy_pass http://localhost:3000;     # ← DEV APPLICATION
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300;
        proxy_connect_timeout 30;
        proxy_send_timeout 30;
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
        proxy_pass http://localhost:3001;     # ← PRODUCTION APPLICATION
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300;
        proxy_connect_timeout 30;
        proxy_send_timeout 30;
    }
}
```

### **Ontrail Domain Configuration**

#### **File:** `/etc/nginx/sites-enabled/ontrail.tech**
```nginx
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name ontrail.tech www.ontrail.tech;
    return 301 https://$server_name$request_uri;
}

# HTTPS server with SSL for ontrail.tech
server {
    listen 443 ssl http2;
    server_name ontrail.tech www.ontrail.tech;

    ssl_certificate /etc/letsencrypt/live/ontrail.tech/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ontrail.tech/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;

    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;

    root /var/www/ontrailapp/webApp;

    # API routes - proxy to ontrail-app PM2 process
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
}
```

---

## 🔧 Management Commands

### **PM2 Management**
```bash
# Check all processes
pm2 list

# View logs for specific application
pm2 logs trafikskolax-prod
pm2 logs trafikskolax-dev
pm2 logs ontrail-app

# Restart specific application
pm2 restart trafikskolax-prod
pm2 restart trafikskolax-dev
pm2 restart ontrail-app

# Check resource usage
pm2 monit

# Save current PM2 configuration
pm2 save
```

### **Nginx Management**
```bash
# Test configuration
nginx -t

# Reload configuration
systemctl reload nginx

# Restart nginx
systemctl restart nginx

# Check nginx status
systemctl status nginx

# View nginx error logs
tail -f /var/log/nginx/error.log
```

### **SSL Certificate Management**
```bash
# Check all certificates
certbot certificates

# Renew certificates
certbot renew

# Test renewal (dry run)
certbot renew --dry-run

# Certificate expiry check
openssl x509 -in /etc/letsencrypt/live/dintrafikskolahlm.se/fullchain.pem -text -noout | grep "Not After"
```

### **Application Management**
```bash
# Navigate to application directory
cd /var/www/dintrafikskolax_prod

# Install/update dependencies
npm install

# Build application
npm run build

# Start development server
npm run dev

# Start production server
npm start

# Check application health
curl http://localhost:3001/health
```

---

## 🔍 Troubleshooting Guide

### **1. Domain Returns 404**
**Problem:** Application not responding on configured port
```bash
# Check if application is running
pm2 list

# Check application logs
pm2 logs [application-name]

# Test local connection
curl http://localhost:3000/health  # For dev/ontrail
curl http://localhost:3001/health  # For production

# Check nginx configuration
nginx -t
systemctl reload nginx
```

### **2. SSL Certificate Errors**
**Problem:** Certificate expired or invalid
```bash
# Check certificate expiry
certbot certificates

# Renew certificate
certbot renew

# Force renewal
certbot renew --force-renewal
```

### **3. Port Conflicts**
**Problem:** Multiple applications trying to use same port
```bash
# Check what ports are in use
netstat -tlnp | grep :300

# Check PM2 ecosystem configuration
cat /var/www/[app]/ecosystem.config.js

# Restart with correct port
pm2 restart [application-name]
```

### **4. Database Connection Issues**
**Problem:** Application can't connect to database
```bash
# Check environment variables
cat /var/www/[app]/.env.local | grep DATABASE_URL

# Test database connection
cd /var/www/[app] && npm run db:test  # If available

# Check database logs
tail -f /var/log/postgresql/postgresql-*.log
```

### **5. High Memory Usage**
**Problem:** Application using too much memory
```bash
# Check memory usage
pm2 monit

# Restart application
pm2 restart [application-name]

# Check for memory leaks in logs
pm2 logs [application-name] --lines 50
```

### **6. HTTP/2 Protocol Errors**
**Problem:** Browser showing ERR_HTTP2_PROTOCOL_ERROR
```bash
# Fix: Remove HTTP/2 from nginx config
sed -i 's/listen 443 ssl http2;/listen 443 ssl;/g' /etc/nginx/sites-enabled/[domain].conf

# Reload nginx
systemctl reload nginx
```

---

## 🚀 Deployment Process

### **Adding New Application**
1. **Create directory structure**
   ```bash
   mkdir -p /var/www/new-app
   cd /var/www/new-app
   ```

2. **Clone/deploy application**
   ```bash
   git clone [repository] .
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env.local
   nano .env.local  # Configure environment variables
   ```

4. **Create PM2 ecosystem file**
   ```bash
   nano ecosystem.config.js
   # Configure port, environment, etc.
   ```

5. **Start application**
   ```bash
   pm2 start ecosystem.config.js
   pm2 save
   ```

6. **Configure nginx**
   ```bash
   nano /etc/nginx/sites-enabled/new-app.conf
   # Add server blocks for HTTP/HTTPS
   nginx -t && systemctl reload nginx
   ```

7. **SSL certificate**
   ```bash
   certbot --nginx -d new-app.com -d www.new-app.com
   ```

### **Updating Existing Application**
1. **Navigate to application directory**
   ```bash
   cd /var/www/[app-name]
   ```

2. **Pull latest changes**
   ```bash
   git pull origin main
   ```

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Build application**
   ```bash
   npm run build
   ```

5. **Restart PM2 process**
   ```bash
   pm2 restart [app-name]
   ```

---

## 📊 Monitoring & Logs

### **Log Locations**
```
/var/log/pm2/                           # PM2 logs
├── dintrafikskolax-prod-error.log
├── dintrafikskolax-prod-out.log
├── dintrafikskolax-dev-error.log
├── dintrafikskolax-dev-out.log
└── combined logs

/var/log/nginx/                         # Nginx logs
├── access.log
└── error.log

/var/www/[app]/logs/                   # Application logs
└── pm2.log
```

### **Health Checks**
```bash
# Application health
curl https://dintrafikskolahlm.se/health
curl https://dev.dintrafikskolahlm.se/health
curl https://ontrail.tech/health

# PM2 health
pm2 jlist | jq '.[] | {name: .name, pm2_env: {status: .pm2_env.status, restart_time: .pm2_env.restart_time}}'

# System health
df -h
free -h
uptime
```

---

## 🔐 Security Configuration

### **SSL Settings**
- **Protocols:** TLS 1.2, TLS 1.3 only
- **Ciphers:** Strong ECDHE-RSA encryption
- **HSTS:** 31,536,000 seconds (1 year)
- **Auto-renewal:** Every Monday at 2:30 AM

### **Firewall (UFW)**
```bash
# Check firewall status
ufw status

# Allow required ports
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
```

### **SSH Security**
- **Key-based authentication only**
- **Root login disabled** (use sudo)
- **SSH key path:** `%USERPROFILE%\.ssh\id_rsa_ontrail`

---

## 📈 Performance Optimization

### **Current Settings**
- **PM2 Cluster Mode:** 2 instances for production apps
- **Memory Limits:** 1GB per application
- **Auto-restart:** On crashes and high memory usage
- **Gzip Compression:** Enabled for text-based content
- **Caching:** Static assets cached for 1 year

### **Resource Usage**
```bash
# Current memory usage
pm2 list | grep -E "(mem|name)"

# Disk usage
df -h /var/www

# CPU usage
pm2 monit
```

---

## 🆘 Emergency Procedures

### **Application Down**
1. **Check PM2 status**
   ```bash
   pm2 list
   ```

2. **Check application logs**
   ```bash
   pm2 logs [app-name] --lines 50
   ```

3. **Restart application**
   ```bash
   pm2 restart [app-name]
   ```

4. **If restart fails, check system resources**
   ```bash
   free -h
   df -h
   ```

### **Server Unresponsive**
1. **Check server connectivity**
   ```bash
   ping 85.208.51.194
   ```

2. **SSH connection**
   ```bash
   ssh -i ~/.ssh/id_rsa_ontrail root@85.208.51.194
   ```

3. **Check system services**
   ```bash
   systemctl status nginx
   systemctl status pm2-root
   ```

4. **Restart services if needed**
   ```bash
   systemctl restart nginx
   pm2 restart all
   ```

---

## 📞 Support Information

### **Server Details**
- **IP Address:** 85.208.51.194
- **OS:** Ubuntu Linux
- **SSH Key:** `id_rsa_ontrail`
- **Root Access:** Yes (use with caution)

### **Domain Registrars**
- **dintrafikskolahlm.se:** [Registrar name]
- **dev.dintrafikskolahlm.se:** [Registrar name]
- **ontrail.tech:** [Registrar name]

### **Key Contacts**
- **System Administrator:** [Your name/contact]
- **Hosting Provider:** Contabo
- **SSL Provider:** Let's Encrypt

---

## ✅ Quick Reference

### **Domain → Port Mapping**
```
dintrafikskolahlm.se     → Port 3001 (trafikskolax-prod)
dev.dintrafikskolahlm.se → Port 3000 (trafikskolax-dev)
ontrail.tech             → Port 3000 (ontrail-app)
```

### **Directory Structure**
```
/var/www/dintrafikskolax_prod/    # Production trafikskola
/var/www/dintrafikskolax_dev/     # Development trafikskola
/var/www/ontrailapp/webApp/       # Ontrail application
```

### **Critical Files**
```
PM2 Config:    /var/www/[app]/ecosystem.config.js
Nginx Config:  /etc/nginx/sites-enabled/
SSL Certs:     /etc/letsencrypt/live/
Environment:   /var/www/[app]/.env.local
```

---

## 🎯 **This Documentation Ensures:**

✅ **Complete server setup reference**  
✅ **Domain-to-port mapping**  
✅ **PM2 application management**  
✅ **Nginx configuration details**  
✅ **SSL certificate management**  
✅ **Troubleshooting procedures**  
✅ **Deployment workflows**  
✅ **Emergency recovery steps**  
✅ **Performance monitoring**  
✅ **Security configurations**

**This is your complete server administration guide!** 🚀📚

---

*Last Updated: August 28, 2025*  
*Server: 85.208.51.194*  
*Domains: 3 active (dintrafikskolahlm.se, dev.dintrafikskolahlm.se, ontrail.tech)*

