function Get-ContextCache {
    <#
    .SYNOPSIS
    Retrieve variables from the PSFTaskEngineCache as a hashtable for debugging and ad-hoc testing.

    .DESCRIPTION
    This function reads variables from the PSFTaskEngineCache (as used by the ContextCache module) and returns them as a hashtable. It is designed to help you extract the state of the local variable scope from a previous function call, so you can perform ad-hoc tests or debugging with the captured data. You can either restore all variables, or use include/exclude lists to filter which variables are returned.

    .PARAMETER Name
    The key under which the variables were stored in the cache.

    .PARAMETER Include
    List of variable names to explicitly restore from the cache. If not specified, all variables are considered.

    .PARAMETER Exclude
    List of variable names to exclude from restoration.

    .EXAMPLE
    Get-ContextCache -Name 'foo' -Include @('A','C')

    Returns variables A and C from the cache as a hashtable.

    .EXAMPLE
    $vars = Get-ContextCache -Name 'JustTheParams'
    $vars['A']

    Retrieves the parameters A and B from the cache and accesses variable A.

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
        [string[]]$Exclude
    )
    # Determine the current module name
    # Retrieve the cached variables
    $cache = Get-PSFTaskEngineCache -Name $Name -Module "ContextCache"
    Write-PSFMessage -Level Warning -Message "Cache for $Name=$cache"
    if (-not $cache) {
        Write-PSFMessage -Level Warning -Message "No ContextCache found for $Name."
        return
    }

    # Exclude read-only and constant variables
    $Exclude += Get-Variable | Where-Object { $_.Options -match 'ReadOnly|Constant' } | Select-Object -ExpandProperty name

    # Determine which variables to restore
    $restoreVars = $cache.Keys | Where-Object { $_ -in $Include -or -not $Include } | Where-Object { $_ -notin $Exclude }

    # Inform about the variables being restored
    Write-PSFMessage -Level Host -Message "Restoring variables from $($Name): $($restoreVars -join ', ')"
    $result=@{}
    # Restore each variable
    foreach ($name in $restoreVars) {
        $value = $cache[$name]
        Write-PSFMessage -Level Verbose -Message "Setting $name to $value"
        $result.$name=$value
    }
    return $result
}