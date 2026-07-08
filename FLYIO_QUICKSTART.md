# 🚀 Fly.io Quick Deploy

## Install Fly.io CLI

**PowerShell (Windows):**
```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

**Bash (Linux/Mac):**
```bash
curl -L https://fly.io/install.sh | sh
```

---

## Deploy (Complete Setup)

**PowerShell:**
```powershell
.\deploy-flyio.ps1 -All
```

**Bash:**
```bash
chmod +x deploy-flyio.sh
./deploy-flyio.sh --all
```

---

## Deploy (Update Only)

**PowerShell:**
```powershell
.\deploy-flyio.ps1 -Deploy
```

**Bash:**
```bash
./deploy-flyio.sh --deploy
```

---

## Manual Commands

```bash
# Login
flyctl auth login

# Create app
flyctl apps create choose-your-own-adventure-ai

# Set secrets
flyctl secrets set \
  DATABASE_URL="postgresql://..." \
  OPENAI_API_KEY="sk-..." \
  ALLOWED_ORIGINS="https://choose-your-own-adventure-ai.fly.dev"

# Deploy
flyctl deploy

# Open app
flyctl open

# View logs
flyctl logs -f

# Check status
flyctl status
```

---

## Your App URL

https://choose-your-own-adventure-ai.fly.dev

---

## Full Documentation

See [FLYIO_DEPLOYMENT.md](FLYIO_DEPLOYMENT.md) for complete guide.
