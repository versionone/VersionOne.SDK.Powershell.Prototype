# V1 PowerShell SDK sample file.  Edit in ISE and highlight multiple lines and use F8 to run just those

$ErrorActionPreference = 'Stop'

# import the module, overwriting any existing version
Import-Module (Join-Path $PSScriptRoot ..\V1.psm1) -Force

# use tab completion for command names
# Set-V1<tab>

# set the url and credentials.  This will prompt for the admin password
# $cred = Get-Credential admin
Set-V1Connection -baseUri localhost/VersisdonOne.Web -credential $cred
v1get scope -id 0
# make sure meta is loaded.  First time this will take some time
$null = Get-V1Meta

# basic gets note that use can tab complete as below.  Piping through Format-Table to be pretty
# Get-V1Asset <tab>
# Get-V1Asset e<tab>
Get-V1Asset EpicCategory | Format-Table

# can get only a few attributes.  Tab completion works for attributes
# Get-V1Asset EpicCategory -attributes <tab>
# Get-V1Asset EpicCategory -attributes c<tab>
Get-V1Asset EpicCategory -attributes ColorName,Order,Name | Format-Table

# most commands have aliases that start with v1 to save some keystrokes, the next set of commands use them
# 

# since filters more complex getting tab completion on them requires a filter object
# -- or -- 
# you can just enter a filter

$f = v1filter EpicCategory
# run the above line to get tab completion of $f
v1get EpicCategory -filter{ $f.ColorName -eq 'iron' -and $f.Order -gt 20 } | ft

# can sort results on the server.  tab complete sort attributes (or use | sort)
# v1get Epic -attributes Name -sort <tab>
v1get Epic -attributes Name -sort Name

# can also get assets as of a date
v1get Epic -asOf '2016-11-1' | ft