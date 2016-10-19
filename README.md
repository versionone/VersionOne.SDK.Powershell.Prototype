Powershell is a very handy tool in the Windows developer toolbox.

This is an experimental Powershell SDK for the VersionOne REST API. We welcome your participation in development of this! Just fork and send a pull-request.

# V1 Implementation 

## Getting Started
To get things rolling, clone the repo and load the module, then set your Uri and credentials.

```Powershell
Import-Module .\V1.psm1
Set-V1Default -baseUri localhost/VersionOne.Web -token <mytoken>
```
## Simple Objects
The PowerShell API simplifies the objects returned from REST into simple PSCustomObjects to make them easy to work with.  To make the model easy to work with meta is loaded so new objects can be created with correct names, and tab-completion can be used to easily discover valid asset and attribute name.

## Primary Functions
There are many functions that get loaded by the module, some of which are called by the main functions, but may be useful to a developer.  The list is available with ```PowerShell Get-Command -Module V1```  The main ones of interest are the following:

| Function                | Description |
|-------------------------|-------------|
|`Get-V1Meta`| Loads and caches meta locally.  Certain function will call this to load meta.  Once this is called you can use tab completion for assetType and assetAttribute names! (Use -Force to reload from the server)|
|`Get-V1Asset`| Gets one or more assets, depending on parameters.  Can select properties to return, and a filter. |
|`New-V1Asset`| Creates an asset from a hash table, validating against meta.  Can fill in required parameters.  Pass to Save-V1Meta. |
|`Set-V1Value`| Sets a value on an object, adding it if not there.  Tab-completion works and the names are validated |
|`Save-V1Asset`| Saves the asset.  If it has an id is will try to update, it otherwise it will create it.  Assets from New-V1Asset do not have an id, ones from Get-V1Asset will. |
|`Remove-V1Asset`| Removes an asset |

All functions have help, examples, and support pipelines where appropriate.  Ones that make changes support the -WhatIf and -Confirm common PowerShell parameters.

## Testing
The `Tests` folder has Pester test files.  First set credentials with Set-V1Default, or set environment variables like the Set-Pester.ps1 sample file.

Each file is names for the function it tests, so you may look at those for more examples of using the API. 

---------------------------
## Goals for v1 (get it?)

* Native powershelly experience via pipes and filters model
* Support for reading meta information and building strongly-typed objects at run-time
* Basic Authentication support (VersionOne Authentication)
* Documented samples
* Documented source code using powershell conventions

## More ideas. What do you think?

* Object-oriented alternative, like the Python SDK, JavaScript SDK, and Fluent vNext wrapper for the .NET SDK
* Support for query.v1
* Support for OAuth2 
