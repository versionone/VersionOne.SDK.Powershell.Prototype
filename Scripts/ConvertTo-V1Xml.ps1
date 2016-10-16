function getMultiValue( $assetValue )
{
  if ( $assetValue -is "string" )
  {
      return $assetValue
  }
  else 
  {
       return $assetValue.id
  }
}

function ConvertTo-V1Xml
{
[CmdletBinding()]
param(
[Parameter(Mandatory,ValueFromPipeline)]
[object] $asset,
[Parameter(Mandatory)]
[string] $baseUri  
)
    Set-StrictMode -Version Latest
    
    if ( -not (Get-Member -InputObject $asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType property"
    }

    $assetMeta =  Get-V1AssetType -assetType $asset.AssetType -baseUri $baseUri

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
        $xml = "<Asset>`n"
        $addedKeys = @()

        foreach ( $m in $asset | Get-Member -MemberType Properties | Where name -NotIn ("AssetType","id") )
        {
            $name = $m.name
            $addedKeys += $name

            if ( -not ( $assetMeta.ContainsKey($name)))
            {
                throw "Attribute name of $name not found on asset of type $($asset.AssetType)"
            }

            if ( $assetMeta.$name.AttributeType -eq "Relation" )
            {
                if ($assetMeta.$name.IsMultivalue)
                {
                    $xml += "    <Relation name=`"$($assetMeta.$name.Name)`">`n"    
                    if ( $asset.$name -is 'Array')
                    {
                        foreach ( $v in $asset.$name )
                        {
                            $xml += "        <Asset idref=`"$(getMultiValue $v)`" act=`"add`"/>`n"   
                        } 
                    }
                    else 
                    {
                        $xml += "        <Asset idref=`"$(getMultiValue $asset.$name)`" act=`"add`"/>`n"    
                    }
                }
                else 
                {
                    $xml += "    <Relation name=`"$($assetMeta.$name.Name)`" act=`"set`">`n"    
                    $xml += "        <Asset idref=`"$(getMultiValue $asset.$name)`"/>`n"    
                }
                $xml += "    </Relation>`n"    
            }
            else # simple type
            {
                $xml += "    <Attribute name=`"$name`" act=`"set`">$($asset.$name)</Attribute>`n"
            }
        } 
        $xml += "</Asset>"

        $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where { $_ -notin $addedKeys }
        if ( $missingRequired )
        {
            throw "Asset of type $($asset.AssetType) requires missing attributes: $($missingRequired -join ", ")"
        }
    }
    $xml
}

