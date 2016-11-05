<#
    Register all the tab completion script blocks for the SDK, this uses the PS V5 Register-ArgumentCompleter function
#>
$global:debuggingTabV1 = $true
Set-StrictMode -Version Latest

<#
    Tab completion for asset type
#>
$assetTypeTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ( $global:debuggingTabV1 )
    {
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "commandName: $commandName parameterName: $parameterName wordToComplete: $wordToComplete commandAst: $($commandAst.gettype()) fakeBoundParameter $($fakeBoundParameter |out-string)`n")
    }

    return Get-V1MetaName | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_)}
}


<#
    Tab completion for attribute of an asset type
#>
$attributeTabComplete = {
     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ( $global:debuggingTabV1 )
    {
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "commandName: $commandName parameterName: $parameterName wordToComplete: $wordToComplete commandAst: $($commandAst.commandElements | fl -fo | out-string) fakeBoundParameter $($fakeBoundParameter |out-string)`n")
    }

    if ( $fakeBoundParameter.keys -contains "assetType")
    {
        if ( $global:debuggingTabV1 )
        {
            [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "Found assetType parameter before this`n");
            [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "$(Get-V1Meta -assetType $fakeBoundParameter['assetType'])`n");
        }
        $excludes = @()
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "Last command element $($commandAst.commandElements[-1] | ft -fo | out-string))`n");
        
        if ( $commandAst.commandElements[-1].Extent )
        {
            $excludes = $commandAst.commandElements[-1].Extent -split ","
        }
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "Excluding $excludes`n");
        return (Get-V1Meta -assetType $fakeBoundParameter["assetType"] ).keys | Where-Object {$_ -like "$wordToComplete*" -and $_ -notin $excludes } | Sort-Object | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_)}
    }
    else 
    {
        return $null
    }
}

# asset Type
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged","Get-V1Meta","Get-V1FilterAsset","Get-V1MetaAttribute","Get-V1MetaAssetType","New-V1Asset" -ParameterName "AssetType" -ScriptBlock $assetTypeTabComplete
Register-ArgumentCompleter -CommandName "Remove-V1Asset" -ParameterName "ID" -ScriptBlock $assetTypeTabComplete

# attribute for functions that take assetType
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged","New-V1Asset" -ParameterName "attributes" -ScriptBlock $attributeTabComplete
Register-ArgumentCompleter -CommandName "New-V1Asset" -ParameterName "Names" -ScriptBlock $attributeTabComplete
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged" -ParameterName "Sort" -ScriptBlock $attributeTabComplete
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged" -ParameterName "Filter" -ScriptBlock $attributeTabComplete
Register-ArgumentCompleter -CommandName "Set-V1Value" -ParameterName "Name" -ScriptBlock $attributeTabComplete