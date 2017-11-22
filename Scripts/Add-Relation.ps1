<#
.Synopsis
	Add one or more relationships from to asset
	
.Description
	Adds the relations specified by Attribute.

.Parameter Asset
	The asset to add relations to.  Must have Oid

.Parameter Attribute
	Names of relations to add

.Parameter ID
    ID or array of IDs of items to add.  Can be strings (OIDs), or objects with ID.  

.Outputs
	Asset object

.Example
    Add-V1Relation $story -Attribute Owners -ID "Member:20"

    Adds the Member with oid 20 from the Owners relations

#>
function Add-V1Relation
{
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")] # saveAssetOrRelation does and it passes through
[CmdletBinding(SupportsShouldProcess)]
param (
[Parameter(Mandatory,ValueFromPipeline)]
$Asset,
[Parameter(Mandatory)]
[string] $Attribute,
[Parameter(Mandatory)]
$ID
)

process
{
    testAsset $Asset -IdRequired
    
    $Asset = [PSCustomObject]@{AssetType=$Asset.AssetType;ID=$Asset.ID;$Attribute=@()}
    foreach ( $i in $ID )
    {
        $Asset.$Attribute += getOid $i
    }
    saveAssetOrRelation $Asset $Attribute
}

}


Set-Alias -Name v1addrel Add-V1Relation
