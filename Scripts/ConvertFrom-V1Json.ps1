function getJsonValue($attributeType, $AssetValue)
{
    switch ($attributeType)
    {   
        "Attribute" { return $AssetValue }
        "Relation" { 
            if ( $AssetValue -eq $null ) 
            {
                 return $AssetValue 
            } 
            elseif ( $AssetValue -is "Array")
            {
                $ret = @()
                foreach ( $v in $AssetValue )
                {
                    $ret += $v.idref
                }
                return $ret
            }
            else
            {
                 return $AssetValue.idref 
            } }
        default { throw "Unknow asset value type of $($AssetValue._type)"}
    }
}

function removeMomement( [hashtable] $Asset )
{
    if ( $Asset.Keys -contains "id" -and $Asset["id"] -like "*:*:*" )
    {
        $Asset["id"] = ($Asset["id"] -split ":")[0..1] -join ":"
    }
}


<#
.Synopsis
	Convert JSON from REST API to an object
	
.Parameter Asset
	The JSON object returned from Invoke-RestMethod 

.Outputs
	An object hydrated from JSON

#>
function ConvertFrom-V1Json
{
[CmdletBinding()]
param(
[Parameter(Mandatory,ValueFromPipeline)]
[object] $Asset
)

process
{
    Set-StrictMode -Version Latest

    $ret = @{};

    if ( (Get-Member -InputObject $Asset -Name "_type") -and ($Asset._type -eq "Asset"))
    {
        $ret["id"] = $Asset.id;
        foreach ( $a in $Asset.Attributes | Get-Member -MemberType Properties )
        {
            $name = $a.name
            $attribute = $Asset.Attributes.($name)
            $ret[$name] = getJsonValue $attribute._type $attribute.value
        }
        $ret["AssetType"]  = ($Asset.id -split ":")[0]
        removeMomement $ret
        [PSCustomObject]$ret
    
    }
    else 
    {
        throw "Unknown asset: $Asset"
    }
    
}

}