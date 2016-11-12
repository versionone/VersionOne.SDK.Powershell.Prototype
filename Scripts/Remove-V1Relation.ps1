<#
.Synopsis
	Remove one or more relations from an asset
	
.Description
	Removes all the relations specified by name.  For multi-relations removes the relations currently on the object

.Parameter Asset
	The asset to remove relations from.  Must have Oid

.Parameter Attribute
	Names of relations to remove

.Outputs
	Asset object

.Example
    $story.Owners = @("Member:123")
    Remove-V1Relation $story -Attribute Owners

    Removes the Member with oid 123 from the Owners relations

.Example
    Remove-V1Relation $story -Attribute Status

    Clears out the single Status relationship on a story
#>
function Remove-V1Relation
{
[CmdletBinding(SupportsShouldProcess)]
param (
[Parameter(Mandatory,ValueFromPipeline)]
$Asset,
[Parameter(Mandatory)]
[string[]] $Attribute
)

process
{
    saveRemoveRelation $Asset $Attribute -RemovingRelation
}

}


Set-Alias -Name v1delrel Remove-V1Relation
