function Save-ContextCache {
    <#
        .SYNOPSIS
        Saves variables and parameters from the calling function's scope into the PSFTaskEngineCache.

        .DESCRIPTION
        This function extracts variables and parameters from the calling function's scope
        and stores them as a hashtable in the PSFTaskEngineCache. Optionally, the selection of variables
        can be controlled via include and exclude lists. The cache key and module name can be specified.

        .PARAMETER CacheKey
        The key under which the variables will be stored.

        .PARAMETER CurrentVariables
        Array of all variables to be saved, can be retrieved using 'Get-Variable -Scope Local'.

        .PARAMETER Include
        List of variable names to explicitly include in the cache.

        .PARAMETER Exclude
        List of variable names to exclude from the cache.

        .PARAMETER ModuleName
        Name of the module under which the cache is stored. Defaults to the current
        module name if available, otherwise '<unknown>'.

        .PARAMETER FunctionName
        Name of the function whose parameters should be saved.

        .EXAMPLE
        Save-ContextCache -CacheKey 'foo' -Include @('A','C') -CurrentVariables (Get-Variable -Scope Local)

        Saves variables A and C from the current scope into the cache under the key 'foo'.

        .EXAMPLE
        Save-ContextCache -CacheKey 'foo' -CurrentVariables (Get-Variable -Scope Local) -FunctionName 'Test-Foo'

        Saves the parameters used in the function 'Test-Foo' into the cache.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CacheKey,
        [Parameter(Mandatory)]
        $CurrentVariables,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Include,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Exclude,
        [string]$ModuleName,
        [Parameter(Mandatory, ParameterSetName = 'FunctionReference')]
        [string]$FunctionName
    )
    if ($FunctionName) {
        $Include = (Get-Command $FunctionName).Parameters.Keys
        Write-PSFMessage -Level Host -Message "Saving only the parameters of the function $FunctionName"
    }

    # Create the hashtable
    $result = @{}
    foreach ($var in $CurrentVariables) {
        $name = $var.Name
        Write-PSFMessage $name -Level Verbose
        if ($Include -and $name -notin $Include) { continue }
        if ($Exclude -and $name -in $Exclude) { continue }
        $result[$name] = $var.Value
    }

    $currentModuleName = if ($ModuleName) { $ModuleName } else { $MyInvocation.MyCommand.ModuleName }
    if (-not $currentModuleName) {
        $currentModuleName = '<unknown>'
        Write-PSFMessage -Level Verbose -Message "No module name found, using '<unknown>'"
    }

    Write-PSFMessage -Level Host -Message "Variables stored in $currentModuleName.$CacheKey: $($result.Keys -join ', ')"
    Write-PSFMessage -Level Host -Message "Retrievable via 'Get-PSFTaskEngineCache -Name $CacheKey -Module $currentModuleName' as a HashTable"
    $restoreCommand = "Restore-ContextCache -CacheKey $CacheKey -Module $currentModuleName" + ($null -eq $FunctionName ? "" : "[-FunctionName $FunctionName]")
    Write-PSFMessage -Level Host -Message "Retrievable via '$restoreCommand' as global variables"

    Set-PSFTaskEngineCache -Name $CacheKey -Value $result -Module $currentModuleName

}

