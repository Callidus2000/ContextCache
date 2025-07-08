function Save-ContextCache {
    <#
    .SYNOPSIS
    Save variables and parameters from the calling function's scope into the PSFTaskEngineCache for later retrieval or debugging.

    .DESCRIPTION
    This function extracts variables and parameters from the calling function's scope and stores them as a hashtable in the PSFTaskEngineCache (as used by the ContextCache module). It is designed to help you capture the state of the local variable scope for ad-hoc debugging, testing, or later restoration. You can save all variables, or use include/exclude lists to filter which variables are stored. If a function name is provided, only the parameters of that function are saved.

    .PARAMETER Name
    The key under which the variables will be stored in the cache.

    .PARAMETER CurrentVariables
    Array of all variables to be saved, can be retrieved using 'Get-Variable -Scope Local'.

    .PARAMETER Include
    List of variable names to explicitly include in the cache. If not specified, all variables are considered.

    .PARAMETER Exclude
    List of variable names to exclude from the cache.

    .PARAMETER FunctionName
    Name of the function whose parameters should be saved. If specified, only those parameters are saved.

    .EXAMPLE
    Save-ContextCache -Name 'foo' -Include @('A','C') -CurrentVariables (Get-Variable -Scope Local)

    Saves variables A and C from the current scope into the cache under the key 'foo'.

    .EXAMPLE
    Save-ContextCache -Name 'JustTheParams' -CurrentVariables (Get-Variable -Scope Local) -FunctionName 'foo'

    Saves the parameters used in the function 'foo' into the cache.

    .NOTES
    This function is part of the ContextCache module, which is designed to help debug PowerShell code by capturing and restoring variable states. See the module README for more details and usage examples.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        $CurrentVariables,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Include,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Exclude,
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
        # Write-PSFMessage $var.Name -Level Verbose
        if ($Include -and $var.Name -notin $Include) { continue }
        if ($Exclude -and $var.Name -in $Exclude) { continue }
        $result[$var.Name] = $var.Value
    }


    Write-PSFMessage -Level Host -Message "Variables stored in $($Name): $($result.Keys -join ', ')"
    Write-PSFMessage -Level Host -Message "Retrievable via 'Get-ContextCache -Name $Name' as a HashTable"
    $restoreCommand = "Restore-ContextCache -Name $Name " #+ ($null -eq $FunctionName ? "" : "[-FunctionName $FunctionName]")
    Write-PSFMessage -Level Host -Message "Retrievable via '$restoreCommand' as global variables"

    Set-PSFTaskEngineCache -Name $Name -Value $result -Module 'ContextCache'
    $existingCacheKeys=[array](Get-PSFTaskEngineCache -Name "___CACHEKEYS" -Module 'ContextCache')
    if ($existingCacheKeys -notcontains $Name){
        $existingCacheKeys+=$Name
        Write-PSFMessage -Message "Adding Name $Name to TEPP"
        Write-PSFMessage -Message "`$existingCacheKeys=$existingCacheKeys"
    }else{
        Write-PSFMessage -Message "Not adding Name $Name to TEPP, `$existingCacheKeys=$existingCacheKeys"
    }
    $cacheVarNames = Get-PSFTaskEngineCache -Name "___CACHEKEYVARNAMES" -Module 'ContextCache'
    $cacheVarNames.$Name = $result.Keys
    Set-PSFTaskEngineCache -Name "___CACHEKEYVARNAMES" -Module 'ContextCache' -Value $cacheVarNames
    Set-PSFTaskEngineCache -Name "___CACHEKEYS" -Module 'ContextCache' -Value $existingCacheKeys
}

