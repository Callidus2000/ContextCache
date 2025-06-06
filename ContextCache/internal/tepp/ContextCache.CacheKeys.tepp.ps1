<#
.SYNOPSIS
Registers a PSFramework Tab Expansion Plus Plus (TEPP) script block for
SMAX entity types.

.DESCRIPTION
The TEPP script block retrieves all entity types from the SMAX configuration.
If the command name matches 'SMAXComment', it returns only those definitions
that have a 'Comments' property. The TEPP is used to provide dynamic
completion for entity types in SMAX.
#>
Set-PSFTaskEngineCache -Name "___CACHEKEYS" -Module 'ContextCache' -Value @()
Set-PSFTaskEngineCache -Name "___CACHEKEYVARNAMES" -Module 'ContextCache' -Value @{}

Register-PSFTeppScriptblock -Name "ContextCache.CacheKeys" -ScriptBlock {
    Write-PSFMessage -Message "Starte TEPP ContextCache.CacheKeys"
    try {
        return Get-PSFTaskEngineCache -Name "___CACHEKEYS" -Module 'ContextCache'
    }
    catch {
        return "Error $_"
    }
}
