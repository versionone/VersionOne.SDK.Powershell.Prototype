# VersionOne PowerShell SDK Tutorial 2 -- Overview

# Prereq -- Run 01 to install and load the SDK

# List all the commands in the SDK
Get-Command -Module VersionOneSdk 

# Most commands have aliases 
Get-Alias -Name v1*

# All commands have help most with examples
help v1asset -ShowWindow

# To view online help for the V1 API
Show-V1Help -HelpType Meta

# To make the SDK easy-to-use, tab completion is available for 
# asset types and attributes in most cases.  This works from the
# command line or within ISE or VSCode, if you load the module

# for asset types
Get-V1Asset 

# for asset types starting with S
Get-V1Asset S

# for attributes
Get-V1Asset Scope -Attribute 

# Common parameters are available for all commands like -Verbose 
# For ones that make change data you can use -WhatIf or -Confirm

# Pipleline input is supported for many commands