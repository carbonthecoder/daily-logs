param (
    [string]$StartDateStr = "2024-01-01",
    [string]$EndDateStr = "2024-12-31",
    [int]$MinCommits = 3,
    [int]$MaxCommits = 20,
    [int]$ActiveDayPercentage = 70
)

$StartDate = [datetime]::ParseExact($StartDateStr, 'yyyy-MM-dd', $null)
$EndDate = [datetime]::ParseExact($EndDateStr, 'yyyy-MM-dd', $null)

Write-Host "Starting backfill from $StartDateStr to $EndDateStr"

$currentDate = $StartDate
$commitCount = 0

while ($currentDate -le $EndDate) {
    # Skip some days randomly
    $randPercent = Get-Random -Minimum 1 -Maximum 101
    if ($randPercent -le $ActiveDayPercentage) {
        $commitsToday = Get-Random -Minimum $MinCommits -Maximum ($MaxCommits + 1)
        
        for ($i = 1; $i -le $commitsToday; $i++) {
            # Randomize the time slightly during the day (between 10 AM and 10 PM)
            $hour = Get-Random -Minimum 10 -Maximum 23
            $minute = Get-Random -Minimum 0 -Maximum 60
            $second = Get-Random -Minimum 0 -Maximum 60
            
            $commitDate = $currentDate.AddHours($hour).AddMinutes($minute).AddSeconds($second)
            
            # Format expected by Git: ISO 8601 or similar (RFC 2822)
            $formattedDate = $commitDate.ToString("yyyy-MM-ddTHH:mm:ss")
            
            $content = "Backfill commit on $formattedDate - $i"
            Set-Content -Path "daily_update.txt" -Value $content
            
            git add daily_update.txt
            
            $env:GIT_AUTHOR_DATE = $formattedDate
            $env:GIT_COMMITTER_DATE = $formattedDate
            
            git commit -m "Auto backfill for $formattedDate" --quiet
            $commitCount++
        }
        Write-Host "Generated $commitsToday commits for $($currentDate.ToString('yyyy-MM-dd'))"
    }
    
    $currentDate = $currentDate.AddDays(1)
}

$env:GIT_AUTHOR_DATE = $null
$env:GIT_COMMITTER_DATE = $null

Write-Host "Backfill complete! Generated $commitCount total commits. Run 'git push' to upload."
