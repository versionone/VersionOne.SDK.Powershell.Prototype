function ConvertTo-V1Json
{
[CmdletBinding()]
param(
[Parameter(Mandatory,ValueFromPipeline)]
[object] $asset
)

    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType property"
    }

    $meta = Get-V1Meta
    if ( -not ($meta.ContainsKey($asset.AssetType)))
    {
        throw "Asset type of $($asset.AssetType) not found in meta"
    }
    $assetMeta = $meta[$asset.AssetType]

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
    }
    ConvertTo-Json $v1Object -Depth 100
}

