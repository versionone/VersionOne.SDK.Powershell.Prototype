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

<#
.Synopsis
	Convert an object to V1 XML for sending to the REST API
	
.Parameter asset
	An asset created with New-V1Object or converted via ConvertFrom-V1Xml, which is called from Get-V1Asset

.Outputs
	XML

#>
function ConvertTo-V1Xml
{
[OutputType([string])]    
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
        $xml = "<Asset>`n"
        $addedKeys = @()
        
        foreach ( $m in $asset | Get-Member -MemberType Properties )
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

        if ( $addedKeys -notcontains "id") # if updating don't check for missing 
        {
            $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where-Object { $_ -notin $addedKeys }
            if ( $missingRequired )
            {
                throw "Asset of type $($asset.AssetType) requires missing attributes: $($missingRequired -join ", ")"
            }
        }
    }
    $xml
}

}