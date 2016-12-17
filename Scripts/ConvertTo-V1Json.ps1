<#
.Synopsis
	Convert an object to V1 JSON for sending to the REST API

.Parameter Asset
	An asset created with New-V1Object or converted via ConvertFrom-V1Json, which is called from Get-V1Asset

.Parameter StripDotted
    Strip any dotted names, e.g Scheme.Name that are return from Get-V1Asset

.Outputs
	JSON

#>
function ConvertTo-V1Json
{
[CmdletBinding()]
[OutputType([string])]
param(
[Parameter(Mandatory,ValueFromPipeline)]
[object] $Asset,
[switch] $StripDotted,
[switch] $RemoveRelations,
[string[]] $Attribute
)

process
{
    Set-StrictMode -Version Latest

    testAsset $Asset

    $AssetMeta =  Get-V1Meta -assetType $Asset.AssetType

    $v1Object = @{Attributes=@{}}
    if ( $Asset -is "HashTable" )
    {
        foreach ( $n in $Asset.keys )
        {
            if ( $StripDotted -and $n.Contains("."))
            {
                continue
            }
            $v1Object[$n] = @{name=$n;value=$Asset[$n];act="set"}
        }

    }
    else
    {
        $addedKeys = @()
        $isInsert = $true
        foreach ( $m in $Asset | Get-Member -MemberType Properties | Where-Object name -ne "AssetType" )
        {
            $name = $m.name
            if ( $name -eq "id" )
            {
                $isInsert = $false
                continue
            }

            if ( ($StripDotted -and $name.Contains(".")) -or
                 ($Attribute -and $name -notin $Attribute) -or
                 $AssetMeta.$name.IsReadOnly -or
                 $Asset.$name -eq $null)
            {
                continue
            }


            if ( -not ( $AssetMeta.ContainsKey($name)))
            {
                throw "Attribute name of $name not found on asset of type $($Asset.AssetType)"
            }

            $addedKeys += $name

            if ( $AssetMeta.$name.AttributeType -eq "Relation" )
            {
                if ( $AssetMeta[$name].IsMultivalue)
                {
                    $action = "add"
                    if ( $RemoveRelations )
                    {
                        $action = "remove"
                    }
                    $values = @($Asset.$name | ForEach-Object { @{idref=$(getMultiValue $_);act=$action}})

                    $v1Object.Attributes[$name]=@{name=$name;value=$values}
                }
                else
                {
                    if ( $RemoveRelations )
                    {
                        $value = $null
                        $v1Object.Attributes[$name]=@{name=$name;act="set"}
                    }
                    else
                    {
                        $v1Object.Attributes[$name]=@{name=$name;value=$(getMultiValue $Asset.$name);act="set"}
                    }
                }
            }
            elseif (-not $RemoveRelations) # simple type
            {
                $v1Object.Attributes[$name]=@{name=$name;value=$Asset.$name;act="set"}
            }
        }

        if ( -not $addedKeys )
        {
            Write-Warning "No attributes found when converting $($Asset.AssetType)"
        }
        if ( $isInsert ) # if updating or removing don't check for missing
        {
            $missingRequired =  $AssetMeta.Keys | Where-Object { $AssetMeta[$_].IsRequired } | Where-Object { $_ -notin $v1Object.Attributes.Keys }
            if ( $missingRequired )
            {
                throw "Asset of type $($Asset.AssetType) requires missing attributes: $($missingRequired -join ", ")"
            }
        }
    }
    $ret = ConvertTo-Json $v1Object -Depth 100
    Write-Verbose $ret
    $ret

}

}