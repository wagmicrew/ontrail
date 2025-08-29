# 🚀 Ontrail Deployment Guide

## Overview
This guide explains how to use the Ontrail deployment scripts to set up your ontrail.tech domain and manage deployments to your Ubuntu server.

## 📋 Prerequisites

1. **Ubuntu Server** with sudo access
2. **Domain**: `ontrail.tech` pointing to your server's IP address
3. **SSH Access**: Ability to connect to your server via SSH
4. **Git Repository**: https://github.com/wagmicrew/ontrail.git

## 🔑 SSH Key Setup

Your SSH key has been generated at: `C:\Users\johs\.ssh\id_rsa_ontrail`

**Public Key (add this to your server's `~/.ssh/authorized_keys`):**
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4vPKFB+i4IY7l8/aJXuZA2iLwVjOVC5tso1eN2Rs ontrail-deploy@HLMIT100248
```

### Adding SSH Key to Server
1. Connect to your server: `ssh root@ontrail.tech`
2. Create SSH directory: `mkdir -p ~/.ssh`
3. Add the public key: `echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4vPKFB+i4IY7l8/aJXuZA2iLwVjOVC5tso1eN2Rs ontrail-deploy@HLMIT100248" >> ~/.ssh/authorized_keys`
4. Set correct permissions: `chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh`

## 🛠️ Available Scripts

### PowerShell Script (Windows) - `ontrail-deploy.ps1`

**Location**: `C:\projects\ontrail\ontrail-deploy.ps1`

#### Basic Usage:
```powershell
# Setup SSH access
.\ontrail-deploy.ps1 -Command setup-ssh

# Complete server setup
.\ontrail-deploy.ps1 -Command full-setup

# Deploy application
.\ontrail-deploy.ps1 -Command deploy

# Check server status
.\ontrail-deploy.ps1 -Command status
```

#### Available Commands:
- `setup-ssh` - Setup SSH key for passwordless access
- `setup-server` - Create server directory structure
- `setup-nginx` - Configure nginx for ontrail.tech
- `setup-db` - Install and setup PostgreSQL database
- `deploy` - Deploy application from local machine
- `start` - Start application with PM2
- `sync` - Pull latest changes from git
- `status` - Show server status
- `backup` - Create database backup
- `run <command>` - Run arbitrary command on server
- `full-setup` - Run complete setup (recommended)

### Bash Script (Linux/Mac) - `ontrail-deploy.sh`

**Location**: `C:\projects\ontrail\ontrail-deploy.sh`

#### Basic Usage:
```bash
# Make executable
chmod +x ontrail-deploy.sh

# Complete setup
./ontrail-deploy.sh full-setup

# Deploy application
./ontrail-deploy.sh deploy

# Check status
./ontrail-deploy.sh status
```

## 🚀 Quick Start (Recommended)

### Step 1: Setup SSH Access
```powershell
.\ontrail-deploy.ps1 -Command setup-ssh
```

### Step 2: Complete Server Setup
```powershell
.\ontrail-deploy.ps1 -Command full-setup
```

This will:
- ✅ Create directory structure at `/var/www/ontrailapp/`
- ✅ Setup nginx configuration for `ontrail.tech`
- ✅ Install and configure PostgreSQL
- ✅ Deploy your application
- ✅ Start application with PM2
- ✅ Setup SSL certificate (optional)

### Step 3: Access Your Application
Once setup is complete, your application will be available at:
- **Main Site**: https://ontrail.tech
- **API**: https://ontrail.tech/api
- **User Profiles**: https://[username].ontrail.tech

## 📁 Server Directory Structure

```
/var/www/ontrailapp/
├── webApp/          # Next.js application
├── logs/           # Application logs
├── backups/        # Database backups
├── ecosystem.config.js  # PM2 configuration
└── nginx config at /etc/nginx/sites-available/ontrail.tech
```

## 🔄 Deployment Workflow

### Method 1: Direct Deployment (Recommended)
```powershell
# Deploy from your local machine
.\ontrail-deploy.ps1 -Command deploy
```

### Method 2: Git-Based Deployment
```powershell
# Push changes to git
git add .
git commit -m "Your commit message"
git push origin main

# Pull changes on server
.\ontrail-deploy.ps1 -Command sync

# Restart application
.\ontrail-deploy.ps1 -Command run -RemoteCommand "pm2 restart ontrail-app"
```

## 🛠️ Useful Commands

### Check Application Status
```powershell
.\ontrail-deploy.ps1 -Command status
```

### View Application Logs
```powershell
.\ontrail-deploy.ps1 -Command run -RemoteCommand "pm2 logs ontrail-app"
```

### Restart Application
```powershell
.\ontrail-deploy.ps1 -Command run -RemoteCommand "pm2 restart ontrail-app"
```

### Create Database Backup
```powershell
.\ontrail-deploy.ps1 -Command backup
```

### Run Custom Commands
```powershell
.\ontrail-deploy.ps1 -Command run -RemoteCommand "df -h"
.\ontrail-deploy.ps1 -Command run -RemoteCommand "systemctl status nginx"
```

## 🔧 Configuration

### Update Server Details
Edit `ontrail-config.json` to customize:
- Server user and host
- Database credentials
- Application settings
- nginx configuration

### Environment Variables
The script automatically sets up:
- `DATABASE_URL` for PostgreSQL connection
- `NODE_ENV=production`
- `PORT=3000` for the application

## 🔒 Security Notes

1. **Change Database Password**: Update the default password in production
2. **Firewall**: Ensure only necessary ports are open (22, 80, 443, 3000)
3. **SSL**: Consider setting up SSL certificates with Let's Encrypt
4. **Backups**: Regular database backups are created in `/var/www/ontrailapp/backups/`

## 🐛 Troubleshooting

### SSH Connection Issues
```powershell
# Test SSH connection
ssh root@ontrail.tech

# If connection fails, check:
# 1. Domain DNS resolution
# 2. SSH service running on server
# 3. Firewall settings
```

### Application Not Starting
```powershell
# Check PM2 status
.\ontrail-deploy.ps1 -Command run -RemoteCommand "pm2 status"

# View logs
.\ontrail-deploy.ps1 -Command run -RemoteCommand "pm2 logs ontrail-app"

# Restart application
.\ontrail-deploy.ps1 -Command run -RemoteCommand "pm2 restart ontrail-app"
```

### Database Connection Issues
```powershell
# Test database connection
.\ontrail-deploy.ps1 -Command run -RemoteCommand "psql -U ontrail_user -d ontrail_db -h localhost -c 'SELECT version();'"

# Check PostgreSQL status
.\ontrail-deploy.ps1 -Command run -RemoteCommand "systemctl status postgresql"
```

## 📞 Support

If you encounter issues:

1. Check the server logs: `pm2 logs ontrail-app`
2. Verify nginx configuration: `nginx -t`
3. Test database connectivity
4. Ensure all prerequisites are met

## 🎉 Next Steps

After successful deployment:

1. **Domain Setup**: Ensure `ontrail.tech` DNS points to your server IP
2. **SSL Certificate**: Set up HTTPS with Let's Encrypt
3. **Database Migration**: The script runs migrations automatically
4. **Testing**: Test all features of your Ontrail application
5. **Monitoring**: Set up monitoring and alerts

Your Ontrail Social-Fi application is now ready for production! 🚀


