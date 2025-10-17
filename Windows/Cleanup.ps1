# Ensure this runs with Admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Please run this script as Administrator."
    exit
}

Write-Host "`n== Setting Cleanmgr Registry Options ==" -ForegroundColor Cyan

# Registry path for Cleanmgr settings
$cleanmgrKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"

# Define the cleanup items to enable (set StateFlags100 = 2 to enable)
$cleanmgrItems = @(
    "Active Setup Temp Folders",
    "BranchCache",
    "Content Indexer Cleaner",
    "Device Driver Packages",
    "Delivery Optimization Files",
    "Downloaded Program Files",
    "Internet Cache Files",
    "Language Pack",
    "Old ChkDsk Files",
    "Previous Installations",
    "Recycle Bin",
    "Setup Log Files",
    "System error memory dump files",
    "System error minidump files",
    "Temporary Files",
    "Temporary Setup Files",
    "Thumbnail Cache",
    "Update Cleanup",
    "Upgrade Discarded Files",
    "User file versions",
    "Windows Defender",
    "Windows Error Reporting Archive Files",
    "Windows Error Reporting Queue Files",
    "Windows Error Reporting System Archive Files",
    "Windows Error Reporting System Queue Files",
    "Windows ESD installation files",
    "Windows Upgrade Log Files"
)

foreach ($item in $cleanmgrItems) {
    $regPath = Join-Path $cleanmgrKey $item
    if (Test-Path $regPath) {
        New-ItemProperty -Path $regPath -Name "StateFlags100" -Value 2 -PropertyType DWORD -Force | Out-Null
        Write-Host "Enabled cleanup for: $item"
    }
}

# Run Cleanmgr silently
Write-Host "`n== Running Cleanmgr (silent) ==" -ForegroundColor Yellow
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:100" -Wait

### --- Continue with additional PowerShell cleanup tasks ---

# Clean user temp files
Write-Host "Cleaning user temp files..." -ForegroundColor Yellow
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Windows temp
Write-Host "Cleaning Windows temp files..." -ForegroundColor Yellow
Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Empty Recycle Bin
Write-Host "Emptying Recycle Bin..." -ForegroundColor Yellow
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Clean Windows Update cache
Write-Host "Cleaning Windows Update cache..." -ForegroundColor Yellow
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue

# Clean Delivery Optimization cache
Write-Host "Cleaning Delivery Optimization files..." -ForegroundColor Yellow
Remove-Item -Path "C:\Windows\SoftwareDistribution\DeliveryOptimization\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Prefetch folder
Write-Host "Cleaning Prefetch folder..." -ForegroundColor Yellow
Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Windows Error Reporting
Write-Host "Cleaning Windows Error Reports..." -ForegroundColor Yellow
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clear event logs (optional)
Write-Host "Clearing event logs..." -ForegroundColor Yellow
wevtutil el | ForEach-Object { wevtutil cl $_ } | Out-Null

# Clear Internet Explorer/Edge legacy cache
Write-Host "Clearing browser cache..." -ForegroundColor Yellow
Start-Process -FilePath "rundll32.exe" -ArgumentList "InetCpl.cpl,ClearMyTracksByProcess 255" -Wait

Write-Host "`n== FULL SYSTEM CLEANUP COMPLETE ==" -ForegroundColor Green
