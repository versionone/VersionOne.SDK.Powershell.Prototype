<#
.Synopsis
	Save (add or update) a V1 Asset
	
.Description
	If the asset has an id, it will update it, otherwise it will create it

.Parameter Asset
	The asset object returned from Get-V1Asset or New-V1Asset

.Outputs
	The created or updated asset, as returned from the REST API

.Example
    $savedStory = New-V1Asset Story -Attribute @{Name="Test";Scope="Scope:0"} | Save-V1Asset 

    New up a story and save it to the server

.Example
    $bundles = v1asset Bundle -Attribute ChangeSets -id 1016
    $changeSets = v1asset ChangeSet -Attribute Name -id 2144
    $bundles[0].ChangeSets = $changeSets[0].id
    Save-V1Asset $bundles[0]

    Add a ChangeSet to a Bundle 

#>
function Save-V1Asset
{
[CmdletBinding(SupportsShouldProcess)]
param(
[Parameter(Mandatory,ValueFromPipeline)]  
$Asset  
)

process
{
    saveRemoveRelation $Asset
}

}

Set-Alias -Name v1save Save-V1Asset