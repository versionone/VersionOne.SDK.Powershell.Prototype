<#
.Synopsis
	Get VersionOne meta data about assets
	
.Parameter baseUri
	baseUri for the server

.Parameter Force
	force reload from the server

.Link
    https://community.versionone.com/VersionOne_Connect/Developer_Library/Getting_Started/Platform_Concepts/Endpoints/rest-1.v1%2F%2FData

.Outputs
	HashTable of Asset names to data about them

#>
$script:meta = $null

function Get-V1Meta
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]    
[string] $baseUri,
[switch] $Force
)
    Set-StrictMode -Version Latest

    if ( $script:meta -and -not $Force )
    {
        Write-Verbose "Meta already loaded"
        return $script:meta;
    }

    $metaJson = Invoke-RestMethod -Uri "http://$baseUri/meta.v1" -Headers @{Accept="application/json"}

    $script:meta = @{}
    $activityName = "Processing meta (once per PowerShell session)"

    Write-Progress -Activity $activityName -PercentComplete 0 
    $i = 0
    $properties = $metaJson.AssetTypes | Get-Member -MemberType Properties
    if ( $properties )
    {
        $total = $properties.Count

        $properties | ForEach-Object {

            $name = $_.name

            Write-Progress -Activity $activityName -PercentComplete (100*($i++)/$total) -CurrentOperation $name

            $metum = @{}

            foreach ( $a in $metaJson.AssetTypes.$name.Attributes | Get-Member -MemberType Properties )
            {
                $attrName = $a.name
                $simpleName = $attrName
                if ( $simpleName.StartsWith("$name.") )
                {
                    $simpleName = ($simpleName -split '\.')[1]
                }
                $metum[$simpleName] = $metaJson.AssetTypes.$name.Attributes.$attrName | Select Name,IsReadOnly,IsRequired,IsMultivalue,IsCustom,AttributeType,
                                @{n="RelatedNameRef";e={if ( $_.AttributeType -eq "Relation"){$_.RelatedAsset.nameref}else{$null}}}
            }
            $meta[$name] = $metum
        }

        Write-Progress -Activity $activityName -Completed 

    }

    return $script:meta

}

Export-ModuleMember -Function "*-*"
