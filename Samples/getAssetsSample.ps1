# V1 PowerShell SDK sample file.  Edit in ISE and highlight multiple lines and use F8 to run just those
$ErrorActionPreference = 'Stop'

if ( -not (Test-Path ..\V1.psm1 ))
{
    throw "Must be in Samples folder"
}

# import the module, overwriting any existing version
Import-Module (Join-Path $PWD ..\V1.psm1) -Force

# use tab completion for command names
# Set-V1<tab>

# set the url and credentials.  This will prompt for the admin password
# $cred = Get-Credential admin
Set-V1Connection -baseUri localhost/VersionOne.Web -credential $cred -test

# make sure meta is loaded.  First time this will take some time
$null = Get-V1Meta

$scope = v1get Scope -id Scope:0
$scope 

# basic gets note that use can tab complete as below.  Piping through Format-Table to be pretty
# Get-V1Asset <tab>
# Get-V1Asset e<tab>
Get-V1Asset EpicCategory | Format-Table

# can get only a few attributes.  Tab completion works for attributes
# Get-V1Asset EpicCategory -Attribute <tab>
# Get-V1Asset EpicCategory -Attribute c<tab>
Get-V1Asset EpicCategory -Attribute ColorName,Order,Name | Format-Table

# most commands have aliases that start with v1 to save some keystrokes, the next set of commands use them
# 

# since filters more complex getting tab completion on them requires a filter object
# -- or -- 
# you can just enter a filter
v1get Epic -filter "Status='EpicStatus:1049'" -Attribute Name,Status,Description | ft

$f = v1filter EpicCategory
# run the above line to get tab completion of $f
v1get EpicCategory -filter{ $f.ColorName -ne 'iron' -and $f.Order -gt 20 } | ft

# can sort results on the server.  tab complete sort attributes (or use | sort)
# v1get Epic -Attribute Name -sort <tab>
v1get Epic -Attribute Name -sort Name

# can also get assets as of a date
v1get Epic -asOf '2016-11-1' | ft

# findin
v1get Epic -Find Janua* -FindIn Name -Attribute Name

# paging
$paged = v1paged Epic -Attribute Name,Description -PageSize 3
"Total count: $($paged.Total)"
$paged.Assets | ft

# meta....
# get all asset type names
v1metaname

# get attributes of an asset type
v1asset Scope | ft