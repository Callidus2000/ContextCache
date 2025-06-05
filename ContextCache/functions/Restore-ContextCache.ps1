function Restore-ContextCache {
    <#
    .SYNOPSIS
    Restores variables and parameters from the PSFTaskEngineCache into the current context.

    .DESCRIPTION
    This function reads variables from the PSFTaskEngineCache and sets them in the current scope.
    Optionally, the selection of variables can be controlled via include and exclude lists.
    The cache key and module name can be specified.

    .PARAMETER CacheKey
    The key under which the variables were stored.

    .PARAMETER Include
    List of variable names to explicitly restore.

    .PARAMETER Exclude
    List of variable names to exclude from restoration.

    .PARAMETER ModuleName
    Name of the module under which the cache was stored. Defaults to the current
    module name if available, otherwise '<unknown>'.

    .PARAMETER FunctionName
    Name of the function whose parameters should be restored.

    .EXAMPLE
    Restore-ContextCache -CacheKey 'foo' -Include @('A','C')

    Restores variables A and C from the cache into the current context.

    .EXAMPLE
    Restore-ContextCache -CacheKey 'foo' -FunctionName 'Test-Foo'

    Restores the parameters used in the function 'Test-Foo' from the cache.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CacheKey,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Include,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Exclude,
        [string]$ModuleName,
        [Parameter(Mandatory, ParameterSetName = 'FunctionReference')]
        [string]$FunctionName
    )
    # Determine the current module name
    $currentModuleName = if ($ModuleName) { $ModuleName } else { $MyInvocation.MyCommand.ModuleName }
    if (-not $currentModuleName) { $currentModuleName = '<unknown>' }

    # Retrieve the cached variables
    $cache = Get-PSFTaskEngineCache -Name $CacheKey -Module $currentModuleName
    if (-not $cache) {
        Write-PSFMessage -Level Warning -Message "No cache found for $currentModuleName.$CacheKey."
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
    Write-PSFMessage -Level Host -Message "Restoring variables from $currentModuleName.$($CacheKey): $($restoreVars -join ', ')"

    # Restore each variable
    foreach ($name in $restoreVars) {
        $value = $cache[$name]
        Write-PSFMessage -Level Verbose -Message "Setting $name to $value"
        Set-Variable -Name $name -Value $value -Force -ErrorAction Continue -Scope Global
    }

    # Final confirmation message
    Write-PSFMessage -Level Host -Message "Restored variables from $currentModuleName.$($CacheKey): $($restoreVars -join ', ')"
}