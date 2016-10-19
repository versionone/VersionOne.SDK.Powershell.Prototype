$script:sortedKeys = $null
$script:debuggingTab = $false
Set-StrictMode -Version Latest

if ( -not $Function:PrevTabExpansionV1 -and $Function:TabExpansion)
{
    Rename-Item Function:\TabExpansion PrevTabExpansionV1
}

function TabExpansion( $line, $lastword )
{
    if ( -not $script:sortedKeys )
    {
        $script:sortedKeys = (Get-V1Meta -noLoad).Keys | sort
    }

    if ( $script:debuggingTab) { [System.IO.File]::AppendAllText("C:\temp\tabexpansion.txt", ">$line<`t>$lastword<`n") }

    # already have assetType and completing attributes
    if ( $line -match "-V1ass\w* +(?:-as\w+)?(\w+).*(?:-pr\w* *)?(?:\w*|, *\w*)$" )
    {
        if ( $script:debuggingTab) { [System.IO.File]::AppendAllText("C:\temp\tabexpansion.txt", "Match! $($Matches[1])`n") }

        if ( $script:sortedKeys -contains $Matches[1])
        {
         
            $lastword = $lastword -split "," | Select-Object -Last 1
            if ( $lastword )
            {
                return (Get-V1Meta -assetType $Matches[1]).keys | Where-Object {$_ -like "$lastword*" } | Sort-Object
            }
            else
            {
                return (Get-V1Meta -assetType $Matches[1]).keys | Sort-Object
            }        
        }
    }
    
    # complete assetType
    if ( $script:sortedKeys -and ($line -like '*-V1*-assett* *' -or $line -match "(New|Get)-V1Asset +\w*$" ))
    {
        if ( $lastword )
        {
            return $script:sortedKeys | Where-Object {$_ -like "$lastword*" }
        }
        else
        {
            return $script:sortedKeys
        }        
    }


    if ( $Function:PrevTabExpansionV1 )
    {
        PrevTabExpansionV1 $line $lastWord 
    }
}
