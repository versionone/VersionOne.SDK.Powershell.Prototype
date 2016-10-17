<#
.Synopsis
	Set a value on a V1 Asset, adding the property if it doesn't exist yet.
	
.Description
	Use this when getting an asset from the server with a subset of properties, but you want to set one that didn't come down.

.Parameter asset
	the asset object

.Parameter name
	the name of the property

.Parameter value
	the value of the property, may be null

.Outputs
	the updated asset

#>
function Set-V1Value
{
param( 
[Parameter(Mandatory,ValueFromPipeline)]
$asset, 
[Parameter(Mandatory)]
[string] $name, 
$value )

process
{
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1AssetProperty $asset $name 
    if ( $assetMeta  )
    {
        if ( -not (Get-Member -Input $asset -name $name ))
        {
            Add-Member -InputObject $asset -MemberType NoteProperty -Name $name -Value (ConvertTo-V1AssetValue $value $assetMeta)
        }
        else
        {
            $asset.$name = $value
        }
        return $asset
    }
    else 
    {
        throw "Property $name not found on asset of type $($asset.AssetType)"    
    }
}

}
