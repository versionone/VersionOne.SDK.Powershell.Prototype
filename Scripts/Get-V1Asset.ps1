<#
.Synopsis
	Get version assets from the server
	
.Parameter assetType
	Asset type.  To see valid values (Get-V1Meta).keys | sort

.Parameter ID
	optional ID to specify to get just one item, can be <type>:num, or just the number

.Parameter attributes
	optional list of attributes to return, otherwise it returns default set

.Parameter filter
	optional filter (where clause) for limiting results.  For details run Get-V1Help Filter 

.Parameter sort
	optional sort attributes. For details run Get-V1Help Sort  

.Parameter asOf
	optional asOf DateTime to get an asset as of that time

.Outputs
	Asset objects of the given type

.Example
    Set-V1Default -baseUri "localhost/VersionOne.Web" -token "1.bxDPFh/9y3x9MAOt469q2SnGDqo="
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

    Get PrimaryWorkitems that have an estimate > 1.  Note that when not using a variable, you must enclose the filter in double quotes, otherwise it will return an error.            
#>
function Get-V1Asset
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $assetType,
[string[]] $attributes,
$ID,
[string] $filter,
[string] $sort,
[DateTime] $asOf
)
    Set-StrictMode -Version Latest

    (Get-V1AssetPaged  @PSBoundParameters -startPage 0).Assets 
}

Set-Alias -Name v1get Get-V1Asset