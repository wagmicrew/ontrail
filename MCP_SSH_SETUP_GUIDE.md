# 🚀 SSH MCP Server Setup Guide for Ontrail

## Overview

This guide explains how to set up a Model Context Protocol (MCP) server that allows Cursor IDE to remotely manage your Ubuntu server via SSH. This enables seamless server management directly from your development environment.

## 📋 Prerequisites

- **Cursor IDE** installed on your local machine
- **Node.js 18+** installed
- **SSH access** to your Ubuntu server (`ontrail.tech`)
- **SSH key** configured for passwordless authentication
- **Server setup** completed (nginx, PostgreSQL, PM2)

## 🛠️ Quick Setup (Windows)

### Step 1: Run the Setup Script
```powershell
# Navigate to your project directory
cd C:\projects\ontrail

# Run the setup script
.\setup-mcp-ssh.ps1
```

### Step 2: Restart Cursor
Restart your Cursor IDE to load the new MCP server.

### Step 3: Test the Connection
In Cursor, try asking:
- "Check the server status"
- "Show me the running processes on the server"
- "Execute 'pm2 status' on the remote server"

## 🛠️ Manual Setup (Alternative)

### Step 1: Install MCP SDK
```powershell
npm install -g @modelcontextprotocol/sdk
```

### Step 2: Create MCP Directory
```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.cursor-mcp" -Force
```

### Step 3: Copy MCP Server Files
Copy the following files to `C:\Users\johs\.cursor-mcp\`:
- `mcp-server-ssh.js`
- `mcp-server-ssh-package.json` (rename to `package.json`)

### Step 4: Install Dependencies
```powershell
cd "$env:USERPROFILE\.cursor-mcp"
npm install
```

### Step 5: Update MCP Configuration
The setup script automatically updates your `.cursor\mcp.json` file. If doing manual setup, ensure it contains:

```json
{
  "ssh-remote-manager": {
    "command": "node",
    "args": ["C:\\Users\\johs\\.cursor-mcp\\mcp-server-ssh.js"],
    "env": {
      "SSH_HOST": "ontrail.tech",
      "SSH_USER": "root",
      "SSH_KEY_PATH": "C:\\Users\\johs\\.ssh\\id_rsa_ontrail"
    }
  }
}
```

## 🔧 Available Tools

Once set up, you can use these commands in Cursor:

### Server Management
- **"Execute [command] on the server"**
  - Example: "Execute 'pm2 status' on the server"
  - Example: "Execute 'systemctl status nginx' on the server"

- **"Check server status"**
  - Shows system uptime, disk usage, memory, and service status

- **"List files in [directory]"**
  - Example: "List files in /var/www/ontrailapp"

### File Operations
- **"Read file [path]"**
  - Example: "Read file /var/log/nginx/error.log"

- **"Write to file [path] content [content]"**
  - Example: "Write to file /tmp/test.txt content 'Hello World'"

### Deployment Operations
- **"Sync latest changes from git"**
  - Pulls latest changes from your git repository

- **"Restart the application"**
  - Restarts the PM2 application

- **"Show application logs"**
  - Displays recent PM2 application logs

- **"Create database backup"**
  - Creates a PostgreSQL database backup

### Database Operations
- **"Check database status"**
  - Shows PostgreSQL version and status

- **"Run database migrations"**
  - Executes Drizzle migrations

- **"Create database backup"**
  - Creates a database backup

- **"Execute SQL query [query]"**
  - Example: "Execute SQL query 'SELECT * FROM users LIMIT 5;'"

## 💡 Usage Examples

### Daily Operations
```cursor
"Check if the server is running properly"
"Show me the current PM2 processes"
"Execute 'df -h' to check disk usage"
"Read the nginx error log"
```

### Deployment Workflow
```cursor
"Sync the latest code changes from git"
"Restart the ontrail application"
"Check if the deployment was successful"
"Show the application logs"
```

### Troubleshooting
```cursor
"Check nginx configuration for errors"
"Show PostgreSQL logs"
"Execute 'netstat -tlnp' to see listening ports"
"Check system resource usage"
```

## 🔧 Configuration Options

### Environment Variables
You can customize the server connection by modifying the environment variables in `.cursor\mcp.json`:

```json
{
  "ssh-remote-manager": {
    "command": "node",
    "args": ["path/to/mcp-server-ssh.js"],
    "env": {
      "SSH_HOST": "your-server.com",           // Server hostname/IP
      "SSH_USER": "ubuntu",                    // SSH username
      "SSH_KEY_PATH": "/path/to/ssh/key",     // Path to SSH private key
      "SSH_PORT": "22"                        // SSH port (optional)
    }
  }
}
```

### Multiple Servers
You can configure multiple servers by adding additional entries:

```json
{
  "ssh-remote-manager": { ... },
  "production-server": {
    "command": "node",
    "args": ["path/to/mcp-server-ssh.js"],
    "env": {
      "SSH_HOST": "prod.ontrail.tech",
      "SSH_USER": "root"
    }
  },
  "staging-server": {
    "command": "node",
    "args": ["path/to/mcp-server-ssh.js"],
    "env": {
      "SSH_HOST": "staging.ontrail.tech",
      "SSH_USER": "ubuntu"
    }
  }
}
```

## 🔒 Security Best Practices

1. **SSH Key Security**
   - Use strong SSH keys (4096-bit RSA or Ed25519)
   - Protect your private key with a passphrase
   - Never share your private key

2. **Server Access**
   - Use non-standard SSH ports when possible
   - Configure fail2ban for brute force protection
   - Regularly rotate SSH keys

3. **Firewall Configuration**
   - Only allow SSH from trusted IP addresses
   - Use UFW or firewalld for access control

## 🐛 Troubleshooting

### Connection Issues
```powershell
# Test SSH connection manually
ssh -i ~/.ssh/id_rsa_ontrail root@ontrail.tech "echo 'Connection successful'"

# Check SSH key permissions
icacls C:\Users\johs\.ssh\id_rsa_ontrail
```

### MCP Server Issues
```powershell
# Test MCP server directly
cd C:\Users\johs\.cursor-mcp
node mcp-server-ssh.js

# Check for Node.js errors
npm list --depth=0
```

### Cursor IDE Issues
1. **Restart Cursor** after configuration changes
2. **Check MCP logs** in Cursor's developer console
3. **Verify configuration syntax** in `.cursor\mcp.json`

### Common Errors

**"MCP server failed to start"**
- Check Node.js version (must be 18+)
- Verify all dependencies are installed
- Check file permissions on the MCP server files

**"SSH connection refused"**
- Verify server is accessible: `ping ontrail.tech`
- Check SSH service status on server
- Verify firewall rules allow SSH connections

**"Permission denied (publickey)"**
- Ensure SSH key is properly added to server's authorized_keys
- Check SSH key file permissions
- Verify correct username in configuration

## 📊 Monitoring & Maintenance

### Regular Tasks
- **Monitor server resources**: Use "Check server status" regularly
- **Review logs**: Check application and system logs periodically
- **Backup database**: Create regular database backups
- **Update dependencies**: Keep Node.js and npm packages updated

### Health Checks
Set up automated health checks:
```cursor
"Check nginx configuration"
"Verify database connectivity"
"Monitor application performance"
"Check disk space usage"
```

## 🚀 Advanced Usage

### Custom Commands
You can extend the MCP server by modifying `mcp-server-ssh.js`:

```javascript
// Add custom tools in the setupToolHandlers() method
{
  name: "custom_command",
  description: "Your custom server command",
  inputSchema: {
    type: "object",
    properties: {
      parameter: { type: "string" }
    }
  }
}
```

### Integration with CI/CD
Combine with your deployment scripts:
```cursor
"Execute deployment script on server"
"Run database migrations after deployment"
"Restart services in correct order"
```

## 📞 Support

If you encounter issues:

1. **Check the troubleshooting section** above
2. **Test SSH connection manually** first
3. **Verify MCP server logs** in Cursor
4. **Check server-side permissions** and configurations
5. **Review firewall and security group settings**

## 🎉 You're All Set!

With the SSH MCP server configured, you now have seamless remote server management capabilities directly within Cursor IDE. You can manage your Ontrail application, monitor server health, and perform deployments without leaving your development environment!

**Happy coding! 🚀**

