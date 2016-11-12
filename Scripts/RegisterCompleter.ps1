<#
    Register all the tab completion script blocks for the SDK, this uses the PS V5 Register-ArgumentCompleter function
#>
$global:debuggingTabV1 = $false
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
function tabCompleteForAssetAttributes {
    param($assetType, $wordToComplete, $commandAst, $alsoReadOnly = $false)
    
    $excludes = @()
    
    if ( $commandAst.commandElements[-1].Extent )
    {
        $excludes = $commandAst.commandElements[-1].Extent -split ","
    }

    if ( $global:debuggingTabV1 )
    {
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "1 Found assetType parameter before this`n");
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "2 $(Get-V1Meta -assetType $assetType)`n");
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "3 Last command element $($commandAst.commandElements[-1] | ft -fo | out-string))`n");
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "4 Excluding $excludes`n");
    }
    
    return (Get-V1MetaAssetType -assetType $assetType -alsoReadOnly:$alsoReadOnly ).Name | Where-Object {$_ -like "$wordToComplete*" -and $_ -notin $excludes } | Sort-Object | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_)}
}

function attributeTabComplete {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter, $alsoReadOnly )

    if ( $global:debuggingTabV1 )
    {
        [System.IO.File]::AppendAllText("c:\temp\registerCompleter.txt", "0 commandName: $commandName parameterName: $parameterName wordToComplete: $wordToComplete commandAst: $($commandAst.commandElements | fl -fo | out-string) fakeBoundParameter $($fakeBoundParameter |out-string)`n")
    }

    if ( $fakeBoundParameter.keys -contains "assetType")
    {
        return tabCompleteForAssetAttributes $fakeBoundParameter["assetType"] $wordToComplete $commandAst $alsoReadOnly
    }
    else 
    {
        return $null
    }
}

$attributeTabCompleteFull = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    attributeTabComplete $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter $true
}

$attributeTabCompleteWriteable = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    attributeTabComplete $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter $false
}

$attributeTabCompleteForAsset = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ( $fakeBoundParameter.keys -contains "Asset" -and (Get-Member -InputObject $fakeBoundParameter["Asset"] -Name "AssetType"))
    {
         return tabCompleteForAssetAttributes $fakeBoundParameter["Asset"].AssetType $wordToComplete $commandAst 
    }
    else 
    {
        return $null
    }
}

# asset with AssetType attribute
Register-ArgumentCompleter -CommandName "Set-V1Value" -ParameterName "Name" -ScriptBlock $attributeTabCompleteForAsset
Register-ArgumentCompleter -CommandName "Remove-V1Relation" -ParameterName "Attribute" -ScriptBlock $attributeTabCompleteForAsset

# asset Type as string
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged","Get-V1Meta","Get-V1FilterAsset","Get-V1MetaAttribute","Get-V1MetaAssetType","New-V1Asset" -ParameterName "AssetType" -ScriptBlock $assetTypeTabComplete
Register-ArgumentCompleter -CommandName "Remove-V1Asset" -ParameterName "ID" -ScriptBlock $assetTypeTabComplete

# attribute for functions that take assetType
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged" -ParameterName "Attribute" -ScriptBlock $attributeTabCompleteFull
Register-ArgumentCompleter -CommandName "New-V1Asset" -ParameterName "Attribute" -ScriptBlock $attributeTabCompleteWriteable
Register-ArgumentCompleter -CommandName "New-V1Asset" -ParameterName "Names" -ScriptBlock $attributeTabCompleteWriteable
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged" -ParameterName "Sort" -ScriptBlock $attributeTabCompleteFull
Register-ArgumentCompleter -CommandName "Get-V1Asset","Get-V1AssetPaged" -ParameterName "Filter" -ScriptBlock $attributeTabCompleteFull
