function Save-ContextCache {
    <#
        .SYNOPSIS
        Speichert Variablen und Parameter aus dem Scope der aufrufenden Funktion im PSFTaskEngineCache.

        .DESCRIPTION
        Diese Funktion extrahiert Variablen und Parameter aus dem Scope der aufrufenden Funktion
        und speichert sie als Hashtable im PSFTaskEngineCache. Optional kann die Auswahl der Variablen
        über Include- und Exclude-Listen gesteuert werden. Der CacheKey und der Modulname können
        angegeben werden.

        .PARAMETER CacheKey
        Schlüsselname, unter dem die Variablen gespeichert werden.

        .PARAMETER CurrentVariables
        Array aller zu speichernden Variablen, können über 'Get-Variable -Scope Local' ermittelt werden

        .PARAMETER Include
        Liste von Variablennamen, die explizit gespeichert werden sollen.

        .PARAMETER Exclude
        Liste von Variablennamen, die vom Speichern ausgeschlossen werden sollen.

        .PARAMETER ModuleName
        Name des Moduls, unter dem der Cache gespeichert wird. Standardwert ist der aktuelle
        Modulname, falls vorhanden, sonst '<unknown>'.

        .EXAMPLE
        Save-ContextCache -CacheKey 'foo' -Include @('A','C') -CurrentVariables (Get-Variable -Scope Local)

        Speichert die Variablen A und C aus den aktuellen Scope im Cache unter dem Schlüssel 'foo'.

        .EXAMPLE
        Restore-ContextCache -CacheKey 'foo' -CurrentVariables (Get-Variable -Scope Local) -FunctionName 'Test-Foo'

        Speichert die Variablen in den Cache, die als Parameter bei der Funktion 'Test-Foo' verwendet werden

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CacheKey,
        [Parameter(Mandatory)]
        $CurrentVariables,
        # [Parameter(Mandatory)]
        # $BoundParameters,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Include,
        [Parameter(Mandatory = $false, ParameterSetName = 'includeExclude')]
        [string[]]$Exclude,
        [string]$ModuleName,
        [Parameter(Mandatory, ParameterSetName = 'FunctionReference')]
        [string]$FunctionName
    )
    # Hole alle Variablen und Parameter aus dem Scope der aufrufenden Funktion
    $callerVars = $CurrentVariables
    if ($FunctionName){
        $Include=(Get-Command $FunctionName).Parameters.Keys
        Write-PSFMessage -Level Host -Message "Sichere nur die Parameter der Function $FunctionName"
    }
    # Erstelle die Hashtable
    $result = @{}
    foreach ($var in $callerVars) {
        $name = $var.Name
        Write-PSFMessage $name -Level Verbose
        if ($Include -and $name -notin $Include) { continue }
        if ($Exclude -and $name -in $Exclude) { continue }
        $result[$name] = $var.Value
    }
    $currentModuleName = if ($ModuleName) { $ModuleName } else { $MyInvocation.MyCommand.ModuleName }
    if (-not $currentModuleName) {
        $currentModuleName = '<unknown>'
        Write-PSFMessage -Level Verbose -Message "Kein Modulname gefunden, verwende '<unknown>'"
    }
    Write-PSFMessage -Level Host -Message "In $currentModuleName.$CacheKey gespeicherte Variablen: $($result.Keys -join ', ')"
    Write-PSFMessage -Level Host -Message "Abrufbar über 'Get-PSFTaskEngineCache -Name $CacheKey -Module $currentModuleName'"
    Set-PSFTaskEngineCache -Name $CacheKey -Value $result -Module $currentModuleName
}

