<#
.Synopsis
	Remove one or more relations from an asset
	
.Description
	Removes the relations specified by Attribute.

.Parameter Asset
	The asset to remove relations from.  Must have Oid

.Parameter Attribute
	Names of relations to remove

.Parameter ID
    ID or array of IDs of items to remove.  Can be strings (OIDs), or objects with ID.  

.Outputs
	Asset object

.Example
    Remove-V1Relation $story -Attribute Owners -ID "Member:20"

    Removes the Member with oid 20 from the Owners relations

.Example
    Remove-V1Relation $story -Attribute Status -ID $story.Status

    Clears out the Status single relationship on a story

.Example
    Remove-V1Relation $story -Attribute Owners -ID $story.Owners

    Clears out the Owner multi relationship on a story
#>
function Remove-V1Relation
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
    saveAssetOrRelation $Asset $Attribute -RemovingRelation
}

}

Set-Alias -Name v1delrel Remove-V1Relation
