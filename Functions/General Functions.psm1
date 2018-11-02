<#===========================================================================
Created by: Léon Boers (Ictivity)
Github: https://github.com/LeonB87/Scripts

Versions:
0.01 - 30-10-2018 - LBS - First Setup of Module files - Added "Get-OpenFile"
0.02 - 02-11-2018 - LBS - Added LogScriptProgression

===========================================================================#>
Function Get-OpenFile() {
    <#
    .SYNOPSIS
    Displays a Open File window to select a file

    .DESCRIPTION
    Shows a Open File Dialog during runtime to select a file for further processing.

    .PARAMETER initialDirectory
    Pass an Initual directory where the Open File Dialog should start. Defaults to $ENV:USERPROFILE

    .PARAMETER Filter
    Parameter description

    .EXAMPLE
    $CSVFile = Get-OpenFile -initialDirectory C:\Excel\Exports\ -Filter CSV

    .EXAMPLE
    $myFile = Get-OpenFile

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param(
        # Pass an Initual directory where the Open File Dialog should start. Defaults to $ENV:USERPROFILE
        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Enter the initial directory for the filebrowser to open")]
        [string[]]
        $initialDirectory = $ENV:USERPROFILE,

        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
            Position = 1,
            HelpMessage = "Select a pre-defined filter")]
        [ValidateSet(
            "TXT",
            "CSV",
            "LOG"
        )]
        [string[]]
        $Filter
    )
    Begin {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

        #Defining default filters for regular used files.
        switch ($Filter) {
            "TXT" { $SelectionFilter = "Text files (*.txt)|*.txt" }
            "LOG" { $SelectionFilter = "Log files (*.log)|*.log" }
            "CSV" { $SelectionFilter = "CSV files (*.CSV)|*.CSV" }
            Default {$SelectionFilter = "" }
        }

    }
    Process {
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.Filter = $SelectionFilter
        $OpenFileDialog.ShowDialog() | Out-Null
        $OpenFileDialog.filename
        $OpenFileDialog.ShowHelp = $true
        return $OpenFileDialog
    }
    End {

    }
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

    if (([System.Diagnostics.EventLog]::GetEventLogs() | Where-Object Log -eq $EventlogName | Measure-Object).Count -eq 0) {
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

function LogScriptProgression () {
    <#
    .SYNOPSIS
    Simple function to start a transcript of a powershell script
    
    .DESCRIPTION
    Simple function to start a transcript of a powershell script. Also cleans up old files.
    
    .PARAMETER LogDirectory
    Enter the location where to store the logfiles
    
    .PARAMETER LogName
    The name of the logfile. The Current Date gets appended to this.
    
    .PARAMETER LogRetentionDays
    The ammount of days to keep old log files. Defauls to 31
    
    .PARAMETER LogDateFormat
    The format of the date that gets appended to the logfile. Defaults to dd-MM-yyyy (example: 02-11-2018)
    
    .EXAMPLE
    LogScriptProgression -LogDirectory "\\ubc.local\DFS\CentralLogging\AD-Cleanup" -LogName AD_CleanupScript -LogRetentionDays 93

    % your script %

    stop-transcript
    
    .NOTES
  	===========================================================================
    Created by: Léon Boers (Ictivity)
    Github: https://github.com/LeonB87/Scripts

    Versions:
    0.00 - 02-11-2018 - LBS - Initial Release
	===========================================================================
    #>
    [CmdletBinding()]
    Param (
        #Supply the directory to store the Logfile
        [Parameter(
            Mandatory = $true
        )]
        [String]$LogDirectory,
        #Supply the name of the Logfile
        [Parameter(
            Mandatory = $true
        )]
        [String]$LogName,
        #Supply the ammount of days you want to keep old logfile. Defaults to 31 days
        [Parameter(
            Mandatory = $false
        )]
        [Int]$LogRetentionDays = 31,
        #Supply the date format you want to add to the name of the. Defaults to dd-MM-yyyy (example: 02-11-2018)
        [Parameter(
            Mandatory = $false
        )]
        [string]$LogDateFormat = "dd-MM-yyyy"
    )

    If (!(Test-Path $LogDirectory)) {
        New-Item -ItemType Directory $LogDirectory -Force | Out-Null
    }

    $Date = Get-Date -Format ($LogDateFormat)
    Start-Transcript -Append -Path "$($LogDirectory)\$($LogName).$($Date).log" | Out-Null

    Write-Output "Looking for old Logfile. Retentiondays is set to: $($LogRetentionDays) "
    $OldLogFiles = Get-ChildItem -Path $LogDirectory -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt `
        ((Get-date).AddDays(-$LogRetentionDays)) -and $_.Name -like "*.log"} 

    foreach ($OldLogFile in $OldLogFiles) {
        Write-Output "Removing Old Logfile $OldLogFile"
        try {
            Remove-Item $OldLogFile.FullName -Force
        }
        catch {
            Write-Output "Failed to delete old Logfile $($OldLogFile.FullName)"
        }
    }
}

function Log ($Message) {

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