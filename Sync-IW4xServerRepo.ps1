<#
.SYNOPSIS
    Automated IW4x Missing Asset Generator & GitHub Sync Script
.DESCRIPTION
    1. Creates missing Windows (.bat) and Linux (.sh) server launcher scripts.
    2. Stages all modified and new repository files.
    3. Commits locally with a custom or timestamped message.
    4. Pushes securely to the remote main branch on GitHub.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$CommitMessage = "Add missing Windows/Linux server launchers and sync repository"
)

Write-Host "[*] Step 1: Generating missing launcher files..." -ForegroundColor Cyan

# 1. Create Windows Batch Launcher
$WindowsBatPath = "DedicatedServer.bat"
$WindowsBatContent = @'
@echo off
title IW4x Dedicated Server
cls
echo Starting IW4x Dedicated Server...
iw4x.exe -dedicated -disable-mod-unloading +set fs_game "mods/specialist" +exec server.cfg +map_rotate
pause
'@
Set-Content -Path $WindowsBatPath -Value $WindowsBatContent -Encoding ascii
Write-Host "[+] Created: $WindowsBatPath" -ForegroundColor Green

# 2. Create Linux Shell Launcher
$LinuxShPath = "DedicatedServer.sh"
$LinuxShContent = @'
#!/bin/bash
echo "Starting IW4x Dedicated Server..."
./iw4x.x86_64 -dedicated -disable-mod-unloading +set fs_game "mods/specialist" +exec server.cfg +map_rotate
'@
Set-Content -Path $LinuxShPath -Value $LinuxShContent -Encoding ascii
Write-Host "[+] Created: $LinuxShPath" -ForegroundColor Green

Write-Host "`n[*] Step 2: Interfacing with Git..." -ForegroundColor Cyan

# 3. Check Git Status
git status

# 4. Stage all changes (including newly created files)
Write-Host "[*] Staging all files..." -ForegroundColor Yellow
git add .

# 5. Commit locally
Write-Host "[*] Committing changes with message: '$CommitMessage'" -ForegroundColor Yellow
git commit -m "$CommitMessage"

if ($LASTEXITCODE -ne 0) {
    Write-Warning "No changes detected to commit, or commit skipped."
}

# 6. Push to GitHub main branch
Write-Host "[*] Pushing to remote repository (origin/main)..." -ForegroundColor Cyan
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] All missing files created, committed, and successfully pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Error "[ERROR] Push failed. Verify your branch alignment or Personal Access Token permissions."
}
