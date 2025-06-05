function Restore-ContextCache {
    <#
        .SYNOPSIS
        Stellt Variablen und Parameter aus dem PSFTaskEngineCache im aktuellen Kontext wieder her.

        .DESCRIPTION
        Diese Funktion liest Variablen aus dem PSFTaskEngineCache und legt sie im aktuellen Scope an.
        Optional kann die Auswahl der Variablen über Include- und Exclude-Listen gesteuert werden.
        Der CacheKey und der Modulname können angegeben werden.

        .PARAMETER CacheKey
        Schlüsselname, unter dem die Variablen gespeichert wurden.

        .PARAMETER Include
        Liste von Variablennamen, die explizit wiederhergestellt werden sollen.

        .PARAMETER Exclude
        Liste von Variablennamen, die von der Wiederherstellung ausgeschlossen werden sollen.

        .PARAMETER ModuleName
        Name des Moduls, unter dem der Cache gespeichert wurde. Standardwert ist der aktuelle
        Modulname, falls vorhanden, sonst '<unknown>'.

        .EXAMPLE
        Restore-ContextCache -CacheKey 'foo' -Include @('A','C')

        Stellt die Variablen A und C aus dem Cache im aktuellen Kontext wieder her.
        .EXAMPLE
        Restore-ContextCache -CacheKey 'foo' -FunctionName 'Test-Foo'

        Stellt die Variablen aus dem Cache wieder her, die als Parameter bei der Funktion 'Test-Foo' verwendet werden
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CacheKey,
        [Parameter(Mandatory=$false, ParameterSetName = 'includeExclude')]
        [string[]]$Include,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Exclude,
        [string]$ModuleName,
        [Parameter(Mandatory, ParameterSetName = 'FunctionReference')]
        [string]$FunctionName
    )
    $currentModuleName = if ($ModuleName) { $ModuleName } else { $MyInvocation.MyCommand.ModuleName }
    if (-not $currentModuleName) { $currentModuleName = '<unknown>' }
    $cache = Get-PSFTaskEngineCache -Name $CacheKey -Module $currentModuleName
    if (-not $cache) {
        Write-PSFMessage -Level Warning -Message "Kein Cache für $currentModuleName.$CacheKey gefunden."
        return
    }
    if ($FunctionName) {
        $Include = (Get-Command $FunctionName).Parameters.Keys
        Write-PSFMessage -Level Host -Message "Sichere nur die Parameter der Function $FunctionName"
    }
    $Exclude += Get-Variable | Where-Object { $_.Options -match 'ReadOnly|Constant' } | Select-Object -ExpandProperty name
    $restoreVars = $cache.Keys | Where-Object { $_ -in $Include -or -not $Include } | Where-Object { $_ -notin $Exclude }
    Write-PSFMessage -Level Host -Message "Stelle Variablen aus $currentModuleName.$CacheKey wieder her: $($restoreVars -join ', ')"
    foreach ($name in $restoreVars) {
        # if ($Include -and $name -notin $Include) { continue }
        # if ($Exclude -and $name -in $Exclude) { continue }
        $value = $cache[$name]
        Write-PSFMessage -Level Verbose -Message "Setze $name auf $value"
        Set-Variable -Name $name -Value $value -Force -ErrorAction Continue -Scope Global
    }
    Write-PSFMessage -Level Host -Message "Wiederhergestellte Variablen aus $currentModuleName.$CacheKey`: $($restoreVars -join ', ')"
}