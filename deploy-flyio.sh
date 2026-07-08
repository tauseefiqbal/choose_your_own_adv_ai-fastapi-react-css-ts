#!/bin/bash
# Fly.io Deployment Script for Choose Your Own Adventure AI

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
INITIALIZE=false
SET_SECRETS=false
DEPLOY=false
ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --initialize|-i)
            INITIALIZE=true
            shift
            ;;
        --secrets|-s)
            SET_SECRETS=true
            shift
            ;;
        --deploy|-d)
            DEPLOY=true
            shift
            ;;
        --all|-a)
            ALL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Choose Your Own Adventure - Fly.io Deployment${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo -e "${RED}❌ Fly.io CLI (flyctl) not found.${NC}"
    echo ""
    echo -e "${YELLOW}📥 To install flyctl:${NC}"
    echo -e "${WHITE}   Linux/Mac: curl -L https://fly.io/install.sh | sh${NC}"
    echo -e "${WHITE}   Or visit: https://fly.io/docs/hands-on/install-flyctl/${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Fly.io CLI found${NC}"
echo ""

# Initialize
if [ "$INITIALIZE" = true ] || [ "$ALL" = true ]; then
    echo -e "${BLUE}🚀 Initializing Fly.io application...${NC}"
    echo ""
    
    # Check if logged in
    if ! flyctl auth whoami &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not logged in to Fly.io${NC}"
        echo -e "${BLUE}🔐 Opening browser for authentication...${NC}"
        flyctl auth login
    fi
    
    echo ""
    echo -e "${BLUE}📋 App will be created from fly.toml configuration${NC}"
    echo -e "${WHITE}   App name: choose-your-own-adventure-ai${NC}"
    echo -e "${WHITE}   Region: iad (US East)${NC}"
    echo ""
    
    read -p "Continue with initialization? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}❌ Initialization cancelled${NC}"
        exit 0
    fi
    
    flyctl apps create choose-your-own-adventure-ai --org personal 2>&1 || echo -e "${YELLOW}ℹ️  App may already exist, continuing...${NC}"
    echo -e "${GREEN}✓ Application ready${NC}"
    echo ""
fi

# Set secrets
if [ "$SET_SECRETS" = true ] || [ "$ALL" = true ]; then
    echo -e "${BLUE}🔒 Setting up secrets...${NC}"
    echo ""
    
    echo -e "${YELLOW}⚠️  You'll need the following:${NC}"
    echo -e "${WHITE}   1. PostgreSQL Neon connection string${NC}"
    echo -e "${WHITE}   2. OpenAI API key${NC}"
    echo ""
    
    read -p "Continue with secret setup? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏭️  Skipping secret setup${NC}"
    else
        echo ""
        read -p "Enter DATABASE_URL (PostgreSQL connection string): " dbUrl
        read -p "Enter OPENAI_API_KEY: " openaiKey
        read -p "Enter ALLOWED_ORIGINS (or press Enter for default): " allowedOrigins
        
        if [ -z "$allowedOrigins" ]; then
            allowedOrigins="https://choose-your-own-adventure-ai.fly.dev"
        fi
        
        echo ""
        echo -e "${BLUE}🔐 Setting secrets...${NC}"
        
        flyctl secrets set \
            DATABASE_URL="$dbUrl" \
            OPENAI_API_KEY="$openaiKey" \
            ALLOWED_ORIGINS="$allowedOrigins" \
            --app choose-your-own-adventure-ai
        
        echo -e "${GREEN}✓ Secrets configured successfully${NC}"
    fi
    echo ""
fi

# Deploy
if [ "$DEPLOY" = true ] || [ "$ALL" = true ]; then
    echo -e "${BLUE}🚀 Deploying application...${NC}"
    echo ""
    
    flyctl deploy --app choose-your-own-adventure-ai
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ Deployment successful!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}🌐 Your app is available at:${NC}"
    echo -e "${WHITE}   https://choose-your-own-adventure-ai.fly.dev${NC}"
    echo ""
    echo -e "${YELLOW}📊 Useful commands:${NC}"
    echo -e "${WHITE}   flyctl status --app choose-your-own-adventure-ai${NC}"
    echo -e "${WHITE}   flyctl logs --app choose-your-own-adventure-ai${NC}"
    echo -e "${WHITE}   flyctl open --app choose-your-own-adventure-ai${NC}"
    echo ""
fi

# Show usage if no flags
if [ "$INITIALIZE" = false ] && [ "$SET_SECRETS" = false ] && [ "$DEPLOY" = false ] && [ "$ALL" = false ]; then
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "${WHITE}  ./deploy-flyio.sh --all|-a              # Complete setup${NC}"
    echo -e "${WHITE}  ./deploy-flyio.sh --initialize|-i       # Create app${NC}"
    echo -e "${WHITE}  ./deploy-flyio.sh --secrets|-s          # Set secrets${NC}"
    echo -e "${WHITE}  ./deploy-flyio.sh --deploy|-d           # Deploy${NC}"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "${WHITE}  # First time:${NC}"
    echo -e "${CYAN}  ./deploy-flyio.sh --all${NC}"
    echo ""
    echo -e "${WHITE}  # Update:${NC}"
    echo -e "${CYAN}  ./deploy-flyio.sh --deploy${NC}"
    echo ""
fi
