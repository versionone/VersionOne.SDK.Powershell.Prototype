<#
.Synopsis
    Convenience method to add or update a V1 Asset searching by an attribute

.Description
    Wraps Save-V1Asset by looking up the asset first by the Attribute with the value on the Asset
	
.Parameter asset
	The asset to add or update on the server

.Parameter name
	The name of the Attribute on the Asset to search on

.Outputs
	Assets from Save-V1Asset

.Example
    Push-V1Asset $story 

    Will search story where name -eq $story.Name and if it exists will update it, otherwise it will add a new story
#>
function Push-V1Asset
{
[CmdletBinding()]
param( 
[Parameter(Mandatory,ValueFromPipeline)]
$Asset, 
[string] $Attribute = "Name")

process
{
    $value = "$Attribute='$($Asset.$Attribute)'"
    $ret = Get-V1Asset $Asset.AssetType -filter $value 
    if ( -not $ret )
    {
        $ret = Save-V1Asset $Asset
        Write-Information "Added $($Asset.AssetType) with attribute $value and Oid of $($ret.id)"
    }
    elseif ( @($ret).Count -gt 1 )
    {
        Write-Warning "$($Asset.AssetType) with attribute $value has $($ret.Count) values, taking first one with Oid of $($ret.id)"
        $ret = $ret[0]
    }
    else
    {
        Write-Information "Found existing $($Asset.AssetType) with attribute $value and Oid of $($ret.id)"
    }
    $ret
}

}

