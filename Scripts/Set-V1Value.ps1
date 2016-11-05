<#
.Synopsis
	Set a value on a V1 Asset, adding the attribute if it doesn't exist yet.
	
.Description
	Use this when getting an asset from the server with a subset of attributes, but you want to set one that didn't come down.

.Parameter Asset
	The asset object

.Parameter Name
	The name of the attribute

.Parameter Value
	The value of the attribute, may be null

.Outputs
	the updated asset

#>
function Set-V1Value
{
param( 
[Parameter(Mandatory,ValueFromPipeline)]
$Asset, 
[Parameter(Mandatory)]
[string] $Name, 
$Value )

process
{
    Set-StrictMode -Version Latest

    $AssetMeta = Get-V1MetaAttribute $Asset $Name 
    if ( $AssetMeta  )
    {
        if ( $AssetMeta.IsReadOnly )
        {
           throw "Attribute $Name on asset of type $($Asset.AssetType) is READ ONLY" 
        }
        else
        {
            if ( -not (Get-Member -Input $Asset -name $Name ))
            {
                $Value = ConvertTo-V1AssetValue $Value $AssetMeta
                Add-Member -InputObject $Asset -MemberType NoteProperty -Name $Name -value $Value
            }
            else
            {
                $Asset.$Name = $Value
            }
            return $Asset
        }
    }
    else 
    {
        throw "Attribute $Name not found on asset of type $($Asset.AssetType)"    
    }
}

}

New-Alias -Name v1set -Value Set-V1Value
