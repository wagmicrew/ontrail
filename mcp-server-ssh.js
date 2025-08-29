#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import { exec } from 'child_process';
import { promisify } from 'util';
import fs from 'fs';
import path from 'path';

const execAsync = promisify(exec);

// Server configuration
const SERVER_CONFIG = {
  host: process.env.SSH_HOST || 'ontrail.tech',
  user: process.env.SSH_USER || 'root',
  keyPath: process.env.SSH_KEY_PATH || path.join(process.env.HOME || process.env.USERPROFILE, '.ssh', 'id_rsa_ontrail'),
  port: process.env.SSH_PORT || 22
};

class SSHMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: "ssh-remote-manager",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
  }

  setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "ssh_exec",
            description: "Execute a command on the remote SSH server",
            inputSchema: {
              type: "object",
              properties: {
                command: {
                  type: "string",
                  description: "Command to execute on the remote server"
                },
                cwd: {
                  type: "string",
                  description: "Working directory on remote server (optional)"
                }
              },
              required: ["command"]
            }
          },
          {
            name: "ssh_file_read",
            description: "Read a file from the remote SSH server",
            inputSchema: {
              type: "object",
              properties: {
                path: {
                  type: "string",
                  description: "Path to file on remote server"
                },
                lines: {
                  type: "number",
                  description: "Number of lines to read (optional, reads all if not specified)"
                }
              },
              required: ["path"]
            }
          },
          {
            name: "ssh_file_write",
            description: "Write content to a file on the remote SSH server",
            inputSchema: {
              type: "object",
              properties: {
                path: {
                  type: "string",
                  description: "Path to file on remote server"
                },
                content: {
                  type: "string",
                  description: "Content to write to the file"
                },
                append: {
                  type: "boolean",
                  description: "Whether to append to existing file (default: false)"
                }
              },
              required: ["path", "content"]
            }
          },
          {
            name: "ssh_list_dir",
            description: "List contents of a directory on the remote SSH server",
            inputSchema: {
              type: "object",
              properties: {
                path: {
                  type: "string",
                  description: "Path to directory on remote server",
                  default: "."
                }
              }
            }
          },
          {
            name: "ssh_status",
            description: "Get system status information from the remote server",
            inputSchema: {
              type: "object",
              properties: {
                services: {
                  type: "array",
                  items: { type: "string" },
                  description: "List of services to check status for",
                  default: ["nginx", "postgresql", "pm2"]
                }
              }
            }
          },
          {
            name: "ssh_deploy",
            description: "Deploy application updates to the remote server",
            inputSchema: {
              type: "object",
              properties: {
                action: {
                  type: "string",
                  enum: ["sync", "restart", "logs", "backup"],
                  description: "Deployment action to perform"
                }
              },
              required: ["action"]
            }
          },
          {
            name: "ssh_database",
            description: "Manage PostgreSQL database on the remote server",
            inputSchema: {
              type: "object",
              properties: {
                action: {
                  type: "string",
                  enum: ["status", "backup", "migrate", "query"],
                  description: "Database action to perform"
                },
                query: {
                  type: "string",
                  description: "SQL query to execute (for query action)"
                }
              },
              required: ["action"]
            }
          }
        ]
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "ssh_exec":
            return await this.handleSSHExec(args);
          case "ssh_file_read":
            return await this.handleFileRead(args);
          case "ssh_file_write":
            return await this.handleFileWrite(args);
          case "ssh_list_dir":
            return await this.handleListDir(args);
          case "ssh_status":
            return await this.handleStatus(args);
          case "ssh_deploy":
            return await this.handleDeploy(args);
          case "ssh_database":
            return await this.handleDatabase(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [{ type: "text", text: `Error: ${error.message}` }],
          isError: true
        };
      }
    });
  }

  async executeSSHCommand(command, options = {}) {
    const sshCommand = [
      'ssh',
      '-i', SERVER_CONFIG.keyPath,
      '-o', 'StrictHostKeyChecking=no',
      '-o', 'UserKnownHostsFile=/dev/null',
      `${SERVER_CONFIG.user}@${SERVER_CONFIG.host}`,
      command
    ].join(' ');

    try {
      const { stdout, stderr } = await execAsync(sshCommand, options);
      return { stdout: stdout.trim(), stderr: stderr.trim() };
    } catch (error) {
      throw new Error(`SSH command failed: ${error.message}`);
    }
  }

  async handleSSHExec(args) {
    const { command, cwd } = args;
    const fullCommand = cwd ? `cd ${cwd} && ${command}` : command;

    const result = await this.executeSSHCommand(fullCommand);

    return {
      content: [
        { type: "text", text: result.stdout || "Command executed successfully" }
      ]
    };
  }

  async handleFileRead(args) {
    const { path: filePath, lines } = args;
    const command = lines ? `head -n ${lines} ${filePath}` : `cat ${filePath}`;

    const result = await this.executeSSHCommand(command);

    return {
      content: [
        { type: "text", text: result.stdout }
      ]
    };
  }

  async handleFileWrite(args) {
    const { path: filePath, content, append = false } = args;
    const operator = append ? '>>' : '>';
    const escapedContent = content.replace(/'/g, "'\\''");
    const command = `echo '${escapedContent}' ${operator} ${filePath}`;

    await this.executeSSHCommand(command);

    return {
      content: [
        { type: "text", text: `File ${append ? 'updated' : 'created'} successfully` }
      ]
    };
  }

  async handleListDir(args) {
    const { path: dirPath = "." } = args;
    const command = `ls -la ${dirPath}`;

    const result = await this.executeSSHCommand(command);

    return {
      content: [
        { type: "text", text: result.stdout }
      ]
    };
  }

  async handleStatus(args) {
    const { services = ["nginx", "postgresql", "pm2"] } = args;

    let statusOutput = "# Server Status Report\n\n";

    // System info
    try {
      const uptime = await this.executeSSHCommand("uptime");
      statusOutput += `## System Uptime\n${uptime.stdout}\n\n`;

      const disk = await this.executeSSHCommand("df -h /");
      statusOutput += `## Disk Usage\n${disk.stdout}\n\n`;

      const memory = await this.executeSSHCommand("free -h");
      statusOutput += `## Memory Usage\n${memory.stdout}\n\n`;
    } catch (error) {
      statusOutput += `## System Info Error: ${error.message}\n\n`;
    }

    // Service status
    statusOutput += "## Service Status\n";
    for (const service of services) {
      try {
        const result = await this.executeSSHCommand(`systemctl is-active ${service}`);
        const status = result.stdout === 'active' ? '✅ Running' : '❌ Stopped';
        statusOutput += `${service}: ${status}\n`;
      } catch (error) {
        statusOutput += `${service}: ❌ Error - ${error.message}\n`;
      }
    }

    // Application status
    try {
      const pm2Status = await this.executeSSHCommand("pm2 jlist");
      const pm2Data = JSON.parse(pm2Status.stdout);
      statusOutput += "\n## PM2 Applications\n";
      pm2Data.forEach(app => {
        statusOutput += `${app.name}: ${app.pm2_env.status} (PID: ${app.pid})\n`;
      });
    } catch (error) {
      statusOutput += `\n## PM2 Status Error: ${error.message}\n`;
    }

    return {
      content: [
        { type: "text", text: statusOutput }
      ]
    };
  }

  async handleDeploy(args) {
    const { action } = args;
    let command = "";
    let description = "";

    switch (action) {
      case "sync":
        command = "cd /var/www/ontrailapp/webApp && git pull origin main";
        description = "Syncing latest changes from git repository";
        break;
      case "restart":
        command = "pm2 restart ontrail-app";
        description = "Restarting application";
        break;
      case "logs":
        command = "pm2 logs ontrail-app --lines 20";
        description = "Showing recent application logs";
        break;
      case "backup":
        command = "mkdir -p /var/www/ontrailapp/backups && pg_dump -U ontrail_user -h localhost ontrail_db > /var/www/ontrailapp/backups/backup_$(date +%Y%m%d_%H%M%S).sql";
        description = "Creating database backup";
        break;
      default:
        throw new Error(`Unknown deployment action: ${action}`);
    }

    const result = await this.executeSSHCommand(command);

    return {
      content: [
        { type: "text", text: `${description}:\n${result.stdout}` }
      ]
    };
  }

  async handleDatabase(args) {
    const { action, query } = args;
    let command = "";
    let description = "";

    switch (action) {
      case "status":
        command = "sudo -u postgres psql -c 'SELECT version();'";
        description = "PostgreSQL version and status";
        break;
      case "backup":
        command = "mkdir -p /var/www/ontrailapp/backups && pg_dump -U ontrail_user -h localhost ontrail_db > /var/www/ontrailapp/backups/db_backup_$(date +%Y%m%d_%H%M%S).sql && echo 'Backup completed successfully'";
        description = "Creating database backup";
        break;
      case "migrate":
        command = "cd /var/www/ontrailapp/webApp && npx drizzle-kit migrate";
        description = "Running database migrations";
        break;
      case "query":
        if (!query) throw new Error("Query parameter required for query action");
        command = `psql -U ontrail_user -h localhost -d ontrail_db -c "${query}"`;
        description = "Executing database query";
        break;
      default:
        throw new Error(`Unknown database action: ${action}`);
    }

    const result = await this.executeSSHCommand(command);

    return {
      content: [
        { type: "text", text: `${description}:\n${result.stdout}` }
      ]
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("SSH MCP Server running...");
  }
}

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.error("Shutting down SSH MCP Server...");
  process.exit(0);
});

// Start the server
const server = new SSHMCPServer();
server.run().catch((error) => {
  console.error("Failed to start SSH MCP Server:", error);
  process.exit(1);
});


