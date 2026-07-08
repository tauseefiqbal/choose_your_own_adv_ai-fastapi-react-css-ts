#!/usr/bin/env pwsh
# Quick deployment script for Vercel frontend + separate backend

param(
    [Parameter(Mandatory = $false)]
    [string]$BackendUrl = "",
    
    [Parameter(Mandatory = $false)]
    [switch]$Production
)

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Choose Your Own Adventure - Deployment Script" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check if Vercel CLI is installed
$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue
if (-not $vercelInstalled) {
    Write-Host "❌ Vercel CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g vercel
}

# Check if backend URL is provided
if (-not $BackendUrl) {
    Write-Host "⚠️  No backend URL provided." -ForegroundColor Yellow
    $BackendUrl = Read-Host "Enter your backend URL (e.g., https://your-app.onrender.com)"
}

Write-Host ""
Write-Host "📝 Configuration:" -ForegroundColor Green
Write-Host "   Backend URL: $BackendUrl" -ForegroundColor White
Write-Host "   Environment: $(if ($Production) { 'Production' } else { 'Preview' })" -ForegroundColor White
Write-Host ""

# Create .env.production file
Write-Host "🔧 Creating frontend/.env.production..." -ForegroundColor Blue
$envContent = @"
VITE_API_URL=$BackendUrl
VITE_DEBUG=false
"@
Set-Content -Path "frontend/.env.production" -Value $envContent

# Navigate to frontend directory
Set-Location frontend

# Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Blue
    npm install
}

# Build frontend
Write-Host "🏗️  Building frontend..." -ForegroundColor Blue
npm run build

# Deploy to Vercel
Write-Host "🚀 Deploying to Vercel..." -ForegroundColor Blue
if ($Production) {
    vercel --prod
}
else {
    vercel
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  ✅ Deployment initiated!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Note your Vercel URL from the output above" -ForegroundColor White
Write-Host "   2. Add that URL to your backend's ALLOWED_ORIGINS" -ForegroundColor White
Write-Host "   3. Redeploy your backend" -ForegroundColor White
Write-Host ""

# Return to root directory
Set-Location ..
