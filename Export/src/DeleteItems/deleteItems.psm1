$todaysdate = Get-Date -Format "yyyy-MM-dd"

$logfilepath = "./Export/DeletedItems.log"

function WriteToLogFile ($message)
{
   Write-Output $message
   Add-content $logfilepath -value ("[" + (Get-Date -Format "yyyy-MM-dd").ToString() + "]:" + $message)
}

function deleteItems{
	param (
        [Parameter(Mandatory=$true)]
		[string]$path,
		[Parameter(Mandatory=$true)]
		[string]$extension = "json"
    )
	
    $fichier = "Bitwarden_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9][0-9][0-9].${extension}"
    $list = @(Get-ChildItem -Path "${path}" -Recurse -Include $fichier)
	
    $listMois = New-Object Collections.Generic.List[Int]
    $listSemaines = New-Object Collections.Generic.List[Int]
	$listJour = New-Object Collections.Generic.List[Int]
	$dateTime = Get-Date

    for ($num = 0; $num -lt $list.Length; $num++){
        [string]$splittedText = [string](($list[$num] -split '_')[1])

        $provider = New-Object System.Globalization.CultureInfo "en-US"
        $convertible = [datetime]::TryParseExact($splittedText, "yyyy-MM-dd", [system.Globalization.DateTimeFormatInfo]::InvariantInfo,[system.Globalization.DateTimeStyles]::None, [ref]$dateTime)

        if($convertible){
            [int]$month = [Int](Get-Date $dateTime -UFormat '%m')
            [int]$week = [Int](Get-Date $dateTime -UFormat '%V')
		    [int]$day = [Int]((Get-Date $dateTime).DayOfWeek.value__)

            $listMois.Add([int]$month)
            $listSemaines.Add([int]$week)
            $listJour.Add([int]$day)
        }
    }

    [int]$currentMonth = Get-Date -UFormat '%m'
    [int]$currentWeek = Get-Date -UFormat '%V'
    [int]$currentDay = [Int](Get-Date).DayOfWeek.value__

    [int]$currentMonthNumber = $null
	[int]$countMonth = 0

    [int]$currentWeekNumber = $null
    [int]$countWeek = 0
	
	[int]$currentDayNumber = $null
	[int]$countDay = 0
	
    for ($num = $list.Length-1; $num -ge 0; $num--){
        [int]$tempCurrentWeekNumber = $listSemaines[$num]
		[int]$tempCurrentDayNumber = $listJour[$num]
        [Int]$tempCurrentMonthNumber = $listMois[$num]
		
        if($currentMonthNumber -ne $tempCurrentMonthNumber){
            $currentMonthNumber = $tempCurrentMonthNumber
            $countMonth = 1
        }Else{
            $countMonth++
        }

		if($currentDayNumber -ne $tempCurrentDayNumber){
            $currentDayNumber = $tempCurrentDayNumber
            $countDay = 1
        }Else{
            $countDay++
        }

        if($currentWeekNumber -ne $tempCurrentWeekNumber){
            $currentWeekNumber = $tempCurrentWeekNumber
            $countWeek = 1
        }Else{
            $countWeek++
        }

        $filename = $list[$num]
		if(($currentMonth -ne $tempCurrentMonthNumber) -and ($currentMonth-1 -ne $tempCurrentMonthNumber)){ #Si c'est pas le mois actuel ou le mois dernier, supprimer s'il y a plus d'un fichier par mois
            if($countMonth -gt 1){
                Remove-Item $filename -Recurse
                WriteToLogFile "Delete $filename : Mois #$currentMonthNumber : Compté $countMonth fois"
            }
        }Elseif(($currentWeek -ne $tempCurrentWeekNumber) -and ($currentWeek-1 -ne $tempCurrentWeekNumber)){ #Si c'est pas la semaine actuelle ou la semaine passé
            if($countWeek -gt 1){ #supprimer s'il y a plus d'un fichier par semaine
                Remove-Item $filename -Recurse
                $bool=$tempCurrentWeekNumber-1
                WriteToLogFile "Delete $filename : ($currentWeekNumber != $currentWeek) or ($currentWeek-1 != $tempCurrentWeekNumber)"
            }
        }Elseif($countDay -gt 1){ #Supprimer s'il y a plus d'un fichier par jour
			Remove-Item $filename -Recurse
            WriteToLogFile "Delete $filename : More than one a day ($countDay)"
            if($currentWeek -eq $tempCurrentWeekNumber){
                $countWeek--
            }
		}
    }
}