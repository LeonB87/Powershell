<#===========================================================================
Created by: Léon Boers (Ictivity)
Github: https://github.com/LeonB87/Scripts

Versions:
0.01 - 30-10-2018 - LBS - First Setup of Module files - Added "Select-File"
0.02 - 02-11-2018 - LBS - Added LogScriptProgression

===========================================================================#>
Function Select-File() {
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

function Log-ScriptProgression () {
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

function Convert-TextToBase64 () {
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = "Plain",
            HelpMessage = "Your Input"
        )]
        [string]$inputString,
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = "Secure",
            HelpMessage = "Your Secured String input"
        )]
        [securestring]$SecureInputString
    )
    BEGIN {

    }
    PROCESS {
        if (!($null -eq $SecureInputString)) {

            #$convertedInput = ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($inputString)))
            $convertedInput = ([System.Convert]::FromBase64String((ConvertFrom-SecureString $SecureInputString)))

            write-host "resultaat: " $convertedInput
        }
        else {
            $convertedInput = ([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($inputString)))
        }
    }
    END {
        return $convertedInput
    }
}

## Malware
function SuperDecrypt {
    param($script)

    $bytes = [Convert]::FromBase64String($script)
    ## XOR “encryption”
    $xorKey = 0x42
    for ($counter = 0; $counter -lt $bytes.Length; $counter++) {
        $bytes[$counter] = $bytes[$counter] -bxor $xorKey
    }
    [System.Text.Encoding]::Unicode.GetString($bytes)
}

function Clean-String {
    Param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            Position = 0,
            HelpMessage = "Enter your input")]
        [ValidateNotNullOrEmpty()]
        [String]$inputString,
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
            Position = 1,
            HelpMessage = "Do you want to trim the string?")]
        [ValidateSet(
            'true',
            'false'
        )]
        [string]$Trim = 'false',
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
            Position = 2,
            HelpMessage = "Do you want to remove diacritics?")]
        [ValidateSet(
            'true',
            'false'
        )]
        [string]$diacritics = 'false',
        [Parameter(Mandatory = $false,
            Position = 3,
            HelpMessage = "Do you want to remove ALL whitespaces?")]
        [ValidateSet(
            'true',
            'false'
        )]
        [string]$RemoveWhitespaces = 'false',
        [Parameter(Mandatory = $false,
            Position = 3,
            HelpMessage = "Do you want to remove the @ sign?")]
        [ValidateSet(
            'true',
            'false'
        )]
        [string]$RemoveATsign = 'false',
        [Parameter(Mandatory = $false,
            Position = 4,
            HelpMessage = "Do you want to replace the @ sign?")]
        [ValidateSet(
            'true',
            'false'
        )]
        [string]$ReplaceATsign = 'false'

    )
    [hashtable]$CharacterHashTable = @{
        # a
        'æ' = 'a'
        'à' = 'a'
        'â' = 'a'
        'ã' = 'a'
        'å' = 'a'
        'ā' = 'a'
        'ă' = 'a'
        'ą' = 'a'
        'ä' = 'a'
        'á' = 'a'
        
        # b
        'ƀ' = 'b'
        'ƃ' = 'b'
        
        # Tone six
        'ƅ' = 'b'
        
        # c
        'ç' = 'c'
        'ć' = 'c'
        'ĉ' = 'c'
        'ċ' = 'c'
        'č' = 'c'
        'ƈ' = 'c'
        
        # d
        'ď' = 'd'
        'đ' = 'd'
        'ƌ' = 'd'
        
        # e
        'è' = 'e'
        'é' = 'e'
        'ê' = 'e'
        'ë' = 'e'
        'ē' = 'e'
        'ĕ' = 'e'
        'ė' = 'e'
        'ę' = 'e'
        'ě' = 'e'
        
        # g
        'ĝ' = 'e'
        'ğ' = 'e'
        'ġ' = 'e'
        'ģ' = 'e'
        
        # h
        'ĥ' = 'h'
        'ħ' = 'h'
        
        # i
        'ì' = 'i'
        'í' = 'i'
        'î' = 'i'
        'ï' = 'i'
        'ĩ' = 'i'
        'ī' = 'i'
        'ĭ' = 'i'
        'į' = 'i'
        'ı' = 'i'
        
        # j
        'ĳ' = 'j'
        'ĵ' = 'j'
        
        # k
        'ķ' = 'k'
        'ĸ' = 'k'
        
        # l
        'ĺ' = 'l'
        'ļ' = 'l'
        'ľ' = 'l'
        'ŀ' = 'l'
        'ł' = 'l'
        
        # n
        'ñ' = 'n'
        'ń' = 'n'
        'ņ' = 'n'
        'ň' = 'n'
        'ŉ' = 'n'
        'ŋ' = 'n'
        
        # o
        'ð' = 'o'
        'ó' = 'o'
        'õ' = 'o'
        'ô' = 'o'
        'ö' = 'o'
        'ø' = 'o'
        'ō' = 'o'
        'ŏ' = 'o'
        'ő' = 'o'
        'œ' = 'o'
        
        # r
        'ŕ' = 'r'
        'ŗ' = 'r'
        'ř' = 'r'
        
        # s
        'ś' = 's'
        'ŝ' = 's'
        'ş' = 's'
        'š' = 's'
        'ß' = 'ss'
        'ſ' = 's'
        
        # t
        'ţ' = 't'
        'ť' = 't'
        'ŧ' = 't'
        
        # u
        'ù' = 'u'
        'ú' = 'u'
        'û' = 'u'
        'ü' = 'u'
        'ũ' = 'u'
        'ū' = 'u'
        'ŭ' = 'u'
        'ů' = 'u'
        'ű' = 'u'
        'ų' = 'u'
        
        # w
        'ŵ' = 'w'
        
        # y
        'ý' = 'y'
        'ÿ' = 'y'
        'ŷ' = 'y'
        
        # z
        'ź' = 'z'
        'ż' = 'z'
        'ž' = 'z'
    }

    if ($diacritics -eq 'True') {
        foreach ($key in $CharacterHashTable.Keys) {
            $inputString = $inputString -Replace ($key, $CharacterHashTable.$key)
        }
    }
    if ($Trim -eq 'True') {
        $inputString = $inputString.trim()
    }
    if ($RemoveWhitespaces -eq 'True') {
        $inputString = $inputString.Replace(" ", "")
    }
    if ($RemoveATsign -eq 'True') {
        $inputString = $inputString.Replace("@", "")
    }
    if ($ReplaceATsign -eq 'True') {
        $inputString = $inputString.Replace("@", "AT")
    }

    return $inputString
}