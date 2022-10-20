<#
    .SYNOPSIS
    This is a powershell script template

    .DESCRIPTION
    This is a very simple powershell script template to get started

    .PARAMETER stringParameter
    This is a string parameter as an example

    .EXAMPLE
    .\template -stringParameter "Hello"

    .NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  17-03-2020;
    Purpose/Change: Initial script development;

    #>
[cmdletBinding(DefaultParameterSetName = "default")]
param (
    [Parameter(Mandatory = $false, ParameterSetName = "default")]
    [ValidateNotNullOrEmpty()]
    [string]$stringParameter
)
BEGIN {
    Write-Verbose $stringParameter
}
PROCESS {

}
END {

}
