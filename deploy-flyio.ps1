param(
    [Parameter(Mandatory = $false)]
    [switch]$Initialize,
    
    [Parameter(Mandatory = $false)]
    [switch]$SetSecrets,
    
    [Parameter(Mandatory = $false)]
    [switch]$Deploy,
    
    [Parameter(Mandatory = $false)]
    [switch]$All
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Choose Your Own Adventure - Fly.io Deploy" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if flyctl is installed
$flyctlInstalled = Get-Command flyctl -ErrorAction SilentlyContinue
if (-not $flyctlInstalled) {
    Write-Host "ERROR: Fly.io CLI (flyctl) not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "To install flyctl:" -ForegroundColor Yellow
    Write-Host "  PowerShell: iwr https://fly.io/install.ps1 -useb | iex" -ForegroundColor White
    Write-Host "  Or visit: https://fly.io/docs/hands-on/install-flyctl/" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "SUCCESS: Fly.io CLI found" -ForegroundColor Green
Write-Host ""

# Initialize (create app)
if ($Initialize -or $All) {
    Write-Host "Initializing Fly.io application..." -ForegroundColor Blue
    Write-Host ""
    
    # Check if user is logged in
    $authStatus = flyctl auth whoami 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Not logged in to Fly.io" -ForegroundColor Yellow
        Write-Host "Opening browser for authentication..." -ForegroundColor Blue
        flyctl auth login
    }
    
    Write-Host ""
    Write-Host "App will be created from fly.toml configuration" -ForegroundColor Blue
    Write-Host "  App name: choose-your-own-adventure-ai" -ForegroundColor White
    Write-Host "  Region: iad (US East)" -ForegroundColor White
    Write-Host ""
    
    $continue = Read-Host "Continue with initialization? (y/n)"
    if ($continue -ne "y") {
        Write-Host "Initialization cancelled" -ForegroundColor Yellow
        exit 0
    }
    
    # Create app
    flyctl apps create choose-your-own-adventure-ai --org personal 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Application created" -ForegroundColor Green
    }
    else {
        Write-Host "INFO: App may already exist, continuing..." -ForegroundColor Yellow
    }
    Write-Host ""
}

# Set secrets
if ($SetSecrets -or $All) {
    Write-Host "Setting up secrets..." -ForegroundColor Blue
    Write-Host ""
    
    Write-Host "You will need the following:" -ForegroundColor Yellow
    Write-Host "  1. PostgreSQL Neon connection string" -ForegroundColor White
    Write-Host "  2. OpenAI API key" -ForegroundColor White
    Write-Host ""
    
    $continue = Read-Host "Continue with secret setup? (y/n)"
    if ($continue -ne "y") {
        Write-Host "Skipping secret setup" -ForegroundColor Yellow
    }
    else {
        Write-Host ""
        $dbUrl = Read-Host "Enter DATABASE_URL (PostgreSQL connection string)"
        $openaiKey = Read-Host "Enter OPENAI_API_KEY"
        $allowedOrigins = Read-Host "Enter ALLOWED_ORIGINS (press Enter for default)"
        
        if ([string]::IsNullOrWhiteSpace($allowedOrigins)) {
            $allowedOrigins = "https://choose-your-own-adventure-ai.fly.dev"
        }
        
        Write-Host ""
        Write-Host "Setting secrets..." -ForegroundColor Blue
        
        flyctl secrets set DATABASE_URL="$dbUrl" OPENAI_API_KEY="$openaiKey" ALLOWED_ORIGINS="$allowedOrigins" --app choose-your-own-adventure-ai
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Secrets configured" -ForegroundColor Green
        }
        else {
            Write-Host "ERROR: Failed to set secrets" -ForegroundColor Red
            exit 1
        }
    }
    Write-Host ""
}

# Deploy
if ($Deploy -or $All) {
    Write-Host "Deploying application..." -ForegroundColor Blue
    Write-Host ""
    
    flyctl deploy --app choose-your-own-adventure-ai
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "SUCCESS: Deployment complete!" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Your app is available at:" -ForegroundColor Yellow
        Write-Host "  https://choose-your-own-adventure-ai.fly.dev" -ForegroundColor White
        Write-Host ""
        Write-Host "Useful commands:" -ForegroundColor Yellow
        Write-Host "  flyctl status --app choose-your-own-adventure-ai" -ForegroundColor White
        Write-Host "  flyctl logs --app choose-your-own-adventure-ai" -ForegroundColor White
        Write-Host "  flyctl open --app choose-your-own-adventure-ai" -ForegroundColor White
        Write-Host ""
    }
    else {
        Write-Host ""
        Write-Host "ERROR: Deployment failed" -ForegroundColor Red
        Write-Host "Check logs with: flyctl logs --app choose-your-own-adventure-ai" -ForegroundColor Yellow
        exit 1
    }
}

# If no flags provided, show usage
if (-not ($Initialize -or $SetSecrets -or $Deploy -or $All)) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\deploy-flyio.ps1 -All          # Complete setup" -ForegroundColor White
    Write-Host "  .\deploy-flyio.ps1 -Initialize   # Create app" -ForegroundColor White
    Write-Host "  .\deploy-flyio.ps1 -SetSecrets   # Configure secrets" -ForegroundColor White
    Write-Host "  .\deploy-flyio.ps1 -Deploy       # Deploy" -ForegroundColor White
    Write-Host ""
}
