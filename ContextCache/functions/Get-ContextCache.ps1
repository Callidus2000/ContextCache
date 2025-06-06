function Get-ContextCache {
    <#
    .SYNOPSIS
    Retrieves variables from the PSFTaskEngineCache into the current context.

    .DESCRIPTION
    This function reads variables from the PSFTaskEngineCache and returns them as a HashTable.

    .PARAMETER Name
    The key under which the variables were stored.

    .PARAMETER Include
    List of variable names to explicitly restore.

    .PARAMETER Exclude
    List of variable names to exclude from restoration.

    .EXAMPLE
    Get-ContextCache -Name 'foo' -Include @('A','C')

    Restrieves variables A and C from the cache

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