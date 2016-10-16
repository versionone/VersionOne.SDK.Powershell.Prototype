Import-Module .\VersionOne.SDK.Powershell.psm1 -args "https://www14.v1host.com/v1sdktesting", "admin", "admin"	

# Using aliases:
$s = (vmeta).Story; $s | vquery 37741 | vselect $s.Name, $s.ID, $s.CreateDate | vfetch
$m = (vmeta).Member; $m | vquery | vselect $m.Name, $m.Email, $m.DefaultRole | vwhere {$m.OwnedWorkitems -eq 'Story:1071'} | Invoke-V1Fetch

# Same thing, but with long function names:
$s = (Get-V1Metamodel).Story; $s | Start-V1Query 37741 | Invoke-V1Select $s.Name, $s.ID, $s.CreateDate | Invoke-V1Fetch
$m = (Get-V1Metamodel).Member; $m | Start-V1Query | Invoke-V1Select $m.Name, $m.Email, $m.DefaultRole | Invoke-V1Where {$m.OwnedWorkitems -eq 'Story:1071'} | Invoke-V1Fetch
