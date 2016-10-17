function ConvertTo-V1Json
{
[CmdletBinding()]
param(
[Parameter(Mandatory,ValueFromPipeline)]
[object] $asset  
)

process
{
    Set-StrictMode -Version Latest
    
    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType property"
    }

    $assetMeta =  Get-V1AssetType -assetType $asset.AssetType

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
        foreach ( $m in $asset | Get-Member -MemberType Properties | Where name -ne "AssetType" )
        {
            $name = $m.name
            if ( -not ( $assetMeta.ContainsKey($name)))
            {
                throw "Attribute name of $name not found on asset of type $($asset.AssetType)"
            }

            if ( $assetMeta[$name].IsMultivalue) 
            {
                $act = "add"
            }
            else 
            {
                $act = "set"
            }
            if ($assetMeta[$name].RelatedNameRef )
            {
                $attrName = $assetMeta[$name].RelatedNameRef
            }
            else
            {
                $attrName = $name    
            }
            $v1Object.Attributes[$name]=@{Name=$attrName;value=$asset.$name;act=$act}
        } 
        $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where { $_ -notin $v1Object.Attributes.Keys }
        if ( $missingRequired )
        {
            throw "Asset of type $($asset.AssetType) requires missing attributes: $($missingRequired -join ", ")"
        }
    }
    ConvertTo-Json $v1Object -Depth 100
}

}