function getMultiValue( $AssetValue )
{
  if ( $AssetValue -is "string" )
  {
      return $AssetValue
  }
  else 
  {
       return $AssetValue.id
  }
}

<#
.Synopsis
	Convert an object to V1 XML for sending to the REST API
	
.Parameter Asset
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
[object] $Asset  
)

process
{
    Set-StrictMode -Version Latest
    
    if ( -not (Get-Member -InputObject $Asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType attribute"
    }

    $AssetMeta =  Get-V1Meta -assetType $Asset.AssetType

    $v1Object = @{Attributes=@{}}
    if ( $Asset -is "HashTable" )
    {
        foreach ( $n in $Asset.keys )
        {
            $v1Object[$n] = @{name=$n;value=$Asset[$n];act="set"}
        }

    }
    else 
    {
        $xml = "<Asset>`n"
        $addedKeys = @()
        
        foreach ( $m in $Asset | Get-Member -MemberType Properties )
        {
            $name = $m.name
            $addedKeys += $name

            if ( -not ( $AssetMeta.ContainsKey($name)))
            {
                throw "Attribute name of $name not found on asset of type $($Asset.AssetType)"
            }
            
            if ($AssetMeta.$name.IsReadOnly -or $Asset.$name -eq $null)
            {
                continue;
            }

            if ( $AssetMeta.$name.AttributeType -eq "Relation" )
            {
                if ($AssetMeta.$name.IsMultivalue)
                {
                    $xml += "    <Relation name=`"$($AssetMeta.$name.Name)`">`n"    
                    if ( $Asset.$name -is 'Array')
                    {
                        foreach ( $v in $Asset.$name )
                        {
                            $xml += "        <Asset idref=`"$(getMultiValue $v)`" act=`"add`"/>`n"   
                        } 
                    }
                    else 
                    {
                        $xml += "        <Asset idref=`"$(getMultiValue $Asset.$name)`" act=`"add`"/>`n"    
                    }
                }
                else 
                {
                    $xml += "    <Relation name=`"$($AssetMeta.$name.Name)`" act=`"set`">`n"    
                    $xml += "        <Asset idref=`"$(getMultiValue $Asset.$name)`"/>`n"    
                }
                $xml += "    </Relation>`n"    
            }
            else # simple type
            {
                $xml += "    <Attribute name=`"$name`" act=`"set`">$($Asset.$name)</Attribute>`n"
            }
        } 
        $xml += "</Asset>"

        if ( $addedKeys -notcontains "id") # if updating don't check for missing 
        {
            $missingRequired =  $AssetMeta.Keys | Where-Object { $AssetMeta[$_].IsRequired } | Where-Object { $_ -notin $addedKeys }
            if ( $missingRequired )
            {
                throw "Asset of type $($Asset.AssetType) requires missing attributes: $($missingRequired -join ", ")"
            }
        }
    }
    $xml
}

}