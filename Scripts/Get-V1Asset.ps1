<#
.Synopsis
	Get version assets from the server
	
.Parameter AssetType
	Asset type.  To see valid values (Get-V1Meta).keys | sort

.Parameter ID
	Optional ID to specify to get just one item, can be <type>:num, or just the number

.Parameter Attributes
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
	Attributes for Find.  Uses default attributes for type if not supplied

.Outputs
	Asset objects of the given type

.Example
    Set-V1Connection -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="
    $scopes = Get-V1Asset -assetType "Scope" -attributes "Name"

    Get all scopes, just the Name field

.Example
    Get-V1Asset -assetType ChangeSet -id 4434

    Get a changeset with id of 4434

.Example
    Get-V1Asset EpicCategory -asOf 2001-1-1

    Get a epic categories as they looked as of January 1, 2001

.Example
    Get-V1Asset PrimaryWorkitem -attributes Name,Status,ToDo,Estimate  -filter "Estimate>'1'" | ft

    Get PrimaryWorkitems that have an estimate > 1.  Note that when not using a variable, you must enclose the filter in double quotes, otherwise it will return an error.  For details about filter syntax run Get-V1Help Filter            

.Example
    $pi = Get-V1FilterAsset PrimaryWorkitem 
    Get-V1Asset PrimaryWorkitem -attributes Name,Status,ToDo,Estimate  -filter { $pi.Estimate -gt 1 } | ft

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
[string[]] $Attributes,
[Parameter(ValueFromPipeline)]
$ID,
$Filter,
[string] $Sort,
[DateTime] $AsOf,
[string] $Find,
[string[]] $FindIn
)

process
{
    Set-StrictMode -Version Latest

    $ret = (Get-V1AssetPaged  @PSBoundParameters -startPage 0).Assets 
    if ( $ret )   # don't return $null if empty, don't return anything 
    {
        $ret 
    }
}

}

Set-Alias -Name v1get Get-V1Asset