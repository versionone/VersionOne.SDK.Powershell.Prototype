function getValue($attributeType, $assetValue)
{
    switch ($attributeType)
    {   
        "Attribute" { return $assetValue }
        "Relation" { 
            if ( $assetValue -eq $null ) 
            {
                 return $assetValue 
            } 
            elseif ( $assetValue -is "Array")
            {
                $ret = @()
                foreach ( $v in $assetValue )
                {
                    $ret += $v.idref
                }
                return $ret
            }
            else
            {
                 return $assetValue.idref 
            } }
        default { throw "Unknow asset value type of $($assetValue._type)"}
    }
}

function removeMomement( [hashtable] $asset )
{
    if ( $asset.Keys -contains "id" -and $asset["id"] -like "*:*:*" )
    {
        $asset["id"] = ($asset["id"] -split ":")[0..1] -join ":"
    }
}

function ConvertFrom-V1Json
{
[CmdletBinding()]
param(
[Parameter(Mandatory,ValueFromPipeline)]
[object] $asset
)

process
{
    Set-StrictMode -Version Latest

    $ret = @{};

    if ( (Get-Member -InputObject $asset -Name "_type") -and ($asset._type -eq "Asset"))
    {
        $ret["id"] = $asset.id;
        foreach ( $a in $asset.Attributes | Get-Member -MemberType Properties )
        {
            $name = $a.name
            $attribute = $asset.Attributes.($name)
            $ret[$name] = getValue $attribute._type $attribute.value
        }
        $ret["AssetType"]  = ($asset.id -split ":")[0]
        removeMomement $ret
        [PSCustomObject]$ret
    
    }
    else 
    {
        throw "Unknown asset: $asset"
    }
    
}

}