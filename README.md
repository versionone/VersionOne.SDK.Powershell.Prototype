# V1 PowerShell SDK 
Powershell is a very handy tool in the Windows developer toolbox.

This is an experimental Powershell SDK for the VersionOne REST API. We welcome your participation in development of this! Just fork and send a pull-request.

## Getting Started
To get things rolling, clone the repo and load the module, then set your Uri and credentials.

```Powershell
git clone https://github.com/versionone/VersionOne.SDK.Powershell.Prototype.git
cd VersionOne.SDK.Powershell.Prototype

Import-Module .\V1.psm1

Set-V1Connection -baseUri localhost/VersionOne.Web -token <mytoken>
# -- or --
Set-V1Connection -baseUri localhost/VersionOne.Web -credentials <myusername>
# -- or --
$cred = Get-Credential <myusername>
Set-V1Connection -baseUri localhost/VersionOne.Web -credentials $cred

Test-V1Connection
```

## SDK Functions 
There are many functions and aliases that get loaded by the module, which can be listed with ```Get-Command -Module V1 -CommandType Alias,Function``` The following sections highlight the primary ones.  As usual, use ```help <commandName>``` command to get details and examples.  

All functions support pipelines when appropriate and the common PowerShell parameters such as -Verbose, -Debug, -ErrorAction, etc. Ones that make changes support the -WhatIf and -Confirm common parameters. (see ```help about_commonparameters```) 

(Some functions are mainly used by the SDK, but made public since a developer may find them useful):

### Primary Asset Functions

| Function                | Alias | Description | Output |
|-------------------------|-------|-------------|--------|
|`Get-V1Asset`| `v1get` | Gets one or more assets from the server, depending on parameters.  You can select attributes to return, asof, sorting, and a filter.| asset objects. |
|`Get-V1AssetPaged`| `v1paged` | Superset of Get-V1Asset, but does paging. | Object with assets and the total. | 
|`Get-V1AssetFilter`| `v1filter` | Returns an object with properties for all the attributes.  A variable of this type can then be used to tab complete for the -filter paramter of Get-V1Asset, and Get-V1AssetPaged since those can be complex| asset object with all writable attributes but no values |
|`New-V1Asset`| `v1new` | Creates an asset from scratch or from a hash table of values, validating against meta.  It can fill in required parameters.  Pass this to ```Save-V1Meta``` to add or update an asset. | asset object |
|`Set-V1Value`| `v1set` | Sets a value on an object, adding it if not there.  Tab-completion works and the names are validated | The asset passed into it (for fluency) |
|`Save-V1Asset`| `v1save` | Saves the asset.  If it has an ```id``` attribute it will try to update, it otherwise it will create it.  Assets from ```New-V1Asset``` do not have an id, ones from ```Get-V1Asset``` will. | Asset as returned from the server which has minimal attributes. |
|`Remove-V1Asset`| `v1del` | Removes an asset on the server with a soft-delete.  The ID with the moment is returned. | Oid with the moment |
|`New-V1AdminUser`|| Creates a new Administrator user with roles and scope access.  This is not strictly an SDK function, but used to populate users for regression testing ||

### The Asset Object in the PowerShell SDK
The PowerShell SDK converts the data returned from REST into simple PSCustomObjects to make them easy to work with.  It also loads meta so validatation and tab-completion can be used to easily discover valid asset and attribute name.

### Meta Functions
Meta is used by the SDK for validation, and can be used to explore meta by showing the asset types and attributes available. 

| Function                | Alias | Description |
|-------------------------|-------|-------------|
|`Get-V1Meta`| `v1meta` | Loads and caches meta locally.  if assetType specified, it only returns a hash table for that type.  SDK functions call this to load meta.  Once this is called you can use tab completion for assetType and assetAttribute names for most functions! (Use -Force to reload from the server)|
|`Get-V1MetaAssetType`| `v1asset` | Gets all the attributes for a given assetType, showing names, types, required, etc. |

## Getting help
All the functions have self-contained help accessed using the PowerShell help function, e.g. ```help Get-V1Asset```  Useful options are ```-full``` to display all the help, ```-examples``` to show just examples, or ```-showWindow``` to pop up a GUI.  Tab completion can be used to complete function names, parameters, asset types, and attributes (in most cases).  When in doubt, hit tab.

```Show-V1Help``` function will launch the browser with various web-based help from your server.  Tab through the options.

## Samples and Tests
The `Samples` folder has several samples. Filea ending in `Sample.ps1` are designed to be used in PowerShell ISE and highlighting a couple lines at a time and using F8 to run them.  At each pause you can run other commands in the PowerShell windows, including just dumping out variables.  The other files are scripts that show using the SDK to load test data.

The `Tests` folder has Pester test files.  First set credentials with Set-V1Connection, or set environment variables like the ```Tests\Set-Pester.ps1``` sample file.  Then do ``Invoke-Pester`` to run the tests.  Each file is named for the function it tests, so you may look at those for more examples of using the SDK. 

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

### TODOs
 * Always check case of assetType since get nothing if wrong
 * Implement remove relation
 * Make loading meta optional?
 
### Dones 
 * Filter helper for tab completion via object.  Take scriptblock or string