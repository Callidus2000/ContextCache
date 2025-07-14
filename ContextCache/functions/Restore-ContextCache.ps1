function Restore-ContextCache {
    <#
    .SYNOPSIS
    Restore variables from the PSFTaskEngineCache directly into the current scope for ad-hoc debugging and testing.

    .DESCRIPTION
    This function reads variables from the PSFTaskEngineCache (as used by the ContextCache module) and sets them as variables in the current (global) scope. It is designed to help you quickly re-initialize the variable state from a previous function call, so you can manually step through code or perform further debugging. You can restore all variables, or use include/exclude lists to filter which variables are set. If a function name is provided, only the parameters of that function are restored.

    .PARAMETER Name
    The key under which the variables were stored in the cache.

    .PARAMETER Include
    List of variable names to explicitly restore from the cache. If not specified, all variables are considered.

    .PARAMETER Exclude
    List of variable names to exclude from restoration. By default, this includes the values from the configuration key 'ContextCache.Restore.DefaultIgnoreVariables'.
    This configuration contains common variables that are typically not useful to restore, such as system variables, preferences and read only variables. You can modify this list in your configuration settings if needed.
    If you need to retrieve all variables, you can use "Get-ContextCache" instead.

    .PARAMETER FunctionName
    Name of the function whose parameters should be restored. If specified, only those parameters are restored.

    .EXAMPLE
    Restore-ContextCache -Name 'foo' -Include @('A','C')

    Restores variables A and C from the cache into the current context.

    .EXAMPLE
    Restore-ContextCache -Name 'JustTheParams'
    Write-Host $B

    Restores the parameters A and B from the cache and makes them available as variables in the current scope.

    .NOTES
    This function is part of the ContextCache module, which is designed to help debug PowerShell code by capturing and restoring variable states. See the module README for more details and usage examples.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("ContextCache.CacheKeys")]
        [string]$Name,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("ContextCache.VariableNames")]
        [string[]]$Include,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [PSFramework.TabExpansion.PsfArgumentCompleterAttribute("ContextCache.VariableNames")]
        [string[]]$Exclude=(get-psfconfigvalue -fullname 'ContextCache.Restore.DefaultIgnoreVariables'),
        [Parameter(Mandatory, ParameterSetName = 'FunctionReference')]
        [string]$FunctionName
    )
    # Determine the current module name
    # Retrieve the cached variables
    $cache = Get-PSFTaskEngineCache -Name $Name -Module "ContextCache"
    if (-not $cache) {
        Write-PSFMessage -Level Warning -Message "No ContextCache found for $Name."
        return
    }

    # If a function name is provided, get its parameters
    if ($FunctionName) {
        $Include = (Get-Command $FunctionName).Parameters.Keys
        Write-PSFMessage -Level Host -Message "Restoring only the parameters of the function $FunctionName"
    }

    # Exclude read-only and constant variables
    $Exclude += Get-Variable | Where-Object { $_.Options -match 'ReadOnly|Constant' } | Select-Object -ExpandProperty name

    # Determine which variables to restore
    $restoreVars = $cache.Keys | Where-Object { $_ -in $Include -or -not $Include } | Where-Object { $_ -notin $Exclude }

    # Inform about the variables being restored
    Write-PSFMessage -Level Host -Message "Restoring variables from $($Name): $($restoreVars -join ', ')"

    # Restore each variable
    foreach ($name in $restoreVars) {
        $value = $cache[$name]
        Write-PSFMessage -Level Verbose -Message "Setting $name to $value"
        Set-Variable -Name $name -Value $value -Force -ErrorAction Continue -Scope Global
    }

    # Final confirmation message
    Write-PSFMessage -Level Host -Message "Restored variables from $($Name): $($restoreVars -join ', ')"
}