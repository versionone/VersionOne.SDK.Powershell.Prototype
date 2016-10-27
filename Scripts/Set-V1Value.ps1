<#
.Synopsis
	Set a value on a V1 Asset, adding the attribute if it doesn't exist yet.
	
.Description
	Use this when getting an asset from the server with a subset of attributes, but you want to set one that didn't come down.

.Parameter asset
	the asset object

.Parameter name
	the name of the attribute

.Parameter value
	the value of the attribute, may be null

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

    $assetMeta = Get-V1AssetAttribute $asset $name 
    if ( $assetMeta  )
    {
        if ( $assetMeta.IsReadOnly )
        {
           throw "Attribute $name on asset of type $($asset.AssetType) is READ ONLY" 
        }
        else
        {
            if ( -not (Get-Member -Input $asset -name $name ))
            {
                $value = ConvertTo-V1AssetValue $value $assetMeta
                Add-Member -InputObject $asset -MemberType NoteProperty -Name $name -value $value
            }
            else
            {
                $asset.$name = $value
            }
            return $asset
        }
    }
    else 
    {
        throw "Attribute $name not found on asset of type $($asset.AssetType)"    
    }
}

}
