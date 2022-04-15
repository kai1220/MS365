$allTeams = Get-Team

cls
ForEach ($team in $allTeams) {
   
    Write-Host $team.DisplayName
    Get-TeamUser -GroupId $team.GroupId | sort -Descending role| ft Name, User, Role
    $members=Get-TeamUser -GroupId $team.GroupId 
    $owners=Get-TeamUser -GroupId $team.GroupId|where {$_.role -eq "owner"}
    $members=Get-TeamUser -GroupId $team.GroupId|where {$_.role -eq "member"}
    $guests=Get-TeamUser -GroupId $team.GroupId|where {$_.role -eq "guest"}

    Write-Host "owners:  "    $owners.count
    Write-Host "members: "    $members.count
    Write-Host "guests:  "    $guests.count
    Write-Host "OverAll: "    $members.count `n
   # Write-Host `n
   # Write-Host ""
    }
