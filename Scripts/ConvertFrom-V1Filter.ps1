<#
.Synopsis
	Convert a ScriptBlock to a V1 filter query string

.Description
    Used by the SDK, may be useful for creating filters in other cases.

.Parameter Expression
	Script block containing an expression to be translated

.Outputs
	A string in the V1 format

.Example
    $story = Get-V1FilterAsset Story
    ConvertFrom-V1Filter { $story.ToDo -eq 0} 
    
    Returns "ToDo='0'"

.Example
    $story = Get-V1FilterAsset Story
    ConvertFrom-V1Filter { ($story.ToDo -ne 0 -and $story.Owners -eq 'Member:20') -or ($story.ToDo -eq 0 -and $story.Owners -eq 'Member:20','Member:21') }
    
    Returns "(ToDo!='0';Owners='Member:20')|(ToDo='0';Owners='Member:20','Member:21')"
#>
function ConvertFrom-V1Filter {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory)]        
    [ScriptBlock] $Expression
    )

    $psTokens = $null
    $parseErrors = $null
    $prevPrevToken = $null;

    $null = [System.Management.Automation.Language.Parser]::ParseInput($Expression, [ref]$psTokens, [ref]$parseErrors)
    if ( $parseErrors )
    {
        throw "Error parsing filter: $($parseErrors | out-string)"
    } 

    $tokens = @()
    $previousToken = $null
    Write-Verbose $($psTokens | Format-Table -a | out-string)

    # tokenkind
    # https://msdn.microsoft.com/en-us/library/system.management.automation.language.tokenkind%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
    $psTokens | ForEach-Object {     
        $token = $_   
        switch ($token.Kind) {
            'Dot' {             
                if ( $previousToken -eq 'Identifier' )
                    {
                        $tokens += '.'
                    }
             }
            # valued passed thru, more or less
            'Number' { $tokens += "'$($token.Text)'" }
            'Identifier' {
                if ( $previousToken -eq 'Dot' -and $prevPrevToken -ne 'Variable')
                {
                    $tokens += '@'
                }
                $tokens += $token.Text 
            }
            'StringExpandable' { $tokens += "'$($token.Text.Trim('"') -replace "'", "''")'" }
            { $_ -in 'LParen', 'RParen', 'Comma', 'StringLiteral' } { $tokens += $token.Text }
            # logical/relational
            'And'  { $tokens += ';'}
            'Or'  { $tokens += '|'}
            'Ieq' { $tokens += '='}
            'Ine' { $tokens += '!='}
            'Ilt' { $tokens += '<'}
            'Ile' { $tokens += '<='}
            'Igt' { $tokens += '>'}
            'Ige' { $tokens += '>=' }
            'Ceq' { $tokens += '='}
            'Cne' { $tokens += '!='}
            'Clt' { $tokens += '<'}
            'Cle' { $tokens += '<='}
            'Cgt' { $tokens += '>'}
            'Cge' { $tokens += '>='}
            # ignored
            'Variable' {}
            'EndOfInput' {}
            Default { throw "Unsupported token found parsing filter: '$($token.Text)' of type '$($token.Kind)'" }
        }

        $prevPrevToken = $previousToken
        $previousToken = $token.Kind
    }

    $tokens -join ""
}
