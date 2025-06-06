<#
.SYNOPSIS
Registers a PSFramework TEPP scriptblock for SMAX entity properties.

.DESCRIPTION
This function registers a TEPP scriptblock named "SMAX.EntityProperties". It
retrieves the connection information and fetches entity properties based on
the provided entity type and command name.

.PARAMETER Name
The name of the TEPP scriptblock to register.

.PARAMETER ScriptBlock
The scriptblock to register.

.EXAMPLE
Register-PSFTeppScriptblock -Name "SMAX.EntityProperties" -ScriptBlock { ... }

#>
Register-PSFTeppScriptblock -Name "ContextCache.VariableNames" -ScriptBlock {
    try {
        $cacheKey = $fakeBoundParameter.Name
        if ([string]::IsNullOrEmpty($cacheKey)) { return}
        $cacheVarNames = Get-PSFTaskEngineCache -Name "___CACHEKEYVARNAMES" -Module 'ContextCache'
        return $cacheVarNames.$cacheKey
    }
    catch {
        return "Error"
    }
}
