﻿# VersionOne PowerShell SDK Tutorial -- Installation and SDK Overview

# Find the module 
Find-Module VersionOne.*

# install the module from the gallery as ADMIN!
Install-Module VersionOne.Sdk.PowerShell

Get-Module VersionOne* -ListAvailable

# import the module to use it
# you can set the V1Token and BaseUri in the environment before loading
# or call Set-V1Connection as described below
$env:V1_API_TOKEN = "myV1ApiToken..."
$env:V1_BASE_URI = "localhost/VersionOne.Web"
Import-Module VersionOne.SDK.PowerShell -Force

# Set your endpoint and credentials for each session
# You may call this function with a token or PSCredential object
# This will return $true if the connection is ok (unless -SkipTest is set)
Set-V1Connection -BaseUri "localhost/VersionOne.Web" -Credential (Get-Credential)
# -or-
Set-V1Connection -BaseUri "localhost/VersionOne.Web" -Token "myV1ApiToken..."

# List all the commands in the SDK
Get-Command -Module VersionOne.SDK.PowerShell | select name

# Most commands have aliases 
Get-Alias -Name v1*

# All commands have help most with examples
help v1asset -ShowWindow

# To view online help for the V1 API
Show-V1Help -HelpType Meta

# To make the SDK easy-to-use, tab completion is available for 
# asset types and attributes in most cases.  This works from the
# command line or within ISE or VSCode, if you load the module

$Null = Get-V1Meta -Force

# for asset types
Get-V1Asset 

# for asset types starting with S
Get-V1Asset S

# for attributes
Get-V1Asset Scope -Attribute 

# Common parameters are available for all commands like -Verbose 
# For ones that make change data you can use -WhatIf or -Confirm

# Pipleline input is supported for many commands
