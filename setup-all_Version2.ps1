# ====================================================
# Setup AI Tools - Complete Online Installation
# ====================================================

[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "Starting Online Installation..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan

# Check Administrator Rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "WARNING: Run PowerShell as Administrator!" -ForegroundColor Red
    Write-Host "How: Right-click PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    exit
}

# ====================================================
# Step 1: Create Required Folders
# ====================================================

Write-Host "`nStep 1: Creating Directories..." -ForegroundColor Cyan

$configPath = "$env:USERPROFILE\.ai-tools-config"
$scriptsPath = "$configPath\scripts"
$logsPath = "$configPath\logs"

foreach ($path in @($configPath, $scriptsPath, $logsPath)) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "[OK] Created: $path" -ForegroundColor Green
    } else {
        Write-Host "[EXISTS] $path" -ForegroundColor Gray
    }
}

# ====================================================
# Step 2: Install Chocolatey
# ====================================================

Write-Host "`nStep 2: Checking Chocolatey..." -ForegroundColor Cyan

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "[INSTALLING] Chocolatey..." -ForegroundColor Yellow
    
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    
    try {
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "[OK] Chocolatey Installed" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to install Chocolatey: $_" -ForegroundColor Red
        exit
    }
} else {
    Write-Host "[OK] Chocolatey already installed" -ForegroundColor Gray
}

# ====================================================
# Step 3: Install Programs
# ====================================================

Write-Host "`nStep 3: Installing Programs..." -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor White

$programs = @{
    'git' = 'Git'
    'cursor' = 'Cursor IDE'
    'vscode' = 'VS Code'
}

foreach ($program in $programs.Keys) {
    $displayName = $programs[$program]
    Write-Host "[INSTALL] $displayName..." -ForegroundColor Yellow
    
    try {
        choco install $program -y --no-progress 2>&1 | Out-Null
        Write-Host "[OK] $displayName installed" -ForegroundColor Green
    }
    catch {
        Write-Host "[WARNING] Error installing $displayName" -ForegroundColor Yellow
    }
}

Write-Host "================================================================" -ForegroundColor White

# ====================================================
# Step 4: Install Windsurf (Manual)
# ====================================================

Write-Host "`nStep 4: Windsurf IDE (Manual Download)" -ForegroundColor Cyan
Write-Host "[INFO] Opening Windsurf download page..." -ForegroundColor Yellow

$windsurf_url = "https://codeium.com/windsurf"
Start-Process $windsurf_url

Write-Host "[WAIT] Please download Windsurf from the opened page" -ForegroundColor Yellow
Read-Host "Press Enter when done"

# ====================================================
# Step 5: Install GitHub Copilot
# ====================================================

Write-Host "`nStep 5: Installing GitHub Copilot Extensions..." -ForegroundColor Cyan

try {
    code --install-extension GitHub.Copilot --force 2>&1 | Out-Null
    code --install-extension GitHub.Copilot-Chat --force 2>&1 | Out-Null
    Write-Host "[OK] GitHub Copilot installed" -ForegroundColor Green
}
catch {
    Write-Host "[WARNING] You may need to install extensions manually" -ForegroundColor Yellow
}

# ====================================================
# Step 6: Create Configuration Files
# ====================================================

Write-Host "`nStep 6: Creating Configuration Files..." -ForegroundColor Cyan

# Settings Config
$settingsConfig = @"
# ==============================================
# AI Tools Configuration
# ==============================================

DAILY_TOKEN_LIMIT=100000
WARNING_THRESHOLD=80000
CRITICAL_THRESHOLD=95000

USE_CURSOR=true
USE_WINDSURF=true
USE_COPILOT_FREE=true

ENABLE_WARNINGS=true
LOG_USAGE=true
AUTO_BACKUP=true

INSTALL_DATE=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
CONFIG_VERSION=1.0
"@
$settingsConfig | Out-File -FilePath "$configPath\settings.conf" -Encoding UTF8
Write-Host "[OK] Created settings.conf" -ForegroundColor Green

# Usage Tracker
$usageTracker = @"
# ==============================================
# Daily Usage Tracker
# Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# ==============================================
# Format: Date | Time | Tool | Tokens | Status
# ==============================================

"@
$usageTracker | Out-File -FilePath "$configPath\usage-tracker.txt" -Encoding UTF8
Write-Host "[OK] Created usage-tracker.txt" -ForegroundColor Green

# Daily Reminder
$reminderFile = @"
# ==============================================
# Daily Token Limit Reminder
# Last Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# ==============================================

Token Limits:
- Daily Limit: 100,000 tokens
- Warning Level: 80,000 tokens
- Critical Level: 95,000 tokens

Tips to Save Tokens:
1. Use Cursor for complex tasks (fewer tokens)
2. Use Windsurf for Flow mode
3. Write clear and concise prompts
4. Use file context wisely

Configuration Files:
- settings.conf
- usage-tracker.txt
- monitor-usage.ps1
- shortcuts.ps1
"@
$reminderFile | Out-File -FilePath "$configPath\DAILY-REMINDER.md" -Encoding UTF8
Write-Host "[OK] Created DAILY-REMINDER.md" -ForegroundColor Green

# ====================================================
# Step 7: Create Main Shortcuts File
# ====================================================

Write-Host "`nStep 7: Creating Shortcuts..." -ForegroundColor Cyan

$mainShortcutsFile = @"
# ==============================================
# AI Tools Shortcuts - Auto Load
# ==============================================

# Main Tools
function cursor {
    param([string]`$Path = '.')
    & 'C:\Program Files\Cursor\Cursor.exe' `$Path
}

function windsurf {
    param([string]`$Path = '.')
    & 'C:\Program Files\Windsurf\Windsurf.exe' `$Path
}

function vscode {
    param([string]`$Path = '.')
    code `$Path
}

# Monitoring
function tokens {
    Write-Host "`nToken Usage Report:" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor White
    Get-Content "$env:USERPROFILE\.ai-tools-config\usage-tracker.txt"
}

function check-limit {
    Write-Host "`nDaily Limit Status:" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor White
    Get-Content "$env:USERPROFILE\.ai-tools-config\settings.conf" | Select-String "LIMIT|THRESHOLD"
}

function show-reminder {
    Get-Content "$env:USERPROFILE\.ai-tools-config\DAILY-REMINDER.md" | Out-Host
}

function open-config {
    Start-Process explorer "$env:USERPROFILE\.ai-tools-config"
}

# Maintenance
function reload-shortcuts {
    . "$env:USERPROFILE\.ai-tools-config\shortcuts.ps1"
    Write-Host "[OK] Shortcuts reloaded" -ForegroundColor Green
}

function reset-daily-usage {
    Clear-Content "$env:USERPROFILE\.ai-tools-config\usage-tracker.txt"
    Write-Host "[OK] Daily usage reset" -ForegroundColor Green
}

function update-tools {
    choco upgrade cursor vscode git -y
    Write-Host "[OK] Tools updated" -ForegroundColor Green
}

# Display available commands
Write-Host "`n[OK] Shortcuts loaded!" -ForegroundColor Green
Write-Host "`nAvailable Commands:" -ForegroundColor Cyan
Write-Host "  Tools:" -ForegroundColor White
Write-Host "    cursor .         - Open Cursor" -ForegroundColor Gray
Write-Host "    windsurf .       - Open Windsurf" -ForegroundColor Gray
Write-Host "    vscode .         - Open VS Code" -ForegroundColor Gray
Write-Host "  Monitoring:" -ForegroundColor White
Write-Host "    tokens           - Show token usage" -ForegroundColor Gray
Write-Host "    check-limit      - Check daily limits" -ForegroundColor Gray
Write-Host "    show-reminder    - Show reminder" -ForegroundColor Gray
Write-Host "  Maintenance:" -ForegroundColor White
Write-Host "    open-config      - Open config folder" -ForegroundColor Gray
Write-Host "    reload-shortcuts - Reload shortcuts" -ForegroundColor Gray
Write-Host "    reset-daily-usage- Reset today's usage" -ForegroundColor Gray
Write-Host "    update-tools     - Update all programs" -ForegroundColor Gray
Write-Host ""
"@

$mainShortcutsFile | Out-File -FilePath "$configPath\shortcuts.ps1" -Encoding UTF8
Write-Host "[OK] Created shortcuts.ps1" -ForegroundColor Green

# ====================================================
# Step 8: Update PowerShell Profile
# ====================================================

Write-Host "`nStep 8: Updating PowerShell Profile..." -ForegroundColor Cyan

$profilePath = $PROFILE.CurrentUserAllHosts

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = @"
# ==============================================
# PowerShell Profile - AI Tools Auto-Load
# ==============================================

[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
`$PSDefaultParameterValues['*:Encoding'] = 'utf8'

. "`$env:USERPROFILE\.ai-tools-config\shortcuts.ps1"
"@

if (-not (Get-Content $profilePath | Select-String "AI Tools Auto-Load")) {
    Add-Content -Path $profilePath -Value $profileContent
    Write-Host "[OK] PowerShell Profile updated" -ForegroundColor Green
} else {
    Write-Host "[EXISTS] Profile already configured" -ForegroundColor Gray
}

# ====================================================
# Final Summary
# ====================================================

Write-Host "`n" -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Green
Write-Host "[SUCCESS] Installation Complete!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green

Write-Host "`nInstalled Programs:" -ForegroundColor Cyan
Write-Host "  [OK] Cursor IDE" -ForegroundColor White
Write-Host "  [OK] VS Code + GitHub Copilot" -ForegroundColor White
Write-Host "  [OK] Git" -ForegroundColor White
Write-Host "  [MANUAL] Windsurf IDE" -ForegroundColor Yellow

Write-Host "`nConfiguration Path:" -ForegroundColor Cyan
Write-Host "  $configPath" -ForegroundColor Green

Write-Host "`nCreated Files:" -ForegroundColor Cyan
Write-Host "  * settings.conf - Main configuration" -ForegroundColor White
Write-Host "  * usage-tracker.txt - Token usage tracking" -ForegroundColor White
Write-Host "  * shortcuts.ps1 - Quick commands" -ForegroundColor White
Write-Host "  * DAILY-REMINDER.md - Daily reminder" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Close this PowerShell window completely" -ForegroundColor White
Write-Host "  2. Open a new PowerShell window (shortcuts load automatically)" -ForegroundColor White
Write-Host "  3. Try: cursor . or windsurf ." -ForegroundColor White

Write-Host "`nQuick Start:" -ForegroundColor Magenta
Write-Host "  . '$configPath\shortcuts.ps1'" -ForegroundColor Green
Write-Host "  cursor ." -ForegroundColor Green

Write-Host "`n" -ForegroundColor White
Read-Host "Press Enter to exit"