<#
    Helper to call the api, handling credentials, and not found exception
#>
$script:v1NetworkError = "nothing yet"

function InvokeApi
{
param(
[Parameter(Mandatory)]
[string] $Uri,
[ValidateNotNullOrEmpty()]
[string] $contentType = "application/json",
[ValidateNotNullOrEmpty()]
[string] $acceptHeader = "application/json",
[ValidateSet("POST","GET","DELETE")]
[string] $method = "GET",
$body = $null
)

    Set-StrictMode -Version Latest

    Write-Verbose "Calling $uri"
    
    try 
    {
        if ( $script:credential )
        {
            Invoke-RestMethod -Uri $uri -ContentType $contentType  `
                    -Method $method `
                    -Body $body `
                    -headers @{Accept=$acceptHeader} `
                    -Credential $script:credential
        }
        else
        {
            Invoke-RestMethod -Uri $uri -ContentType $contentType  `
                    -Method $method `
                    -Body $body `
                    -headers (@{Accept=$acceptHeader}+$script:authorizationHeader)
        }
    }
    catch 
    {
        $myError = $_
        
        $script:v1NetworkError = $myError
        try 
        {
            if ($myError.exception.response.statusCode -eq [System.Net.HttpStatusCode]::NotFound )
            {
                try 
                {
                    if ( (ConvertFrom-Json $_.ErrorDetails).error -eq "Not Found")
                    {
                        # if get here, V1 returned not found don't throw
                        return $null
                    }
                }
                catch
                {
                    Write-Debug "Yes, I promise not to have empty catches"
                }
            }
        }
        catch 
        {
            # on linux don't get response.status code, so assume 404 missing asset
            if ( (Test-Path variable:isWindows) -and -not $isWindows ) # on PS 6, *nix systems have $isWindows, etc.
            {
                try 
                {
                    if ( $myError.Exception.Message -like "* 404 *")
                    {
                        return $null
                    }
                }
                catch 
                {
                    Write-Debug "Yes, I promise not to have empty catches"
                }
            }
        }
        throw
    }
}

