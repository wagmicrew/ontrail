# 🐘 PostgreSQL Setup Guide for Ontrail Social-Fi Application

This guide will help you set up PostgreSQL database server and connect it to your Ontrail Social-Fi application.

## 📋 Prerequisites

- ✅ Ubuntu server (85.208.51.194)
- ✅ SSH access with private key
- ✅ Ontrail application deployed to `/var/www/ontrailapp/webApp`
- ✅ PM2 process manager configured

## 🚀 Quick Setup (Automated)

### Step 1: Set up PostgreSQL Server

Run the PowerShell script to set up PostgreSQL on your server:

```powershell
# From your local machine (Windows with PowerShell)
.\setup-postgres.ps1
```

This script will:
- ✅ Install PostgreSQL on the server
- ✅ Create database `ontrail` and user `ontrail_user`
- ✅ Set up proper authentication
- ✅ Create environment configuration file
- ✅ Verify database connectivity

### Step 2: Run Database Migrations

After PostgreSQL is set up, run the migrations:

```powershell
# Run database migrations
.\run-migrations.ps1
```

This script will:
- ✅ Install dependencies (if needed)
- ✅ Run Drizzle migrations to create all tables
- ✅ Verify migration success
- ✅ Check database connectivity

### Step 3: Restart Application

Restart the Ontrail application to pick up the new database connection:

```powershell
# Restart the application
pm2 restart ontrail-app
```

## 📊 Database Configuration

After setup, your database will be configured with:

| Setting | Value |
|---------|-------|
| **Host** | `localhost` |
| **Port** | `5432` |
| **Database** | `ontrail` |
| **User** | `ontrail_user` |
| **Password** | `Tropictiger2025!` |
| **Connection URL** | `postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail` |

## 🗂️ Database Schema

The Ontrail application includes a comprehensive Social-Fi database schema:

### Core Tables:
- **`users`** - User authentication (NextAuth.js compatible)
- **`profiles`** - Extended user profiles with valuation algorithm
- **`friendships`** - Tokenized friendship system
- **`pois`** - Points of Interest with NFT support
- **`quests`** - Quest system with sponsorship
- **`posts`** - Social media posts and timeline
- **`wallets`** - Solana wallet management
- **`transactions`** - Blockchain transaction tracking

### Supporting Tables:
- **`poi_visits`** - POI visit tracking
- **`quest_participants`** - Quest participation
- **`post_likes`** - Post engagement
- **`comments`** - Post comments
- **`follows`** - User following system

## 🔧 Manual Setup (If Automated Scripts Fail)

If the automated scripts don't work, you can set up PostgreSQL manually:

### Step 1: Install PostgreSQL

```bash
# On your Ubuntu server
sudo apt update
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

### Step 2: Configure PostgreSQL

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL shell:
ALTER USER postgres PASSWORD 'Tropictiger2025!';
CREATE USER ontrail_user WITH PASSWORD 'Tropictiger2025!';
CREATE DATABASE ontrail OWNER ontrail_user;
GRANT ALL PRIVILEGES ON DATABASE ontrail TO ontrail_user;
\q
```

### Step 3: Create Environment File

```bash
# Create .env.local in your application directory
cat > /var/www/ontrailapp/webApp/.env.local << 'EOF'
# Database Configuration
DATABASE_URL="postgresql://ontrail_user:Tropictiger2025!@localhost:5432/ontrail"

# NextAuth.js Configuration
NEXTAUTH_URL="https://ontrail.tech"
NEXTAUTH_SECRET="your-nextauth-secret-here-replace-in-production"

# OAuth Providers (Configure these)
GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_SECRET=""
FACEBOOK_CLIENT_ID=""
FACEBOOK_CLIENT_SECRET=""

# Solana Configuration
SOLANA_RPC_URL="https://api.devnet.solana.com"

# Application Environment
NODE_ENV="production"
EOF
```

### Step 4: Run Migrations

```bash
# Navigate to your application directory
cd /var/www/ontrailapp/webApp

# Install dependencies
npm install

# Run migrations
npm run db:migrate
```

### Step 5: Restart Application

```bash
# Restart the application
pm2 restart ontrail-app
```

## 🧪 Testing Database Connection

### Test from Server:

```bash
# Test database connection
cd /var/www/ontrailapp/webApp
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "SELECT current_database(), current_user, version();"
```

### Test from Application:

1. Check PM2 logs: `pm2 logs ontrail-app`
2. Look for database connection messages
3. Test application functionality at https://ontrail.tech

## 🔒 Security Considerations

### For Production:

1. **Change Default Password:**
   ```sql
   ALTER USER ontrail_user PASSWORD 'your-secure-password-here';
   ```

2. **Configure Firewall:**
   ```bash
   # Only allow local connections to PostgreSQL
   sudo ufw allow from 127.0.0.1 to any port 5432
   sudo ufw deny from any to any port 5432
   ```

3. **Update Environment Variables:**
   - Change `NEXTAUTH_SECRET`
   - Add JWT secrets if needed
   - Configure OAuth providers

4. **SSL Configuration:**
   ```bash
   # Enable SSL in PostgreSQL
   sudo -u postgres psql -c "ALTER SYSTEM SET ssl = 'on';"
   sudo systemctl restart postgresql
   ```

## 🐛 Troubleshooting

### Common Issues:

1. **Connection Refused:**
   ```bash
   # Check if PostgreSQL is running
   sudo systemctl status postgresql

   # Check PostgreSQL logs
   sudo tail -f /var/log/postgresql/postgresql-17-main.log
   ```

2. **Authentication Failed:**
   ```bash
   # Reset password
   sudo -u postgres psql
   ALTER USER ontrail_user PASSWORD 'Tropictiger2025!';
   ```

3. **Migration Errors:**
   ```bash
   # Check database permissions
   PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "\l"

   # Verify migration files exist
   ls -la /var/www/ontrailapp/webApp/drizzle/
   ```

4. **Application Won't Start:**
   ```bash
   # Check environment variables
   cat /var/www/ontrailapp/webApp/.env.local

   # Check PM2 logs
   pm2 logs ontrail-app
   ```

## 📈 Monitoring

### Database Health:

```bash
# Check database size
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "SELECT pg_size_pretty(pg_database_size('ontrail'));"

# Check active connections
PGPASSWORD='Tropictiger2025!' psql -h localhost -U ontrail_user -d ontrail -c "SELECT count(*) FROM pg_stat_activity WHERE datname = 'ontrail';"
```

### Application Monitoring:

```bash
# Check application status
pm2 status

# Monitor database queries (if needed)
pm2 logs ontrail-app --lines 50
```

## 🎯 Next Steps

After successful database setup:

1. ✅ **Test User Registration** - Create test user accounts
2. ✅ **Configure OAuth** - Set up Google/Facebook login
3. ✅ **Test Social Features** - Friendships, posts, quests
4. ✅ **Configure Solana** - Set up wallet integration
5. ✅ **Deploy Updates** - Push new features to production

## 📞 Support

If you encounter issues:

1. Check this troubleshooting guide
2. Review PM2 and PostgreSQL logs
3. Verify environment variables
4. Test database connectivity manually

---

## 🎉 Success Checklist

- [ ] PostgreSQL installed and running
- [ ] Database `ontrail` created
- [ ] User `ontrail_user` configured
- [ ] Environment file created
- [ ] Migrations applied successfully
- [ ] Application restarted
- [ ] Database connection verified
- [ ] Application accessible at https://ontrail.tech

**Congratulations! Your Ontrail Social-Fi application now has a fully functional PostgreSQL database! 🚀**

