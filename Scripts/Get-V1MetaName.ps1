$script:sortedKeys = $null


<#
.Synopsis
	Get AssetType Names

.Parameter Force
	Force reload from the server

.Outputs
	Sorted string array of assetTypes

#>
function Get-V1MetaName
{
[CmdletBinding()]
param(
[switch] $Force    
)

    if ( $Force -or (-not $script:sortedKeys) )
    {
        $script:sortedKeys = (Get-V1Meta -force:$Force).keys  | Sort-Object
    }    

    return $script:sortedKeys
}

New-Alias -Name v1metaname -Value Get-V1MetaName