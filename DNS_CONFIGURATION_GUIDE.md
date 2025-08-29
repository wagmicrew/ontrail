# 🌐 DNS Configuration Guide for ontrail.tech

This guide provides complete DNS configuration for both **website hosting** and **email services** on your ontrail.tech domain.

## 📋 Quick Setup

### Server Information
- **Server IP**: `85.208.51.194`
- **Domain**: `ontrail.tech`
- **Nameservers**: Configure these in your domain registrar

---

## 🌐 Website DNS Records

### Required Records for Website

| Type | Name | Value | TTL | Purpose |
|------|------|-------|-----|---------|
| **A** | `@` | `85.208.51.194` | 3600 | Main website |
| **A** | `www` | `85.208.51.194` | 3600 | WWW subdomain |
| **A** | `*` | `85.208.51.194` | 3600 | Wildcard for user profiles |

### CNAME Records (if needed)
```dns
Type: CNAME
Name: api
Value: @
TTL: 3600
Purpose: API subdomain
```

---

## 📧 Email DNS Records

### MX Records (Mail Exchange)
Configure these in order of priority:

| Type | Name | Value | Priority | TTL |
|------|------|-------|----------|-----|
| **MX** | `@` | `mx1.ontrail.tech` | 10 | 3600 |
| **MX** | `@` | `mx2.ontrail.tech` | 20 | 3600 |

### A Records for Mail Servers
| Type | Name | Value | TTL |
|------|------|-------|-----|
| **A** | `mail` | `85.208.51.194` | 3600 |
| **A** | `mx1` | `85.208.51.194` | 3600 |
| **A** | `mx2` | `85.208.51.194` | 3600 |
| **A** | `smtp` | `85.208.51.194` | 3600 |
| **A** | `imap` | `85.208.51.194` | 3600 |
| **A** | `pop3` | `85.208.51.194` | 3600 |

### SPF Record (Sender Policy Framework)
```dns
Type: TXT
Name: @
Value: "v=spf1 a mx ip4:85.208.51.194 -all"
TTL: 3600
```

### DKIM Record (DomainKeys Identified Mail)
```dns
Type: TXT
Name: default._domainkey
Value: "v=DKIM1; k=rsa; p=YOUR_DKIM_PUBLIC_KEY_HERE"
TTL: 3600
```

### DMARC Record (Domain-based Message Authentication)
```dns
Type: TXT
Name: _dmarc
Value: "v=DMARC1; p=quarantine; rua=mailto:dmarc@ontrail.tech; ruf=mailto:dmarc@ontrail.tech"
TTL: 3600
```

---

## 📝 Complete DNS Zone File

Here's your complete DNS zone file:

```dns
; ontrail.tech DNS Zone File
; Server IP: 85.208.51.194

; SOA Record
@ IN SOA ns1.ontrail.tech. admin.ontrail.tech. (
    2024010101 ; Serial
    3600       ; Refresh
    1800       ; Retry
    1209600    ; Expire
    86400      ; Minimum TTL
)

; NS Records (Nameservers)
@ IN NS ns1.ontrail.tech.
@ IN NS ns2.ontrail.tech.

; A Records - Website
@ IN A 85.208.51.194
www IN A 85.208.51.194
* IN A 85.208.51.194

; A Records - Email
mail IN A 85.208.51.194
mx1 IN A 85.208.51.194
mx2 IN A 85.208.51.194
smtp IN A 85.208.51.194
imap IN A 85.208.51.194
pop3 IN A 85.208.51.194

; MX Records - Email
@ IN MX 10 mx1.ontrail.tech.
@ IN MX 20 mx2.ontrail.tech.

; TXT Records - Email Security
@ IN TXT "v=spf1 a mx ip4:85.208.51.194 -all"
_dmarc IN TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@ontrail.tech; ruf=mailto:dmarc@ontrail.tech"
default._domainkey IN TXT "v=DKIM1; k=rsa; p=YOUR_DKIM_PUBLIC_KEY_HERE"

; CNAME Records (Optional)
api IN CNAME @
```

---

## 🛠️ Step-by-Step DNS Configuration

### Step 1: Access Your Domain Registrar
1. Log into your domain registrar (GoDaddy, Namecheap, etc.)
2. Navigate to DNS settings for `ontrail.tech`
3. Remove any existing records
4. Add the records below

### Step 2: Add Website Records
```
Type: A
Name: @
Value: 85.208.51.194
TTL: 3600

Type: A
Name: www
Value: 85.208.51.194
TTL: 3600

Type: A
Name: *
Value: 85.208.51.194
TTL: 3600
```

### Step 3: Add Email Records
```
Type: A
Name: mail
Value: 85.208.51.194
TTL: 3600

Type: A
Name: mx1
Value: 85.208.51.194
TTL: 3600

Type: A
Name: mx2
Value: 85.208.51.194
TTL: 3600

Type: MX
Name: @
Value: mx1.ontrail.tech
Priority: 10
TTL: 3600

Type: MX
Name: @
Value: mx2.ontrail.tech
Priority: 20
TTL: 3600
```

### Step 4: Add Security Records
```
Type: TXT
Name: @
Value: "v=spf1 a mx ip4:85.208.51.194 -all"
TTL: 3600

Type: TXT
Name: _dmarc
Value: "v=DMARC1; p=quarantine; rua=mailto:dmarc@ontrail.tech; ruf=mailto:dmarc@ontrail.tech"
TTL: 3600
```

---

## 🧪 Testing Your DNS Configuration

### Test Website DNS
```bash
# Test main domain
nslookup ontrail.tech

# Test www subdomain
nslookup www.ontrail.tech

# Test wildcard subdomain
nslookup test.ontrail.tech
```

### Test Email DNS
```bash
# Test MX records
nslookup -type=mx ontrail.tech

# Test SPF record
nslookup -type=txt ontrail.tech

# Test DMARC record
nslookup -type=txt _dmarc.ontrail.tech
```

### Test from Server
```bash
# From your server, test DNS resolution
ssh root@85.208.51.194 "nslookup ontrail.tech"
ssh root@85.208.51.194 "nslookup -type=mx ontrail.tech"
```

---

## 📧 Email Server Setup (Optional)

If you want to set up your own email server, you'll need:

### Required Software
- **Postfix** (SMTP server)
- **Dovecot** (IMAP/POP3 server)
- **SpamAssassin** (Spam filtering)
- **ClamAV** (Virus scanning)

### Installation Commands
```bash
# Install email server components
sudo apt update
sudo apt install -y postfix dovecot-core dovecot-imapd dovecot-pop3d
sudo apt install -y spamassassin clamav clamav-daemon
sudo apt install -y opendkim opendmarc
```

### Configuration Files to Set Up
- `/etc/postfix/main.cf` - Postfix configuration
- `/etc/dovecot/dovecot.conf` - Dovecot configuration
- `/etc/opendkim.conf` - DKIM configuration
- `/etc/opendmarc.conf` - DMARC configuration

---

## 🌐 Popular Domain Registrars

### GoDaddy
1. Login → Domain Settings → DNS Management
2. Add records as specified above
3. Save changes

### Namecheap
1. Login → Domain List → Manage
2. Advanced DNS → Add new records
3. Add records as specified above

### Cloudflare
1. Login → Select domain
2. DNS → Add records
3. Add records as specified above
4. Enable proxy (orange cloud) for website records

### AWS Route 53
1. Route 53 → Hosted zones → Create record
2. Add records as specified above

---

## ⏱️ DNS Propagation

### How Long Does It Take?
- **Initial**: 24-48 hours
- **Updates**: 4-24 hours
- **Global**: Up to 72 hours for full propagation

### Check Propagation Status
```bash
# Check from different locations
curl -s https://dns.google/resolve?name=ontrail.tech&type=A

# Use online tools
# • https://dnschecker.org
# • https://mxtoolbox.com
# • https://intodns.com
```

### Speed Up Propagation
1. Clear local DNS cache:
   ```bash
   # Windows
   ipconfig /flushdns

   # Linux/Mac
   sudo killall -HUP mDNSResponder
   ```

2. Test from different networks
3. Use different DNS servers (8.8.8.8, 1.1.1.1)

---

## 🚨 Troubleshooting DNS Issues

### Common Problems

#### 1. Website Not Loading
```bash
# Check DNS resolution
nslookup ontrail.tech

# Check server connectivity
ping 85.208.51.194

# Check nginx status
ssh root@85.208.51.194 "systemctl status nginx"
```

#### 2. Email Not Working
```bash
# Check MX records
nslookup -type=mx ontrail.tech

# Check SPF record
nslookup -type=txt ontrail.tech
```

#### 3. SSL Certificate Issues
```bash
# Check certificate
ssh root@85.208.51.194 "certbot certificates"

# Renew certificate
ssh root@85.208.51.194 "certbot renew"
```

### DNS Debugging Tools
```bash
# Comprehensive DNS check
dig ontrail.tech ANY

# Trace DNS resolution
dig +trace ontrail.tech

# Check specific record types
dig MX ontrail.tech
dig TXT ontrail.tech
dig A ontrail.tech
```

---

## 📞 Support & Help

### If DNS Doesn't Work
1. **Wait 24-48 hours** for propagation
2. **Double-check records** in your registrar
3. **Test from different locations**
4. **Clear DNS cache** on your devices

### Contact Information
- **Domain Registrar Support**: Check your registrar's help desk
- **Server Issues**: Check server logs
- **SSL Issues**: Use `certbot certificates` command

---

## ✅ Verification Checklist

### Website DNS ✅
- [ ] Main domain (`ontrail.tech`) resolves to `85.208.51.194`
- [ ] WWW subdomain (`www.ontrail.tech`) resolves correctly
- [ ] Wildcard subdomains work (`*.ontrail.tech`)
- [ ] HTTPS redirects properly
- [ ] SSL certificate is valid

### Email DNS ✅
- [ ] MX records point to your mail servers
- [ ] SPF record is configured correctly
- [ ] DMARC record is set up
- [ ] DKIM is configured (optional)
- [ ] Reverse DNS is set up (optional)

### General ✅
- [ ] DNS propagation is complete (24-48 hours)
- [ ] All services are accessible
- [ ] SSL certificate is valid and current
- [ ] Monitoring is working

---

## 🎉 Configuration Complete!

**Your DNS is now configured for:**
- ✅ **Website hosting** on `https://ontrail.tech`
- ✅ **SSL security** with automatic certificates
- ✅ **Email services** (MX, SPF, DMARC)
- ✅ **Wildcard subdomains** for user profiles
- ✅ **Security headers** and best practices

**Next Steps:**
1. Wait for DNS propagation (24-48 hours)
2. Test your website at `https://ontrail.tech`
3. Set up email services if needed
4. Monitor SSL certificate renewal

**🌐 Your domain is ready for production!** 🚀✨

