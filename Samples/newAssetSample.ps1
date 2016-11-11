# V1 PowerShell SDK sample file.  Edit in ISE and highlight multiple lines and use F8 to run just those
if ( -not (Test-Path ..\V1.psm1 ))
{
    throw "Must be in Samples folder"
}

. .\Push-V1Asset.ps1
. .\New-V1TestName.ps1

# import the module, overwriting any existing version
Import-Module ..\V1.psm1 -Force

# use tab completion for command names
# Set-V1<tab>

# this will prompt for the admin password
Set-V1Connection -baseUri localhost/VersionOne.Web -credential admin 

# make sure meta is loaded.  First time this will take some time
$null = Get-V1Meta


# view required attributes for change set, and bundle
Get-V1MetaAssetType ChangeSet -required | ft
Get-V1MetaAssetType Bundle -required | ft

$name = "PSTest$(Get-Date)"
$changeSet = New-V1Asset -assetType ChangeSet -attributes @{ Name = $name } | Save-V1Asset
$changeSet
$bundle = New-V1Asset -assetType Bundle -attributes @{ Name = $name; PackageRevision = 1; IsCustomLabel = $false; ChangeSets = $changeSet } | Save-V1Asset
$bundle

v1get Bundle -ID $bundle.id

# get the added bundle's changesets
v1get -assetType Bundle -attributes ChangeSets -ID $bundle.id


#add another changeset to bundle
$name = "PSTest$(Get-Date)"
$changeSet = New-V1Asset -assetType ChangeSet -attributes @{ Name = $name } | Save-V1Asset
Set-V1Value $bundle -name ChangeSets -value $changeSet | Save-V1Asset


# get the added bundle's changesets
v1get -assetType Bundle -attributes ChangeSets -ID $bundle.id | select -ExpandProperty ChangeSets


$defaultEpicProps = @{Description="Added via PS";Scope="Scope:0"}

# add 20 epics using little helper to create 20 names
$epics = New-V1TestName 20 -prefix "MyTestEpic" | New-V1Asset -assetType Epic -Name Name `
            -defaultAttributes $defaultEpicProps 