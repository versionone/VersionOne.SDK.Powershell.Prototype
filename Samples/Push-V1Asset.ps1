<#
.Synopsis
    Add or update a V1 Asset
#>
function Push-V1Asset
{
[CmdletBinding()]
param( 
[Parameter(Mandatory,ValueFromPipeline)]
$asset, 
[string] $name = "Name")

process
{
    $value = "$name='$($asset.$name)'"
    $ret = Get-V1Asset $asset.AssetType -filter $value 
    if ( -not $ret )
    {
        $ret = Save-V1Asset $asset
        Write-Information "Added $($asset.AssetType) with attribute $value and Oid of $($ret.id)"
    }
    elseif ( @($ret).Count -gt 1 )
    {
        Write-Warning "$($asset.AssetType) with attribute $value has $($ret.Count) values, taking first one with Oid of $($ret.id)"
        $ret = $ret[0]
    }
    else
    {
        Write-Information "Found existing $($asset.AssetType) with attribute $value and Oid of $($ret.id)"
    }
    $ret
}

}

