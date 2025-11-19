# Start Microsoft Edge with Remote Debugging
# Usage: Right-click this file and select "Run with PowerShell"
#        OR in PowerShell: .\start-edge-debug.ps1

param(
    [string]$Port = "5173",
    [string]$DebugPort = "9222"
)

Write-Host "Starting Edge with debugging enabled..." -ForegroundColor Cyan

# Kill existing Edge processes
Write-Host "Closing existing Edge windows..." -ForegroundColor Yellow
Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start Edge with remote debugging
$EdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$UserDataDir = "$env:TEMP\edge-debug"
$Url = "http://localhost:$Port"

$Args = @(
    "--remote-debugging-port=$DebugPort",
    "--user-data-dir=$UserDataDir",
    "--no-first-run",
    "--no-default-browser-check",
    $Url
)

Write-Host "Starting Edge at $Url with debug port $DebugPort..." -ForegroundColor Green
Start-Process -FilePath $EdgePath -ArgumentList $Args

# Verify
Start-Sleep -Seconds 3
$Connection = Get-NetTCPConnection -LocalPort $DebugPort -ErrorAction SilentlyContinue

if ($Connection) {
    Write-Host ""
    Write-Host "SUCCESS! Edge is running with debugging enabled." -ForegroundColor Green
    Write-Host "  Debug Port: $DebugPort" -ForegroundColor Cyan
    Write-Host "  App URL: $Url" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps in Neovim:" -ForegroundColor Yellow
    Write-Host "  1. Open your file (e.g., :e src/routes/login/+page.svelte)" -ForegroundColor White
    Write-Host "  2. Set breakpoint with <leader>b" -ForegroundColor White
    Write-Host "  3. Press F5" -ForegroundColor White
    Write-Host "  4. Select '🌐 Debug: Attach to Edge (Manual Start)'" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "WARNING: Edge started but debug port not detected yet." -ForegroundColor Yellow
    Write-Host "Wait 5 seconds and check with: Get-NetTCPConnection -LocalPort $DebugPort" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
