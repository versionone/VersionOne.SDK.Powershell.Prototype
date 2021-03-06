<#
.Synopsis
	Get assets from the server
	
.Parameter AssetType
	Asset type.  To see valid values (Get-V1Meta).keys | sort

.Parameter ID
	Optional ID to specify to get just one item, can be <type>:num, or just the number

.Parameter Attribute
	Optional list of attributes to return, otherwise it returns default set

.Parameter Filter
	Optional filter (where clause) for limiting results. May be a string or script block. 

.Parameter Sort
	Optional sort attributes. For details run Get-V1Help Sort  

.Parameter AsOf
	Optional asOf DateTime to get an asset as of that time

.Parameter Find
	Prefix string to find in common attributes, or ones specified in FindIn.  Anything after * is ignored.  If * is not supplied, it is appended.

.Parameter FindIn
	Attribute for Find.  Uses default attributes for type if not supplied

.Parameter MaxToReturn
	Maximum number of items to return.  Defaults to 50. -1 will return all of them

.Parameter NoWarningForMax
	Suppress the warning about more results available

.Outputs
	Asset objects of the given type

.Example
    Set-V1Connection -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="
    $scopes = Get-V1Asset -assetType "Scope" -Attribute "Name"

    Get all scopes, just the Name field

.Example
    Get-V1Asset -assetType ChangeSet -id 4434

    Get a changeset with id of 4434

.Example
    Get-V1Asset EpicCategory -asOf 2001-1-1

    Get a epic categories as they looked as of January 1, 2001

.Example
    Get-V1Asset PrimaryWorkitem -Attribute Name,Status,ToDo,Estimate  -filter "Estimate>'1'" | ft

    Get PrimaryWorkitems that have an estimate > 1.  Note that when not using a variable, you must enclose the filter in double quotes, otherwise it will return an error.  For details about filter syntax run Get-V1Help Filter            

.Example
    $pi = Get-V1FilterAsset PrimaryWorkitem 
    Get-V1Asset PrimaryWorkitem -Attribute Name,Status,ToDo,Estimate  -filter { $pi.Estimate -gt 1 } | ft

    Get PrimaryWorkitems that have an estimate > 1 using a script block that can use tab completion for $pi.

.Example
    Get-V1Asset EpicCategory -filter {$x.Name -eq 'Feature'}

    Get the Feature EpicCategory

.Example    
    v1get ChangeSet -Find 'DoneChangeSet*'
    
    Get changesets that start with DoneChangeSet
#>
function Get-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $AssetType,
[string[]] $Attribute,
[Parameter(ValueFromPipeline)]
$ID,
$Filter,
[string] $Sort,
[DateTime] $AsOf,
[string] $Find,
[string[]] $FindIn,
[ValidateRange(-1,[Int]::MaxValue)]
[int] $MaxToReturn = 50,
[switch] $NoWarningForMax
)

process
{
    Set-StrictMode -Version Latest
    $null = $PSBoundParameters.Remove("MaxToReturn")
    $null = $PSBoundParameters.Remove("NoWarningForMax")

    $ret = (Get-V1AssetPaged  @PSBoundParameters -Start 0 -pageSize $MaxToReturn) 
    if ( $ret.Assets )   # don't return $null if empty, don't return anything 
    {
        $ret.Assets 
        if ( -not $NoWarningForMax -and $MaxToReturn -gt 0 -and $ret.Total -gt $MaxToReturn )
        {
            Write-Warning "Only $MaxToReturn values returned of $($ret.Total).  Set -MaxToReturn higher to see more."
        }
    }
}

}

Set-Alias -Name v1get Get-V1Asset