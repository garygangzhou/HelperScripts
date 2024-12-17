
# Get today's date
$today = (Get-Date).Date

######## For Testing #######################################################
# $today = Get-Date  -Date  "2024-11-16 11:20:33pm"
# $today = $today.Date
############################################################################

# Get the first day of the month, and all Tuesdays in the month
$firstDayOfMonth = Get-Date -Year $today.Year -Month $today.Month -Day 1
$tuesdays = @()
for ($i = 0; $i -lt [DateTime]::DaysInMonth($today.Year, $today.Month); $i++) {
    $day = $firstDayOfMonth.AddDays($i)
    if ($day.DayOfWeek -eq [DayOfWeek]::Tuesday) {
        $tuesdays += $day
    }
}

$saturdayAfterSecondTuesday = $tuesdays[1].AddDays(4).Date
# Output the result
Write-Output "The Saturday after the second Tuesday of the month is $($saturdayAfterSecondTuesday.ToShortDateString())."

######## For Testing #######################################################
# $saturdayAfterSecondTuesday = Get-Date  -Date  "2024-11-16"
# Write-Output $saturdayAfterSecondTuesday 
############################################################################

Write-Output "Today is $($today.ToShortDateString())" 
if ($today -eq $saturdayAfterSecondTuesday) {
    Write-Output "Today is Saturday after the second Tuesday of the month."
} else {
    Write-Output "Today is NOT Saturday after the second Tuesday of the month."
}
