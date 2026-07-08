# Vercel Deployment Guide

## ⚠️ Important Note About Vercel

**Vercel is primarily designed for:**
- Static frontend hosting (React, Next.js, Vue, etc.)
- Serverless functions (Edge Functions, API Routes)

**Vercel does NOT natively support:**
- Traditional Docker containers with long-running processes
- FastAPI/Python backends in the standard way

## Recommended Deployment Options

### Option 1: Split Deployment (Recommended) ⭐

Deploy frontend and backend separately for best results:

#### Frontend on Vercel
1. Deploy only the frontend to Vercel (static hosting)
2. Point API calls to your backend hosted elsewhere

#### Backend Options
Choose one of these for your FastAPI backend:
- **Railway** - Easy Python/Docker deployment
- **Fly.io** - Global edge deployment
- **Render** - Free tier available (current setup)
- **Heroku** - Reliable platform
- **DigitalOcean App Platform** - Simple Docker deployment
- **AWS ECS/Fargate** - Enterprise scale

**Steps:**

1. **Deploy Backend** (e.g., on Railway):
   ```bash
   # Use existing Dockerfile
   railway up
   ```
   Get your backend URL: `https://your-app.railway.app`

2. **Update Frontend Environment** (Vercel):
   ```bash
   cd frontend
   # Update .env or .env.production
   VITE_API_URL=https://your-app.railway.app
   ```

3. **Deploy Frontend to Vercel**:
   ```bash
   # Install Vercel CLI
   npm i -g vercel
   
   # Deploy frontend
   cd frontend
   vercel
   ```

4. **Configure Environment Variables in Vercel Dashboard**:
   - `VITE_API_URL`: Your backend URL
   - `VITE_DEBUG`: `false`

---

### Option 2: Vercel with Serverless Functions

Convert your FastAPI routes to Vercel serverless functions.

**Limitations:**
- 10-second execution timeout (Hobby plan)
- Cold starts
- No persistent connections
- Limited to 50MB deployment size

**Not recommended for this app** because:
- Story generation may take >10 seconds
- WebSocket support is limited
- Complex state management

---

### Option 3: Vercel + External Backend (Hybrid)

**Frontend**: Vercel (static)  
**Backend**: Keep on Render (current setup)

**Simplest approach:**

1. Keep your backend on Render: `https://choose-your-own-adventure-ai.onrender.com`

2. Update `frontend/.env.production`:
   ```env
   VITE_API_URL=https://choose-your-own-adventure-ai.onrender.com
   ```

3. Deploy frontend to Vercel:
   ```bash
   cd frontend
   vercel --prod
   ```

4. Update CORS in `backend/.env`:
   ```env
   ALLOWED_ORIGINS=https://your-vercel-app.vercel.app
   ```

---

### Option 4: Full Docker Deployment (Not Vercel)

If you want to use Docker, use these platforms instead:

#### Railway
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

#### Fly.io
```bash
# Install flyctl
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"

# Deploy
fly launch
fly deploy
```

#### Render (Current)
Already configured in `render.yaml` - just push to GitHub and connect in Render dashboard.

---

## Quick Start: Vercel Frontend + Render Backend

This is the **easiest approach** with your current setup:

### Step 1: Update Frontend Configuration

Create `frontend/.env.production`:
```env
VITE_API_URL=https://choose-your-own-adventure-ai.onrender.com
VITE_DEBUG=false
```

Update `frontend/src/util.ts` to use environment variable:
```typescript
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';
```

### Step 2: Deploy Frontend to Vercel

```bash
cd frontend
npm install -g vercel
vercel login
vercel --prod
```

### Step 3: Update Backend CORS

Add your Vercel URL to `backend/.env`:
```env
ALLOWED_ORIGINS=https://your-app.vercel.app,http://localhost:5173
```

Redeploy backend on Render (automatic if GitHub is connected).

### Step 4: Test

Visit your Vercel URL: `https://your-app.vercel.app`

---

## Environment Variables Needed

### Backend (Render)
- `DATABASE_URL`: Your PostgreSQL Neon connection string
- `OPENAI_API_KEY`: Your OpenAI API key
- `ALLOWED_ORIGINS`: Your Vercel frontend URL
- `DEBUG`: `False`
- `API_PREFIX`: `/api`

### Frontend (Vercel)
- `VITE_API_URL`: Your backend URL
- `VITE_DEBUG`: `false`

---

## Cost Comparison

| Platform | Free Tier | Best For |
|----------|-----------|----------|
| **Vercel** | 100 GB bandwidth | Frontend static hosting |
| **Render** | 750 hours/month | Full-stack Docker apps |
| **Railway** | $5 credit/month | Quick Docker deploys |
| **Fly.io** | 3 shared VMs | Global edge deployment |

---

## Troubleshooting

### CORS Errors
- Ensure backend `ALLOWED_ORIGINS` includes your Vercel URL
- Check browser console for specific errors

### API Not Responding
- Verify backend URL is correct in frontend `.env.production`
- Check backend logs on Render
- Ensure backend service is running

### 502/503 Errors
- Backend service may be sleeping (Render free tier)
- First request after inactivity takes ~30 seconds

---

## Summary

✅ **Recommended**: Deploy frontend to Vercel, keep backend on Render  
❌ **Not Recommended**: Docker on Vercel (not supported)  
✅ **Alternative**: Use Railway or Fly.io for full Docker deployment  

Choose the approach that best fits your needs!
