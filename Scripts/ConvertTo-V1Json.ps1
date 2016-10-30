<#
.Synopsis
	Convert an object to V1 JSON for sending to the REST API
	
.Parameter asset
	An asset created with New-V1Object or converted via ConvertFrom-V1Json, which is called from Get-V1Asset

.Outputs
	JSON

#>
function ConvertTo-V1Json
{
[CmdletBinding()]
[OutputType([string])]
param(
[Parameter(Mandatory,ValueFromPipeline)]
[object] $asset  
)

process
{
    Set-StrictMode -Version Latest
    
    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType attribute"
    }

    $assetMeta =  Get-V1MetaAssetType -assetType $asset.AssetType

    $v1Object = @{Attributes=@{}}
    if ( $asset -is "HashTable" )
    {
        foreach ( $n in $asset.keys )
        {
            $v1Object[$n] = @{name=$n;value=$asset[$n];act="set"}
        }

    }
    else 
    {
        $addedKeys = @()
        foreach ( $m in $asset | Get-Member -MemberType Properties | Where-Object name -ne "AssetType" )
        {
            $name = $m.name
            $addedKeys += $name

            if ( -not ( $assetMeta.ContainsKey($name)))
            {
                throw "Attribute name of $name not found on asset of type $($asset.AssetType)"
            }

            if ($assetMeta.$name.IsReadOnly -or $asset.$name -eq $null)
            {
                continue;
            }

            if ( $assetMeta.$name.AttributeType -eq "Relation" )
            {
                if ( $assetMeta[$name].IsMultivalue) 
                {
                    $values = $asset.$name | ForEach-Object { @{idref=$(getMultiValue $_);act="add"}}

                    $v1Object.Attributes[$name]=@{name=$name;value=$values}
                }
                else 
                {
                    $v1Object.Attributes[$name]=@{name=$name;value=$asset.$name;act="set"}
                }
            }
            else # simple type 
            {
                $v1Object.Attributes[$name]=@{name=$name;value=$asset.$name;act="set"}
            }
        } 

        if ( $addedKeys -notcontains "id") # if updating don't check for missing 
        {
            $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where-Object { $_ -notin $v1Object.Attributes.Keys }
            if ( $missingRequired )
            {
                throw "Asset of type $($asset.AssetType) requires missing attributes: $($missingRequired -join ", ")"
            }
        }
    }
    ConvertTo-Json $v1Object -Depth 100
}

}