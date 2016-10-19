<#
    Helper to call the api, handling credentials, and not found exception
#>
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
        try 
        {
            if ( $_.exception.response.statusCode -eq [System.Net.HttpStatusCode]::NotFound )
            {
                return $null
            }
            throw $myError
        }
        catch 
        {
            throw $myError
        }
    }
}

