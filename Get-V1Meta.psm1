$script:meta = $null
$script:sortedKeys = $null

if ( -not $Function:PrevTabExpansionV1 -and $Function:TabExpansion)
{
    Rename-Item Function:\TabExpansion PrevTabExpansionV1
}

function TabExpansion( $line, $lastword )
{
    if ( $script:sortedKeys )
    {
        if ( $line  -match "-V1ass\w* +(?:-ass\w+ (\w+)|(\w+)) +-pr\w* ")
        {
            if ( $script:sortedKeys -contains $Matches[0])
            {
                return $script:meta[$Matches[0]].keys | sort
            }
        }
        elseif ( ($line -like '*-V1*-assett* *' -or $line -match "(New|Get)-V1Asset +$" ))
        {
            # assetType 
            if ( $lastword )
            {
                return $script:sortedKeys | Where-Object {$_ -like "$lastword*" }
            }
            else
            {
                return $script:sortedKeys
            }        
        }
    }

    if ( $Function:PrevTabExpansionV1 )
    {
        PrevTabExpansionV1 $line $lastWord 
    }
}

<#
.Synopsis
	Get VersionOne meta data about assets

.Parameter Force
	force reload from the server

.Link
    https://community.versionone.com/VersionOne_Connect/Developer_Library/Getting_Started/Platform_Concepts/Endpoints/rest-1.v1%2F%2FData

    REST API documentation

.Outputs
	HashTable of Asset names to data about them

#>
function Get-V1Meta
{
[CmdletBinding()]
param(
[switch] $Force
)
    Set-StrictMode -Version Latest

    if ( $script:meta -and -not $Force )
    {
        Write-Verbose "Meta already loaded"
        return $script:meta;
    }

    $activityName = "Processing meta (once per PowerShell session)"

    Write-Progress -Activity $activityName -PercentComplete 0 -CurrentOperation "Getting meta from server..." 

    Write-Verbose "Loading meta from http://$(Get-V1BaseUri)/meta.v1"
    $metaJson = Invoke-RestMethod -Uri "http://$(Get-V1BaseUri)/meta.v1" -Headers @{Accept="application/json"}

    $script:meta = @{}
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
    $script:sortedKeys = $script:meta.Keys | sort

    return $script:meta

}

Export-ModuleMember -Function "*"
