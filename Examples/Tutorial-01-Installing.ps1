# VersionOne PowerShell SDK Tutorial 1 -- Install

# install the module from the gallery
Install-Module VersionOne.Sdk.PowerShell

# import the module to use it
# you can set the V1Token and BaseUri in the environment before loading
# or call Set-V1Connection as described below
$env:V1_API_TOKEN = "myV1ApiToken..."
$env:V1_BASE_URI = "localhost/VersionOne.Web"
Import-Module VersionOneSdk -Force

# Set your endpoint and credentials for each session
# You may call this function with a token or PSCredential object
# This will return $true if the connection is ok (unless -SkipTest is set)
Set-V1Connection -BaseUri "localhost/VersionOne.Web" -Credential (Get-Credential)
# -or-
Set-V1Connection -BaseUri "localhost/VersionOne.Web" -Token "myV1ApiToken..."


