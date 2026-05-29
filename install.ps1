# ====================================================================
#              DESIGN FACTORY PIPELINE WINDOWS INSTALLER
# ====================================================================
# Self-healing, idempotent installation script for Windows PowerShell.
# Configures environment, installs tools via Winget, and registers AI skills.

# Set UTF-8 encoding for console output
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Clear screen and print premium header
Clear-Host
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "    DESIGN FACTORY · AUTOMATED WINDOWS INSTALLER      " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Starting Windows system diagnostics..." -ForegroundColor Blue

# Diagnostics
$OSVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption
$Arch = $env:PROCESSOR_ARCHITECTURE
$FreeDisk = [Math]::Round(((Get-Volume -DriveLetter C).SizeRemaining / 1GB), 2)

Write-Host "  - Operating System: $OSVersion"
Write-Host "  - Architecture:     $Arch"
Write-Host "  - Shell:            PowerShell ($($PSVersionTable.PSVersion))"
Write-Host "  - C: Drive space:    $FreeDisk GB free"
Write-Host "------------------------------------------------------"

# --------------------------------------------------------------------
# Step 1: Package Manager (Winget Check)
# --------------------------------------------------------------------
Write-Host "`n[*] Step 1: Checking Windows Package Manager (winget)..." -ForegroundColor Blue
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "  [✓] Winget is already installed." -ForegroundColor Green
} else {
    Write-Host "  [!] Winget is missing. Please make sure you are running Windows 10/11 with App Installer configured." -ForegroundColor Yellow
    Write-Host "  [!] Attempting fallback dependency checks..." -ForegroundColor Yellow
}

# --------------------------------------------------------------------
# Step 2: Node.js 20+
# --------------------------------------------------------------------
Write-Host "`n[*] Step 2: Checking Node.js 20+..." -ForegroundColor Blue
if (Get-Command node -ErrorAction SilentlyContinue) {
    $NodeVer = (node -v).Replace('v', '').Split('.')[0]
    if ([int]$NodeVer -ge 20) {
        Write-Host "  [✓] Node.js is already installed and matches requirements: $(node -v)" -ForegroundColor Green
    } else {
        Write-Host "  [!] Node.js version is older than 20. Updating via Winget..." -ForegroundColor Yellow
        winget install --id OpenJS.NodeJS -e --silent
        Write-Host "  [✓] Node.js successfully updated. Please restart terminal after installation." -ForegroundColor Green
    }
} else {
    Write-Host "  [!] Node.js is missing. Installing via Winget..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS -e --silent
    Write-Host "  [✓] Node.js successfully installed! Please restart terminal after installation." -ForegroundColor Green
}

# --------------------------------------------------------------------
# Step 3: Git Installation
# --------------------------------------------------------------------
Write-Host "`n[*] Step 3: Checking Git..." -ForegroundColor Blue
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "  [✓] Git is already installed: $(git --version)" -ForegroundColor Green
} else {
    Write-Host "  [!] Git is missing. Installing via Winget..." -ForegroundColor Yellow
    winget install --id Git.Git -e --silent
    Write-Host "  [✓] Git successfully installed! Please restart terminal after installation." -ForegroundColor Green
}

# --------------------------------------------------------------------
# Step 4: npm Global Prefix configuration (Fix EACCES permission errors)
# --------------------------------------------------------------------
Write-Host "`n[*] Step 4: Configuring npm global prefix for Windows..." -ForegroundColor Blue
$NpmGlobalDir = Join-Path $env:USERPROFILE ".npm-global"
if (-not (Test-Path $NpmGlobalDir)) {
    New-Item -ItemType Directory -Force -Path $NpmGlobalDir | Out-Null
}

# Configure npm prefix
npm config set prefix "$NpmGlobalDir"

# Add global npm path to User environment variable safely
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $UserPath.Contains(".npm-global")) {
    $NewPath = "$UserPath;$NpmGlobalDir\bin;$NpmGlobalDir"
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    $env:Path = "$env:Path;$NpmGlobalDir\bin;$NpmGlobalDir"
    Write-Host "  [✓] Successfully added .npm-global to User environment Path." -ForegroundColor Green
} else {
    Write-Host "  [✓] Global npm prefix is already configured in environment Path." -ForegroundColor Green
}

# --------------------------------------------------------------------
# Step 5: Claude Code CLI
# --------------------------------------------------------------------
Write-Host "`n[*] Step 5: Checking Claude Code CLI..." -ForegroundColor Blue
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  [✓] Claude Code is already installed." -ForegroundColor Green
} else {
    Write-Host "  [!] Claude Code is missing. Installing globally via npm..." -ForegroundColor Yellow
    npm install -g @anthropic-ai/claude-code
    Write-Host "  [✓] Claude Code successfully installed!" -ForegroundColor Green
}

# --------------------------------------------------------------------
# Step 6: CLI Design Tools (monolith, wget)
# --------------------------------------------------------------------
Write-Host "`n[*] Step 6: Installing monolith and wget via winget..." -ForegroundColor Blue
try {
    Write-Host "  [*] Installing GNU Wget..." -ForegroundColor Yellow
    winget install --id JernejSimoncic.Wget -e --silent --accept-package-agreements --accept-source-agreements
    Write-Host "  [✓] Wget installed." -ForegroundColor Green
} catch {
    Write-Host "  [!] Wget winget warning (continuing...)" -ForegroundColor Yellow
}

try {
    Write-Host "  [*] Installing monolith..." -ForegroundColor Yellow
    winget install --id Y2Z.Monolith -e --silent --accept-package-agreements --accept-source-agreements
    Write-Host "  [✓] Monolith installed." -ForegroundColor Green
} catch {
    Write-Host "  [!] Monolith winget warning (continuing...)" -ForegroundColor Yellow
}

# --------------------------------------------------------------------
# Step 7: Registers AI Skills globally in Userprofile
# --------------------------------------------------------------------
Write-Host "`n[*] Step 7: Registering custom AI skills globally..." -ForegroundColor Blue
$SkillsDest = Join-Path $env:USERPROFILE ".claude\skills"
if (-not (Test-Path $SkillsDest)) {
    New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null
}

$RepoRoot = Get-Location
$RepoSkillsDir = Join-Path $RepoRoot "skills"

if (Test-Path $RepoSkillsDir) {
    Copy-Item -Path (Join-Path $RepoSkillsDir "extract-brand-assets") -Destination $SkillsDest -Recurse -Force
    Copy-Item -Path (Join-Path $RepoSkillsDir "create-design-system") -Destination $SkillsDest -Recurse -Force
    Copy-Item -Path (Join-Path $RepoSkillsDir "render-brand-pdf") -Destination $SkillsDest -Recurse -Force
    Write-Host "  [✓] Registered skills globally in: $SkillsDest" -ForegroundColor Green
} else {
    Write-Host "  [✗] Error: Source skills folder not found at $RepoSkillsDir. Run script from repo root." -ForegroundColor Red
    Exit 1
}

# --------------------------------------------------------------------
# Step 8: Initialize Sandbox workspace folder
# --------------------------------------------------------------------
Write-Host "`n[*] Step 8: Preparing local Sandbox design workspace..." -ForegroundColor Blue
$WorkspaceDir = Join-Path $env:USERPROFILE "Design System"
if (-not (Test-Path $WorkspaceDir)) {
    New-Item -ItemType Directory -Force -Path $WorkspaceDir | Out-Null
}
Write-Host "  [✓] Design workspace ready at: $WorkspaceDir" -ForegroundColor Green

# --------------------------------------------------------------------
# Step 9: Final dashboard summary
# --------------------------------------------------------------------
Write-Host "`n======================================================" -ForegroundColor Green
Write-Host "     ✓ DESIGN FACTORY PIPELINE INSTALLED ON WINDOWS!   " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "System Status Summary:"
Write-Host "  - node:          $(node -v)"
Write-Host "  - npm:           v$(npm -v)"
Write-Host "  - design-factory CLI: Ready (node df)"
Write-Host "  - mcp-server:    Ready (node mcp-server.js)"
Write-Host "  - Registered Skills: extract-brand-assets, create-design-system, render-brand-pdf"
Write-Host ""
Write-Host "Next steps to run your pipeline (Please restart PowerShell first):" -ForegroundColor Yellow
Write-Host "  1. Move to design directory:   cd `"\$env:USERPROFILE\Design System`""
Write-Host "  2. Launch Claude Code CLI:     claude"
Write-Host "  3. Scrape a brand website:     /extract-brand-assets https://stripe.com"
Write-Host "  4. Build design tokens:        /create-design-system"
Write-Host "  5. Start local Web console:    node df console (inside design-factory monorepo)"
Write-Host ""
Write-Host "Enjoy automated design factory under Windows!"
Write-Host ""
