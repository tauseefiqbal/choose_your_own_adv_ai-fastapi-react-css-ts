# Fly.io Deployment Guide

Complete guide for deploying Choose Your Own Adventure AI to Fly.io.

---

## Why Fly.io?

✅ **Perfect for Docker** - Native container support  
✅ **Fast deployment** - Global edge network  
✅ **Auto-scaling** - Scales to zero when idle  
✅ **Simple pricing** - Pay only for what you use  
✅ **PostgreSQL support** - Built-in database options  
✅ **Free tier** - 3 shared VMs included  

---

## Prerequisites

1. **Fly.io account** - Sign up at https://fly.io
2. **Fly.io CLI (flyctl)** - Install command below
3. **PostgreSQL database** - Your existing Neon database works perfectly
4. **OpenAI API key** - For story generation

---

## Quick Start (Automated)

### PowerShell (Windows)
```powershell
# Complete setup (first time)
.\deploy-flyio.ps1 -All

# Or step by step:
.\deploy-flyio.ps1 -Initialize
.\deploy-flyio.ps1 -SetSecrets
.\deploy-flyio.ps1 -Deploy
```

### Bash (Linux/Mac)
```bash
# Make script executable
chmod +x deploy-flyio.sh

# Complete setup (first time)
./deploy-flyio.sh --all

# Or step by step:
./deploy-flyio.sh --initialize
./deploy-flyio.sh --secrets
./deploy-flyio.sh --deploy
```

---

## Manual Setup

### Step 1: Install Fly.io CLI

**Windows (PowerShell):**
```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

**Linux/Mac:**
```bash
curl -L https://fly.io/install.sh | sh
```

**Verify installation:**
```bash
flyctl version
```

### Step 2: Login to Fly.io

```bash
flyctl auth login
```

This opens your browser for authentication.

### Step 3: Create Application

```bash
flyctl apps create choose-your-own-adventure-ai
```

Or let Fly.io generate a name:
```bash
flyctl launch --no-deploy
```

### Step 4: Set Environment Secrets

```bash
# Set your PostgreSQL Neon connection string
flyctl secrets set DATABASE_URL="postgresql://user:password@host:port/database?sslmode=require"

# Set your OpenAI API key
flyctl secrets set OPENAI_API_KEY="sk-..."

# Set allowed origins (your app URL)
flyctl secrets set ALLOWED_ORIGINS="https://choose-your-own-adventure-ai.fly.dev"
```

### Step 5: Deploy

```bash
flyctl deploy
```

### Step 6: Open Your App

```bash
flyctl open
```

---

## Configuration Files

### `fly.toml`
Main configuration file. Key settings:

- **App name**: `choose-your-own-adventure-ai`
- **Region**: `iad` (US East - change if needed)
- **Port**: `8080`
- **Memory**: 512 MB
- **CPU**: 1 shared CPU
- **Auto-scaling**: Enabled (scales to 0 when idle)
- **Health check**: `/health` endpoint

### `Dockerfile`
Multi-stage build:
1. Builds React frontend with Node 20
2. Sets up Python 3.13 backend + PostgreSQL
3. Serves static frontend from backend

---

## Available Regions

Change the `primary_region` in `fly.toml`:

- `iad` - US East (Virginia)
- `lax` - US West (Los Angeles)
- `ord` - US Central (Chicago)
- `fra` - Europe (Frankfurt)
- `sin` - Asia (Singapore)
- `syd` - Australia (Sydney)

Full list: https://fly.io/docs/reference/regions/

---

## Useful Commands

### Check Status
```bash
flyctl status --app choose-your-own-adventure-ai
```

### View Logs
```bash
# Real-time logs
flyctl logs --app choose-your-own-adventure-ai

# Follow logs
flyctl logs -f --app choose-your-own-adventure-ai
```

### SSH into Container
```bash
flyctl ssh console --app choose-your-own-adventure-ai
```

### Scale Resources

**Change VM size:**
```bash
# More memory (1 GB)
flyctl scale memory 1024 --app choose-your-own-adventure-ai

# More CPUs
flyctl scale vm shared-cpu-2x --app choose-your-own-adventure-ai
```

**Scale instances:**
```bash
# Multiple instances for high availability
flyctl scale count 2 --app choose-your-own-adventure-ai
```

### Update Secrets
```bash
flyctl secrets set KEY=value --app choose-your-own-adventure-ai
```

### Restart App
```bash
flyctl apps restart choose-your-own-adventure-ai
```

---

## Deployment Workflow

### First Deployment
```bash
# 1. Create app
flyctl apps create choose-your-own-adventure-ai

# 2. Set secrets
flyctl secrets set DATABASE_URL="..." OPENAI_API_KEY="..." ALLOWED_ORIGINS="..."

# 3. Deploy
flyctl deploy

# 4. Open
flyctl open
```

### Subsequent Deployments
```bash
# Just deploy - secrets persist
flyctl deploy
```

Or use the automated script:
```powershell
.\deploy-flyio.ps1 -Deploy
```

---

## Cost Breakdown

### Free Tier (Included)
- 3 shared-cpu-1x VMs (256 MB RAM each)
- 160 GB outbound data transfer
- Unlimited inbound data

### This App (Single Instance)
- **VM**: 1 shared CPU + 512 MB RAM
- **Cost**: Free (within free tier limits)
- **Auto-scaling**: Stops when idle = $0

### If Exceeding Free Tier
- Shared CPU: ~$1.94/month
- Memory: ~$2/GB/month
- Bandwidth: ~$0.02/GB

**Typical cost**: $0-5/month depending on usage

---

## Troubleshooting

### Build Fails

**Check build logs:**
```bash
flyctl logs --app choose-your-own-adventure-ai
```

**Common issues:**
- Missing dependencies in `requirements.txt`
- Node/Python version mismatch
- Docker build context issues

**Solution:**
```bash
# Rebuild with verbose output
flyctl deploy --verbose
```

### App Not Starting

**Check health:**
```bash
flyctl status --app choose-your-own-adventure-ai
```

**View real-time logs:**
```bash
flyctl logs -f --app choose-your-own-adventure-ai
```

**Common issues:**
- Missing environment variables (DATABASE_URL, OPENAI_API_KEY)
- Database connection failed
- Port configuration mismatch

**Solution:**
```bash
# Verify secrets are set
flyctl secrets list --app choose-your-own-adventure-ai

# Check if app is listening on PORT environment variable
flyctl ssh console --app choose-your-own-adventure-ai
# Inside container: echo $PORT
```

### Database Connection Issues

**PostgreSQL Neon:**
- Ensure connection string includes `?sslmode=require`
- Verify database accepts connections from Fly.io IPs
- Check firewall rules

**Test connection:**
```bash
flyctl ssh console --app choose-your-own-adventure-ai
# Inside container:
python -c "from db.database import engine; print(engine.connect())"
```

### CORS Errors

Update ALLOWED_ORIGINS:
```bash
flyctl secrets set ALLOWED_ORIGINS="https://choose-your-own-adventure-ai.fly.dev" \
  --app choose-your-own-adventure-ai
```

---

## Monitoring

### View Metrics
```bash
flyctl dashboard --app choose-your-own-adventure-ai
```

Or visit: https://fly.io/dashboard

### Health Checks
Automatic health checks on `/health` endpoint every 30 seconds.

### Logs
Real-time logs available via CLI:
```bash
flyctl logs -f --app choose-your-own-adventure-ai
```

---

## Custom Domain (Optional)

### Add Your Domain
```bash
flyctl certs add yourdomain.com --app choose-your-own-adventure-ai
```

### Configure DNS
Add CNAME record:
```
yourdomain.com -> choose-your-own-adventure-ai.fly.dev
```

### SSL Certificate
Automatic SSL via Let's Encrypt (handled by Fly.io)

---

## Rollback

### View Releases
```bash
flyctl releases --app choose-your-own-adventure-ai
```

### Rollback to Previous Version
```bash
flyctl releases rollback --app choose-your-own-adventure-ai
```

---

## CI/CD (GitHub Actions)

Create `.github/workflows/fly-deploy.yml`:
```yaml
name: Fly.io Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

Get token: `flyctl auth token`

Add to GitHub Secrets: `FLY_API_TOKEN`

---

## Support

- **Fly.io Docs**: https://fly.io/docs
- **Community**: https://community.fly.io
- **Status**: https://status.fly.io

---

## Summary

✅ **Easy deployment** - Automated scripts included  
✅ **Docker native** - No serverless limitations  
✅ **Auto-scaling** - Free when idle  
✅ **Fast globally** - Edge network  
✅ **Simple pricing** - Predictable costs  

**Your app will be available at:**
https://choose-your-own-adventure-ai.fly.dev

Happy deploying! 🚀
