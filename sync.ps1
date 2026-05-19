$repoPath = "C:\Users\canonfans\Desktop\UnrealEngine-5.7.4-release\claude"
$debounceSeconds = 10

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repoPath
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName

$lastSync = [datetime]::MinValue

$action = {
    $now = [datetime]::Now
    if (($now - $script:lastSync).TotalSeconds -lt $debounceSeconds) { return }
    $script:lastSync = $now

    $changed = $Event.SourceEventArgs.Name
    if ($changed -match "^\.git") { return }

    Start-Sleep -Seconds 2

    Push-Location $repoPath
    $status = git status --porcelain 2>&1
    if ($status) {
        git add . 2>&1 | Out-Null
        $msg = "auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git commit -m $msg 2>&1 | Out-Null
        git push origin main 2>&1 | Out-Null
        Write-Host "[$msg] synced: $changed"
    }
    Pop-Location
}

Register-ObjectEvent $watcher Changed -Action $action | Out-Null
Register-ObjectEvent $watcher Created -Action $action | Out-Null
Register-ObjectEvent $watcher Deleted -Action $action | Out-Null
Register-ObjectEvent $watcher Renamed -Action $action | Out-Null

Write-Host "Auto-sync started. Watching: $repoPath"
Write-Host "Press Ctrl+C to stop."

try { while ($true) { Start-Sleep -Seconds 30 } }
finally { $watcher.Dispose() }
