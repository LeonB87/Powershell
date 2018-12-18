function Get-Systeminformation () {
    <#
    .SYNOPSIS
    Retrieve simple system information about a computer.

    .PARAMETER Computer
    Specify a computer to retreive the information from. Uses WMI to gather the information, so make sure you have the correct privileges and Firewall Allows the connection.

    .EXAMPLE
    Get-Systeminformation

    get system inforamtion about the local machine the command is run on

    .EXAMPLE
    Get-Systeminformation  -Computer member-01.contoso.local

    Get system information about the remote computer remember-01.contoso.local. When no credentials supplied, this will be prompted upon execution

    .EXAMPLE
    Get-Systeminformation  -Computer member-01.contoso.local -credential $cred

    Get system information about the remote computer remember-01.contoso.local with supplied credentials

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Computername",
            ValueFromPipeline = $true
        )]
        [string]
        $Computer = "localhost",
        [Parameter(Mandatory = $false,
            Position = 1,
            HelpMessage = "Enter the remote credentials.")]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    if ($Computer -eq 'localhost') {
        $computerSystem = get-wmiobject Win32_ComputerSystem -Computer $Computer
        $computerBIOS = get-wmiobject Win32_BIOS -Computer $Computer
        $computerOS = get-wmiobject Win32_OperatingSystem -Computer $Computer
        $computerCPU = get-wmiobject Win32_Processor -Computer $Computer
    }
    else {
        if($Credential -eq [System.Management.Automation.PSCredential]::Empty) {
            $Credential = Get-Credential -Message 'Enter the credentials for the remote computer'
        }
        $computerSystem = get-wmiobject Win32_ComputerSystem -Computer $Computer -Credential $Credential
        $computerBIOS = get-wmiobject Win32_BIOS -Computer $Computer -Credential $Credential
        $computerOS = get-wmiobject Win32_OperatingSystem -Computer $Computer -Credential $Credential
        $computerCPU = get-wmiobject Win32_Processor -Computer $Computer -Credential $Credential
    }

    $Computerobj = New-Object PsObject -Property `
    @{
        "Computer name"     = [string] $computerSystem.Name;
        "Install Date"      = [string] $computerOS.ConvertToDateTime($computerOS.InstallDate)
        "Windows Edition"   = [string] $ComputerOS.Caption
        "Serial #"          = [string] $computerBIOS.SerialNumber;
        "Model"             = [string] $computerSystem.Model;
        "SKU"               = [string] $computerSystem.SystemSKUNumber;
        "BIOS Description"  = [string] $computerBIOS.Description;
        "CPU Model"         = [string] $computerCPU.Name;
    }

    <#    $computerOS = get-wmiobject Win32_OperatingSystem -Computer $Computer
    $computerCPU = get-wmiobject Win32_Processor -Computer $Computer
    $computerHDD = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter drivetype=3
    #>
    return $Computerobj
}