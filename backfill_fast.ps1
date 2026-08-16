param (
    [string]$StartDateStr = "2024-01-01",
    [string]$EndDateStr = "2024-12-31"
)

$StartDate = [datetime]::ParseExact($StartDateStr, 'yyyy-MM-dd', $null)
$EndDate = [datetime]::ParseExact($EndDateStr, 'yyyy-MM-dd', $null)

$batContent = "@echo off`n"

$currentDate = $StartDate
$commitCount = 0

while ($currentDate -le $EndDate) {
    if ((Get-Random -Minimum 1 -Maximum 101) -le 70) {
        $commitsToday = Get-Random -Minimum 3 -Maximum 21
        
        for ($i = 1; $i -le $commitsToday; $i++) {
            $hour = Get-Random -Minimum 10 -Maximum 23
            $min = Get-Random -Minimum 0 -Maximum 60
            $sec = Get-Random -Minimum 0 -Maximum 60
            
            $formattedDate = $currentDate.AddHours($hour).AddMinutes($min).AddSeconds($sec).ToString("yyyy-MM-ddTHH:mm:ss")
            
            $batContent += "set GIT_AUTHOR_DATE=$formattedDate`n"
            $batContent += "set GIT_COMMITTER_DATE=$formattedDate`n"
            $batContent += "git commit --allow-empty -m `"Backfill $formattedDate`" --quiet`n"
            $commitCount++
        }
    }
    $currentDate = $currentDate.AddDays(1)
}

Set-Content -Path "run_commits.bat" -Value $batContent
Write-Host "Generated run_commits.bat with $commitCount commits. Executing..."
cmd.exe /c run_commits.bat
Remove-Item "run_commits.bat"
Write-Host "Done!"
