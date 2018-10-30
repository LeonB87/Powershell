Function Get-OpenFile($initialDirectory) { 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    $OpenFileDialog.ShowHelp = $true
}

Function Get-OpenTextFile($initialDirectory) { 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Text files (*.txt)|*.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    $OpenFileDialog.ShowHelp = $true
}

Function Get-OpenLogFile($initialDirectory) { 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Text files (*.log)|*.log"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    $OpenFileDialog.ShowHelp = $true
}

Function Get-OpenCSVFile($initialDirectory) { 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Text files (*.CSV)|*.CSV"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    $OpenFileDialog.ShowHelp = $true
}

function New-EventLogSource {
    param
    (
        [Parameter(Mandatory = $true,
            Position = 2)]
        [String]$SourceName,
        [Parameter(Mandatory = $true,
            Position = 1)]
        [String]$EventlogName
    )

    if (([System.Diagnostics.EventLog]::GetEventLogs() | where Log -eq $EventlogName | measure).Count -eq 0) {
        Write-Host "Creating eventlog"
        New-EventLog -LogName $EventlogName -Source $SourceName
    }

    # Check if eventsource exists, if not exists then it will throw an exception, so we create it there    
    $SourceExists = $false
    try {
        $SourceExists = [System.Diagnostics.EventLog]::SourceExists($SourceName)
    }
    catch {
        $SourceExists = $false
    }

    if ($SourceExists -ne $true) {
        Write-Host "Creating eventsource" -ForegroundColor Blue
        New-EventLog -LogName $EventlogName -Source $SourceName
        Write-EventLog -LogName $EventlogName -Source $SourceName -EventId 1 -EntryType Information -Message "$Sourcename Event Source successfully created"
    }
}

function LogWarning ($Message) {
    # * Nodig dat er een variabelen $WarningLog aangemaakt is. Is deze er niet, dan schrijven we niets weg.
    if ($Warninglog -eq "") {
        Write-verbose '$WarningLog is leeg! defineer dit in je code'
    }
    else {
        if (!(test-path $WarningLog)) {
            write-output "Logfile niet aanwezig. Proberen deze aan te maken"
            new-item $WarningLog -ItemType File -Force
        }
        else {
            $Message | Out-File $WarningLog -Encoding utf8 -NoClobber -Append
        }
    }
}

function PowershellErrorCheck () {
    LogWarning "**************************************************************"
    LogWarning "Einde van script behaald. Controleren op Powershell Errors en deze registreren"
    if ($Error -ne $null) {
        LogWarning ("Er zijn " + $Error.Count + "powershell error(s) gevonden. Controleer onderstaande meldingen:" )
        ForEach ($Line in $Error) {
            LogWarning $Line
        }
    }
    else {
        LogWarning ("Er zijn " + $Error.Count + "powershell errors gevonden.")
    }
}