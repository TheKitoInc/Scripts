# ==========================================
# OpenSSH Server Full Setup Script
# Windows 10 / Windows 11
# Run as Administrator
# ==========================================

Write-Host "=== OpenSSH Server setup starting ===" -ForegroundColor Cyan

# --- Check admin ---
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script MUST be run as Administrator"
    exit 1
}

# --- Install OpenSSH Server if missing ---
$capability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

if ($capability.State -ne "Installed") {
    Write-Host "Installing OpenSSH Server..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "OpenSSH Server already installed" -ForegroundColor Green
}

# --- Enable and start sshd service ---
Write-Host "Enabling sshd service..." -ForegroundColor Yellow
Set-Service sshd -StartupType Automatic
Start-Service sshd

# --- Optional: enable ssh-agent (useful for keys) ---
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent

# --- Firewall rule ---
$ruleName = "OpenSSH Server (sshd)"

if (-not (Get-NetFirewallRule -Name sshd -ErrorAction SilentlyContinue)) {
    Write-Host "Adding firewall rule for SSH (port 22)..." -ForegroundColor Yellow
    New-NetFirewallRule `
        -Name sshd `
        -DisplayName $ruleName `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22
} else {
    Write-Host "Firewall rule already exists" -ForegroundColor Green
}

# --- Verify ---
Write-Host ""
Write-Host "=== Verification ===" -ForegroundColor Cyan

Get-Service sshd | Select-Object Name, Status, StartType

Write-Host ""
Write-Host "SSH is ready." -ForegroundColor Green
Write-Host "Test from another machine with:" -ForegroundColor Green
Write-Host "  ssh username@this-computer-ip" -ForegroundColor White
