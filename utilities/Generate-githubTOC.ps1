<#
    .SYNOPSIS
    Script to generate TOC strings that work on Github

    .DESCRIPTION
    Script to generate TOC strings that work on Github. It uses a single input string and converts it to a link that works on Github.
    This script originated because I wanted an automated way to include an TOC that I've used on Azure DevOps. Unfortunately, [[_TOC_]] doesn't work on Github.

    .PARAMETER InputString
    This is the input string that the script will convert. Must contains between 1 and 5 # characters.

    .EXAMPLE
    Generate-GithubTOC -InputString '## header 2'

    .NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  20-03-2021;
    Purpose/Change: Initial script development;
    #>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$InputString
)
BEGIN {
    Write-Verbose ("Supplied InputString      : $($InputString)")
    $output = ""
}
PROCESS {

    switch -regex ($InputString) {
        "^#\s\S*" {
            Write-Verbose ("Header level 1 detected")
            $str = $InputString.Split("#")[1].Trim()
            $output = ("- [$($str)](#$($str.replace(' ','-')))")
        }
        "^##\s\S*" {
            Write-Verbose ("Header level 2 detected")
            $str = $InputString.Split("##")[1].Trim()
            $output = ("     * [$($str)](#$($str.replace(' ','-')))")
        }
        "^###\s\S*" {
            Write-Verbose ("Header level 3 detected")
            $str = $InputString.Split("###")[1].Trim()
            $output = ("         + [$($str)](#$($str.replace(' ','-')))")
        }
        "^####\s\S*" {
            Write-Verbose ("Header level 4 detected")
            $str = $InputString.Split("####")[1].Trim()
            $output = ("             - [$($str)](#$($str.replace(' ','-')))")
        }
        "^#####\s\S*" {
            Write-Verbose ("Header level 5 detected")
            $str = $InputString.Split("#####")[1].Trim()
            $output = ("                 * [$($str)](#$($str.replace(' ','-')))")
        }
        Default {
            Write-verbose ("unknown switch condition detected")
        }
    }
}
END {
    return $output
}