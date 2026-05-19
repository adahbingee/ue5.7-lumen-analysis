param([string]$RepoPath = "C:\Users\canonfans\Desktop\UnrealEngine-5.7.4-release\claude")

function Sync-Repo {
    Push-Location $RepoPath
    $status = git status --porcelain 2>&1
    if ($status) {
        git add . 2>&1 | Out-Null
        $msg = "auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git commit -m $msg 2>&1 | Out-Null
        $push = git push origin main 2>&1
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Synced to GitHub"
    }
    Pop-Location
}

Write-Host "Auto-sync started. Watching: $RepoPath (polling every 30s)"
Write-Host "Press Ctrl+C to stop."

while ($true) {
    Sync-Repo
    Start-Sleep -Seconds 30
}
