<#
.Synopsis
	Remove a V1 asset from the server
	
.Parameter ID
	A V1 id in the format <assetType>:<number>

.Outputs
	An id with three levels, the last being the "moment" of the deleted item

.Example
    Remove-V1Asset "Story:1009"
#>
function Remove-V1Asset
{
[CmdletBinding(SupportsShouldProcess)]
param(
[Parameter(Mandatory,ValueFromPipeline)]  
[String] $ID
)

process
{
    Set-StrictMode -Version Latest

    ($AssetType,$num) =  $ID -split ":"

    if ( -not $AssetType -or -not $num )
    {
        throw "Id must be of format <assetType>:<number>"
    }

    $uri = "http://$(Get-V1BaseUri)/rest-1.v1/Data/$AssetType/${num}?op=Delete"
    if ( $PSCmdlet.ShouldProcess("$uri", "Remove-V1Asset of type $($AssetType)"))
    {
        try 
        {
            $result = InvokeApi -Uri $uri -Method POST
        }
        catch
        { 
            throw "Exception Saving asset of type $($asset.AssetType) with body of:`n$('='*80)`n$body`n$('='*80)`n$_" 
        }
        return $result.id # has moment in it 
    }
    
}

}

Set-Alias -Name v1del Remove-V1Asset