$script:sortedKeys = $null

if ( -not $Function:PrevTabExpansionV1 -and $Function:TabExpansion)
{
    Rename-Item Function:\TabExpansion PrevTabExpansionV1
}

function TabExpansion( $line, $lastword )
{
    if ( -not $script:sortedKeys )
    {
        $script:sortedKeys = (Get-V1Meta).Keys | sort
    }

    [System.IO.File]::AppendText("C:\temp\tabexpansion.txt", ">$line<\t>$lastword<`n")
    if ( $line  -match "-V1ass\w* +(?:-ass\w+ (\w+)|(\w+)) +-pr\w* ")
    {
        [System.IO.File]::AppendText("C:\temp\tabexpansion.txt", "Match! $($Matches[0])`n")
        if ( $script:sortedKeys -contains $Matches[0])
        {
            return $script:meta[$Matches[0]].keys | sort
        }
    }
    
    if ( $script:sortedKeys -and ($line -like '*-V1*-assett* *' -or $line -match "(New|Get)-V1Asset +$" ))
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


    if ( $Function:PrevTabExpansionV1 )
    {
        PrevTabExpansionV1 $line $lastWord 
    }
}
