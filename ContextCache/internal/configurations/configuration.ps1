<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
Set-PSFConfig -Module 'ContextCache' -Name 'Example.Setting' -Value 10 -Initialize -Validation 'integer' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>

Set-PSFConfig -Module 'ContextCache' -Name 'Import.DoDotSource' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
Set-PSFConfig -Module 'ContextCache' -Name 'Import.IndividualFiles' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."
Set-PSFConfig -Module 'ContextCache' -Name 'Restore.DefaultIgnoreVariables' -Value @(
    "__PSFramework_SelectParam"
    "_"
    "^"
    "args"
    "EnabledExperimentalFeatures"
    "Error"
    "ErrorActionPreference"
    "ErrorView"
    "ExecutionContext"
    "foreach"
    "FormatEnumerationLimit"
    "HOME"
    "Host"
    "IsCoreCLR"
    "IsLinux"
    "IsWindows"
    "MaximumHistoryCount"
    "MyInvocation"
    "NestedPromptLevel"
    "null"
    "PID"
    "PROFILE"
    "ProgressPreference"
    "PSCmdlet"
    "PSCommandPath"
    "PSCulture"
    "PSDefaultParameterValues"
    "PSEdition"
    "PSEmailServer"
    "PSHOME"
    "PSItem"
    "PSNativeCommandUseErrorActionPreference"
    "PSScriptRoot"
    "PSSessionApplicationName"
    "PSSessionConfigurationName"
    "PSStyle"
    "PSVersionTable"
    "PWD"
    "ShellId"
    "StackTrace"
    "VerbosePreference"
    "WarningPreference"
    "WhatIfPreference"
) -Initialize -Validation 'StringArray' -Description "Using Restore-ContextCache these variables will be ignored by default"
