<#
.SYNOPSIS
    Master Orchestration Script for Self-Hosted IW4x Dedicated Server + IW4MAdmin
.DESCRIPTION
    Automates directory validation, firewall rules, server.cfg generation, 
    mod integration (Specialist Perks), and concurrent service execution.
#>

# --- CONFIGURATION VARIABLES ---
$BaseServerDir = "C:\GameServers\MW2-Server"
$AdminDir     = "C:\GameServers\IW4MAdmin"
$ModName      = "specialist"
$ServerPort   = 28960
$RconPass     = "YourSecureRconPasswordHere"
$ServerName   = "^2[SPECIALIST] ^7Custom MW2 | 8-Kill Perk Bonus"

Write-Host "[*] Initializing IW4x Server Orchestration..." -ForegroundColor Cyan

# 1. Validate Base Directories
if (!(Test-Path $BaseServerDir)) {
    Write-Error "Base server directory not found at $BaseServerDir. Please populate your base MW2 server files first."
    exit
}

if (!(Test-Path $AdminDir)) {
    Write-Error "IW4MAdmin directory not found at $AdminDir. Please extract IW4MAdmin there first."
    exit
}

# 2. Configure Windows Firewall Rules for UDP Port
Write-Host "[*] Verifying Firewall Rules for Port $ServerPort..." -ForegroundColor Yellow
$RuleName = "IW4x-Dedicated-Server"
$ExistingRule = Get-NetFirewallRule -Name $RuleName -ErrorAction SilentlyContinue
if (!$ExistingRule) {
    New-NetFirewallRule -DisplayName "IW4x Server Port" -Name $RuleName -Direction Inbound -Protocol UDP -LocalPort $ServerPort -Action Allow | Out-Null
    New-NetFirewallRule -DisplayName "IW4x Server Port Out" -Name "$RuleName-Out" -Direction Outbound -Protocol UDP -LocalPort $ServerPort -Action Allow | Out-Null
    Write-Host "[+] Firewall rules created successfully." -ForegroundColor Green
} else {
    Write-Host "[+] Firewall rules already active." -ForegroundColor Green
}

# 3. Write / Verify Optimized server.cfg
$ConfigDir = Join-Path $BaseServerDir "userraw"
if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir | Out-Null }
$ConfigFilePath = Join-Path $ConfigDir "server.cfg"

$ConfigContent = @"
// --- AUTOMATED SERVER CONFIGURATION ---
set sv_hostname "$ServerName"
set sv_motd "Welcome! Specialist Perks are enabled. Go on an 8-kill streak to unlock all Pro perks!"
set rcon_password "$RconPass"
set g_logSync "2"
set g_log "games_mp.log"
set scr_game_perks "1"
set scr_game_hardpoints "1"
set g_hardcore "0"
set sv_maxclients "18"
set sv_maprotation "gametype war map mp_rust gametype war map mp_terminal gametype war map mp_highrise"
"@

Set-Content -Path $ConfigFilePath -Value $ConfigContent
Write-Host "[+] server.cfg successfully synchronized." -ForegroundColor Green

# 4. Launch IW4x Dedicated Server Process
$ExePath = Join-Path $BaseServerDir "iw4x.exe"
$ModPath = "mods/$ModName"

Write-Host "[*] Launching IW4x Dedicated Server Instance..." -ForegroundColor Cyan
$ServerArgs = "-pTY -dedicated -disable-mod-unloading +set fs_game `"$ModPath`" +set net_port $ServerPort +exec server.cfg +map_rotate"

$ServerProcess = Start-Process -FilePath $ExePath -ArgumentList $ServerArgs -WorkingDirectory $BaseServerDir -PassThru
Write-Host "[+] IW4x Server running with PID: $($ServerProcess.Id)" -ForegroundColor Green

Start-Sleep -Seconds 3

# 5. Launch IW4MAdmin Process
$AdminExecutable = Join-Path $AdminDir "IW4MAdmin.exe"
if (Test-Path $AdminExecutable) {
    Write-Host "[*] Launching IW4MAdmin Moderation Suite..." -ForegroundColor Cyan
    $AdminProcess = Start-Process -FilePath $AdminExecutable -WorkingDirectory $AdminDir -PassThru
    Write-Host "[+] IW4MAdmin running with PID: $($AdminProcess.Id)" -ForegroundColor Green
} else {
    Write-Warning "IW4MAdmin executable not found in $AdminDir. Start it manually if needed."
}

Write-Host "[SUCCESS] All systems operational! Press any key to stop management monitoring..." -ForegroundColor Cyan
[void][System.Console]::ReadKey($true)