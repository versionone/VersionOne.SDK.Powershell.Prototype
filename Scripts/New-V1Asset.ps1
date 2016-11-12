<#
.Synopsis
	Create a new V1 Asset of the given type

.Description
    The Name/Value parameter set is useful when exploring since tab completion can be used for names.
	
.Parameter AssetType
	The type of the asset, use (Get-V1Meta).Keys | sort to see all valid values

.Parameter Name
	Names of attributes to add.  Number of Names must match number of values

.Parameter Value
	Values to set. Number of Names must match number of values

.Parameter Attribute
	Initial attributes for the asset.  They must be valid and include all required ones.  To see them, use Get-V1MetaAttribute -assetType Epic -required | select name,attributeType

.Parameter DefaultAttribute
	Optional addition attributes to set.

.Parameter Required
	Fill in any missing required attributes.

.Parameter Full
	if set will populate the object with all the possible writable attributes for the asset

.Example 
    $epic = New-V1Asset Epic -Attribute @{Name="Test";Scope="Scope:0"} -default @{PlannedStart=$plannedStart;RequestedBy="YoMama"}

    Create a new Epic using hash table

.Example
    $epic = New-V1Asset Epic -Name "Name","Scope" -Value "Test","Scope:0" -default @{PlannedStart=$plannedStart;RequestedBy="YoMama"}

    Create a new Epic using names and values

.Example
    $stories = gc names.txt | v1new Story -Name Name -DefaultAttribute @{Scope="Scope:0"}

    Create Story assets for each line in names.txt and scope of Scope:0

.Outputs
	A PSCustomObject

#>
function New-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory,Position=0)]
[string] $AssetType,
[Parameter(Mandatory,ParameterSetName="Values")]
[string[]] $Name,
[Parameter(Mandatory,ValueFromPipeline,ParameterSetName="Values")]
[object[]] $Value,
[Parameter(ValueFromPipeline,ParameterSetName="Object")]
[hashtable] $Attribute = @{},
[ValidateNotNull()]
[hashtable] $DefaultAttribute = @{},
[switch] $Required,
[switch] $Full
)

process
{
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1Meta -assetType $AssetType
    if ( -not $assetMeta )
    {
        throw "$AssetType not found in meta."
    }
    $AssetType = Get-V1AssetTypeName $AssetType

    $ht = @{AssetType=$AssetType}+$DefaultAttribute

    if ( $PSCmdlet.ParameterSetName -eq "Object")
    {
        $Attribute.Keys | ForEach-Object { $ht[$_] = $Attribute[$_] } # += will barf if duplicate key
    }
    else 
    {
        if ( $Name.Count -ne $Value.Count )
        {
            throw "Count of names ($($Name.Count)) must equal count of values ($($Value.Count))"
        }
        (0..($Name.Count-1)) | ForEach-Object { $ht[$Name[$_]] = $Value[$_]}
    }

    $ret = [PSCustomObject]$ht
    
    if ( $Full )
    {
        $missingWritable = $assetMeta.Keys | Where-Object { -not $assetMeta[$_].IsReadOnly } | Where-Object { $_ -notin $ht.Keys }
        $missingWritable | ForEach-Object { Set-V1Value $ret -Name $_ -Value $null } | Out-Null
    }
    else
    {    
        $missingRequired =  $assetMeta.Keys | Where-Object { $assetMeta[$_].IsRequired } | Where-Object { $_ -notin $ht.Keys }

        if ( $missingRequired )
        {
            if ( -not $Attribute -or $Required )
            {
                $missingRequired | ForEach-Object { Set-V1Value $ret -Name $_ -Value $null } | Out-Null
                Write-Warning "For asset of type $($AssetType), added missing attributes: $($missingRequired -join ", ")"
            }
            else 
            {
                throw "Asset of type $($AssetType) requires missing attributes: $($missingRequired -join ", ")"
            }
        }
    }
     
    return $ret
}

}

Set-Alias -Name v1new New-V1Asset