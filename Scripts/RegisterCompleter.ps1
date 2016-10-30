<#
    Register all the tab completion script blocks for the SDK
#>
$global:debuggingTabV1 = $false
Set-StrictMode -Version Latest

<#
    Tab completion for asset type
#>
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged","Get-V1Meta","Get-V1AssetType","Get-V1MetaAssetType","New-V1Asset" -ParameterName "assetType" -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ( $global:debuggingTabV1 )
    {
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "commandName: $commandName parameterName: $parameterName wordToComplete: $wordToComplete commandAst: $($commandAst.gettype()) fakeBoundParameter $($fakeBoundParameter |out-string)`n")
    }

    return Get-V1MetaAssetName | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_)}
}


<#
    Tab completion for attribute of an asset type
#>
$attributeTabComplete = {
     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ( $global:debuggingTabV1 )
    {
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "commandName: $commandName parameterName: $parameterName wordToComplete: $wordToComplete commandAst: $($commandAst.gettype()) fakeBoundParameter $($fakeBoundParameter |out-string)`n")
    }

    if ( $fakeBoundParameter.keys -contains "assetType")
    {
        if ( $global:debuggingTabV1 )
        {
            [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "Got key`n");
            [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "$(Get-V1MetaAssetType $fakeBoundParameter['assetType'])`n");
        }
        return (Get-V1MetaAssetType $fakeBoundParameter["assetType"] ).keys | Where-Object {$_ -like "$wordToComplete*"} | Sort-Object | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_)}
    }
    else 
    {
        return $null
    }
}

Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged" -ParameterName "attributes" -ScriptBlock $attributeTabComplete

Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged" -ParameterName "sort" -ScriptBlock $attributeTabComplete

Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged" -ParameterName "filter" -ScriptBlock $attributeTabComplete