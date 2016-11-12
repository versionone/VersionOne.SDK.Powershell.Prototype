# Contributing to the VersionOne PowerShell SDK

 1. [Getting Involved](#getting-involved)
 2. [Reporting Bugs](#reporting-bugs)
 3. [Contributing Code](#contributing-code)

## Getting Involved

We need your help to make the VersionOne PowerShell SDK a useful tool for developing integrations and complementary applications! While third-party patches are absolutely essential, they are not the only way to get involved. You can help the project by discovering and [reporting bugs](#reporting-bugs), helping others on [StackOverflow](http://stackoverflow.com/questions/tagged/versionone), and reporting defects or enhancement requests as [GitHub issues](https://github.com/versionone/VersionOne.SDK.Powershell.Prototype/issues).

## Reporting Bugs

Before reporting a bug on the SDK's [issues page](https://github.com/versionone/VersionOne.SDK.Powershell.Prototype/issues), first make sure that your issue is caused by the SDK and not your application code (e.g. passing incorrect arguments to methods, etc.). Second, search the already reported issues for similar cases, and if it has been reported already, just add any additional details in the comments.

After you made sure that you have found a new bug, here are some tips for creating a helpful report that will make fixing it much easier and quicker:

 * Write a **descriptive, specific title**. Bad: *Problem with filtering*. Good: *Scope.Workitems always returns an empty list*.
 * Whenever possible, include **Function** info in the description.
 * Create a **simple test case** that demonstrates the bug.

## Contributing Code

### Making Changes to Source

If you are not yet familiar with the way GitHub works (forking, pull requests, etc.), be sure to read [the article about forking](https://help.github.com/articles/fork-a-repo) on the GitHub Help website &mdash; it will get you started quickly.

You should always write each batch of changes (feature, bugfix, etc.) in its own branch. Please do not commit to the `master` branch, or your unrelated changes will go into the same pull request.

You should also follow the code style and whitespace conventions of the original codebase.

### Source Code conventions
When in Rome....
 * Public functions should be in their own file in the Scripts folder and have the name of the function. (The V1.psm1 file loads all files in the Scripts folder and exports any names that follow the naming convention)
 * Public functions should be named <verb>-V1<singularNoun>.
 * Parameter names should look like the other functions.
 * An alias for the function should be created at the end of the file and start with v1.  
 * Use valueFromPipeline is possibly 
 * Use `Set-StrictMode -Version Latest`
 * Type and validate parameters with `[Validate*]` as possible.
 * Always use comment-based-help (see help about_comment_based_help for details).
 * Tab-completion helpers for completing AssetType and Attribute names are in Scripts\RegisterCompleter.ps1
 * Run your function through `Invoke-ScriptAnalyzer` to check of obvious style violations.

### Considerations for Accepting Patches

Before sending a pull request with a new feature, first check if it has been discussed before already (either on [GitHub issues](https://github.com/versionone/VersionOne.SDK.Powershell.Prototype/issues). If your feature or improvement did get merged into master, please consider submitting another pull request.
