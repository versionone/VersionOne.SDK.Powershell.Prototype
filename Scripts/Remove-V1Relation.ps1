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
    Set-StrictMode -Version Latest

    if ( -not (Get-Member -InputObject $Asset -Name "AssetType"))
    {
        throw "Must supply object with AssetType attribute"
    }
    $AssetType = Get-V1AssetTypeName $Asset.AssetType

    if ( -not (($Asset | Get-Member -Name "id") -and $Asset.id))
    {
        throw "Must supply object with id attribute"
    }

    $uri = "http://$(Get-V1BaseUri)/rest-1.v1/Data/$AssetType"
    $id = $Asset.id -split ":"
    if ( $id.Count -gt 1 )
    {
        $uri += "/$($id[1])"
    }
    else
    {
        $uri += "/$($id[0])"
    }

    $body = ConvertTo-V1Json $Asset -stripDotted -removeRelations -Attribute $Attribute
    if ( $PSCmdlet.ShouldProcess("$uri", "Remove-V1Relation of from type $AssetType"))
    {
        try 
        {
            $result = InvokeApi -Uri $uri `
                    -Body $body `
                    -Method POST
        }
        catch
        { 
            throw "Exception removing relations from asset of type $AssetType with body of:`n$('='*80)`n$body`n$('='*80)`n$_" 
        }
        $result | ConvertFrom-V1Json
    }
    else
    {
        Write-Verbose($body)
    }

}

}


Set-Alias -Name v1delrel Remove-V1Relation
