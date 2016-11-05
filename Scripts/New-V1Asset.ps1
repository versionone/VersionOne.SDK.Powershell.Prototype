<#
.Synopsis
	Create a new V1 Asset of the given type

.Description
    The Name/Value parameter set is useful when exploring since tab completion can be used for names.
	
.Parameter AssetType
	The type of the asset, use (Get-V1Meta).Keys | sort to see all valid values

.Parameter Names
	Names of attributes to add.  Number of Names must match number of values

.Parameter Values
	Values to set. Number of Names must match number of values

.Parameter Attributes
	Initial attributes for the asset.  They must be valid and include all required ones.  To see them, use Get-V1MetaAttribute -assetType Epic -required | select name,attributeType

.Parameter DefaultAttributes
	Optional addition attributes to set.

.Parameter Full
	if set will populate the object with all the possible writable attributes for the asset

.Example 
    $epic = New-V1Asset Epic -attributes @{Name="Test";Scope="Scope:0"} -default @{PlannedStart=$plannedStart;RequestedBy="YoMama"}

    Create a new Epic using hash table

.Example
    $epic = New-V1Asset Epic -Names "Name","Scope" -values "Test","Scope:0" -default @{PlannedStart=$plannedStart;RequestedBy="YoMama"}

    Create a new Epic using names and values

.Example
    $stories = gc names.txt | v1new Story -Names Name -DefaultAttributes @{Scope="Scope:0"}

    Create Story assets for each line in names.txt and scope of Scope:0

.Outputs
	a PSCustomObject

#>
function New-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory,Position=0)]
[string] $AssetType,
[Parameter(Mandatory,ParameterSetName="Values")]
[string[]] $Names,
[Parameter(Mandatory,ValueFromPipeline,ParameterSetName="Values")]
[object[]] $Values,
[Parameter(ValueFromPipeline,ParameterSetName="Object")]
[hashtable] $Attributes = @{},
[ValidateNotNull()]
[hashtable] $DefaultAttributes = @{},
[switch] $AddMissingRequired,
[switch] $Full
)

process
{
    Set-StrictMode -Version Latest

    $assetMeta = Get-V1Meta -assetType $AssetType

    $ht = @{AssetType=$AssetType}+$DefaultAttributes

    if ( $PSCmdlet.ParameterSetName -eq "Object")
    {
        $Attributes.Keys | ForEach-Object { $ht[$_] = $Attributes[$_] } # += will barf if duplicate key
    }
    else 
    {
        if ( $Names.Count -ne $Values.Count )
        {
            throw "Count of names ($($Names.Count)) must equal count of values ($($Values.Count))"
        }
        (0..($Names.Count-1)) | ForEach-Object { $ht[$Names[$_]] = $values[$_]}
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
            if ( -not $Attributes -or $AddMissingRequired )
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