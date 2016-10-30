# V1 PowerShell SDK 
Powershell is a very handy tool in the Windows developer toolbox.

This is an experimental Powershell SDK for the VersionOne REST API. We welcome your participation in development of this! Just fork and send a pull-request.

## Getting Started
To get things rolling, clone the repo and load the module, then set your Uri and credentials.

```Powershell
Import-Module .\V1.psm1
Set-V1Default -baseUri localhost/VersionOne.Web -token <mytoken>
# -- or --
Set-V1Default -baseUri localhost/VersionOne.Web -credentials "admin"
```
## Getting help
All the functions have self-contained help accessed using the PowerShell help function, e.g. ```help Get-V1Asset```  Useful options are ```-full``` to display all the help, ```-examples``` to show just examples, or ```-showWindow``` to pop up a GUI.  Tab completion can be used to complete function names, parameters, asset types, and attributes (in most cases).

## Asset Object in PowerShell
The PowerShell SDK converts the data returned from REST into simple PSCustomObjects to make them easy to work with.  It also loads meta so validatation and tab-completion can be used to easily discover valid asset and attribute name.

## SDK Functions 
There are many functions that get loaded by the module, which can be listed with ```Get-Command -Module V1``` The following sections highlight the primary ones.  As usual, use the ```help``` command to get details and examples.  

All functions support pipelines when appropriate.  All functions support the common PowerShell paramaters such as -Verbose, -Debug, -ErrorAction, etc. Ones that make changes support the -WhatIf and -Confirm common parameters. (see ```help about_commonparameters```) 

(Some functions are mainly used by the SDK, but made public since a developer may find them useful):

### Primary Asset Functions

| Function                | Description |
|-------------------------|-------------|
|`Get-V1Asset`| Gets one or more assets from the server, depending on parameters.  Can select attributes to return, asof, sorting, and a filter.  This returns asset objects. |
|`Get-V1AssetPaged`| Superset of Get-V1Asset, but does paging.  This returns the total available and the paged data. |
|`New-V1Asset`| Creates an asset from scratch or from a hash table of values, validating against meta.  Can fill in required parameters.  Pass to ```Save-V1Meta``` to add or update an asset. |
|`Set-V1Value`| Sets a value on an object, adding it if not there.  Tab-completion works and the names are validated |
|`Save-V1Asset`| Saves the asset.  If it has an ```id``` attribute it will try to update, it otherwise it will create it.  Assets from ```New-V1Asset``` do not have an id, ones from ```Get-V1Asset``` will. |
|`Remove-V1Asset`| Removes an asset with a soft-delete.  The ID with the moment is returned. |

## Meta Functions
Meta is used by the SDK for validation, and can be used to explore meta by showing the asset types and attributes available. 

| Function                | Description |
|-------------------------|-------------|
|`Get-V1Meta`| Loads and caches meta locally.  Certain function will call this to load meta.  Once this is called you can use tab completion for assetType and assetAttribute names! (Use -Force to reload from the server)|
|`Get-V1MetaAssetType`| Gets all the attributes for a given assetType, showing names, types, required, etc. |

## Testing
The `Tests` folder has Pester test files.  First set credentials with Set-V1Default, or set environment variables like the Set-Pester.ps1 sample file.

Each file is names for the function it tests, so you may look at those for more examples of using the SDK. 

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
