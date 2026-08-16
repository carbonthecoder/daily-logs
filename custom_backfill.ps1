param (
    [string]$StartDateStr = "2024-01-01",
    [string]$EndDateStr = "2026-08-16"
)

$StartDate = [datetime]::ParseExact($StartDateStr, 'yyyy-MM-dd', $null)
$EndDate = [datetime]::ParseExact($EndDateStr, 'yyyy-MM-dd', $null)

$batContent = "@echo off`n"

$currentDate = $StartDate
$commitCount = 0

while ($currentDate -le $EndDate) {
    $commitsToday = 0
    $year = $currentDate.Year
    $month = $currentDate.Month
    $dow = $currentDate.DayOfWeek

    if ($year -eq 2024) {
        if ($month -eq 1) {
            # Only in Jan
            if ((Get-Random -Min 1 -Max 100) -le 60) { $commitsToday = Get-Random -Min 2 -Max 8 }
        } elseif ($month -ge 4 -and $month -le 9) {
            # Leave 1-2 months (Feb, Mar), then 6 months enough (Apr-Sep)
            if ((Get-Random -Min 1 -Max 100) -le 50) { $commitsToday = Get-Random -Min 3 -Max 12 }
        }
    } elseif ($year -eq 2025) {
        if ($month -eq 5 -or $month -eq 6) {
            # Summer holidays as hell contrib
            if ((Get-Random -Min 1 -Max 100) -le 90) { $commitsToday = Get-Random -Min 15 -Max 30 }
        } elseif ($month -ge 7) {
            # Last 6 months like 20-30 total (spread thinly)
            if ((Get-Random -Min 1 -Max 100) -le 15) { $commitsToday = Get-Random -Min 1 -Max 3 }
        } else {
            # Jan-Apr 2025 less cuz 10th grade
            if ((Get-Random -Min 1 -Max 100) -le 10) { $commitsToday = 1 }
        }
    } elseif ($year -eq 2026) {
        if ($month -ge 2) {
            # Feb to today around 20 daily, random shuffle, most in weekends
            $chance = 60
            $min = 0
            $max = 15
            if ($dow -eq 'Saturday' -or $dow -eq 'Sunday') {
                $chance = 85
                $min = 15
                $max = 25
            } else {
                $chance = 45
                $min = 5
                $max = 20
            }
            if ((Get-Random -Min 1 -Max 100) -le $chance) { 
                $commitsToday = Get-Random -Min $min -Max $max 
            }
        }
    }

    if ($commitsToday -gt 0) {
        for ($i = 1; $i -le $commitsToday; $i++) {
            $hour = Get-Random -Minimum 10 -Maximum 23
            $min = Get-Random -Minimum 0 -Maximum 60
            $sec = Get-Random -Minimum 0 -Maximum 60
            
            $formattedDate = $currentDate.AddHours($hour).AddMinutes($min).AddSeconds($sec).ToString("yyyy-MM-ddTHH:mm:ss")
            
            $batContent += "set GIT_AUTHOR_DATE=$formattedDate`n"
            $batContent += "set GIT_COMMITTER_DATE=$formattedDate`n"
            $batContent += "git commit --allow-empty -m `"Custom backfill $formattedDate`" --quiet`n"
            $commitCount++
        }
    }
    
    $currentDate = $currentDate.AddDays(1)
}

Set-Content -Path "run_custom_commits.bat" -Value $batContent
Write-Host "Generated run_custom_commits.bat with $commitCount commits. Executing..."
cmd.exe /c run_custom_commits.bat
Remove-Item "run_custom_commits.bat"
Write-Host "Done!"
