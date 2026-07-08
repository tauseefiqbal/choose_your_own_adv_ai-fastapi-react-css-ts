# Quick Deployment Commands

## Option 1: Vercel Frontend + Render Backend (Recommended)

### Frontend (Vercel)
```powershell
# PowerShell
.\deploy-vercel.ps1 -BackendUrl "https://choose-your-own-adventure-ai.onrender.com" -Production

# Or Bash
chmod +x deploy-vercel.sh
./deploy-vercel.sh "https://choose-your-own-adventure-ai.onrender.com" production
```

### Backend (Render)
Already configured! Just push to GitHub and connect in Render dashboard.

---

## Option 2: Railway (Full Docker)

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize project
railway init

# Deploy
railway up

# Get URL
railway open
```

---

## Option 3: Fly.io (Global Edge)

```bash
# Install flyctl
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"

# Login
fly auth login

# Launch (creates fly.toml)
fly launch --dockerfile Dockerfile

# Deploy
fly deploy

# Open app
fly open
```

---

## Option 4: DigitalOcean App Platform

```bash
# Install doctl
# Download from: https://github.com/digitalocean/doctl

# Login
doctl auth init

# Create app from spec
doctl apps create --spec .do/app.yaml

# Or use Web UI
# Push to GitHub, connect in DigitalOcean dashboard
```

---

## Option 5: Local Docker

```bash
# Build
docker build -t choose-adventure -f Dockerfile .

# Run
docker run -p 8080:8080 \
  -e DATABASE_URL="your-postgres-url" \
  -e OPENAI_API_KEY="your-key" \
  -e ALLOWED_ORIGINS="http://localhost:8080" \
  choose-adventure

# Open browser
start http://localhost:8080
```

---

## Environment Variables Required

### Backend
- `DATABASE_URL` - PostgreSQL connection string
- `OPENAI_API_KEY` - OpenAI API key
- `ALLOWED_ORIGINS` - Comma-separated frontend URLs
- `DEBUG` - `True` for development, `False` for production
- `API_PREFIX` - `/api` (default)

### Frontend (for separate deployment)
- `VITE_API_URL` - Backend URL (without /api)
- `VITE_DEBUG` - `false` for production

---

## Testing Deployments

### Backend Health Check
```bash
curl https://your-backend-url/health
# Should return: {"status":"healthy","service":"choose-your-own-adventure-api"}
```

### Frontend
Visit your frontend URL and try generating a story.

---

## Troubleshooting

### CORS Errors
Add your frontend URL to `ALLOWED_ORIGINS` in backend environment variables.

### API Not Found (404)
- Check `VITE_API_URL` in frontend
- Verify backend is deployed and running
- Check `/api` prefix in requests

### Database Connection Failed
- Verify `DATABASE_URL` format
- Check database is accessible from deployment platform
- Ensure SSL mode is correct for your database

### Build Failures
- Check Node.js version (needs 20+)
- Check Python version (needs 3.13+)
- Verify all dependencies are in requirements.txt/package.json
