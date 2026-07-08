#!/bin/bash
# Quick deployment script for Vercel frontend + separate backend

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Choose Your Own Adventure - Deployment Script${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}❌ Vercel CLI not found. Installing...${NC}"
    npm install -g vercel
fi

# Get backend URL
BACKEND_URL=${1:-""}
if [ -z "$BACKEND_URL" ]; then
    echo -e "${YELLOW}⚠️  No backend URL provided.${NC}"
    read -p "Enter your backend URL (e.g., https://your-app.onrender.com): " BACKEND_URL
fi

# Check if production flag is set
PRODUCTION=${2:-"preview"}

echo ""
echo -e "${GREEN}📝 Configuration:${NC}"
echo -e "${WHITE}   Backend URL: $BACKEND_URL${NC}"
echo -e "${WHITE}   Environment: $PRODUCTION${NC}"
echo ""

# Create .env.production file
echo -e "${CYAN}🔧 Creating frontend/.env.production...${NC}"
cat > frontend/.env.production << EOF
VITE_API_URL=$BACKEND_URL
VITE_DEBUG=false
EOF

# Navigate to frontend directory
cd frontend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo -e "${CYAN}📦 Installing frontend dependencies...${NC}"
    npm install
fi

# Build frontend
echo -e "${CYAN}🏗️  Building frontend...${NC}"
npm run build

# Deploy to Vercel
echo -e "${CYAN}🚀 Deploying to Vercel...${NC}"
if [ "$PRODUCTION" = "production" ]; then
    vercel --prod
else
    vercel
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Deployment initiated!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "${WHITE}   1. Note your Vercel URL from the output above${NC}"
echo -e "${WHITE}   2. Add that URL to your backend's ALLOWED_ORIGINS${NC}"
echo -e "${WHITE}   3. Redeploy your backend${NC}"
echo ""

# Return to root directory
cd ..
