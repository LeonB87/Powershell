<#
    .SYNOPSIS
    Script to generate TOC that works on Github

    .DESCRIPTION
    Script to generate TOC that work on Github. It reads a target Markdown file and convert the headers to a TOC with a link that works on Github.
    This script originated because I wanted an automated way to include an TOC that I've used on Azure DevOps. Unfortunately, [[_TOC_]] doesn't work on Github.

    .PARAMETER Path
    This is the Path to a Markdown file that you want to generate a TOC for. Must contains between 1 and 5 # characters.

    .EXAMPLE
    .\Generate-GithubTOC -Path '\scripts\MyMarkdown.md'

    .NOTES
    Version:        1.1.0;
    Author:         Léon Boers;
    Creation Date:  20-03-2021;
    Purpose/Change: Initial script development;

    Version:1.1.0:Refactored the entire script to read an entire Markdown and take into account different levels of headers;
    #>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Path
)
BEGIN {
    Write-Verbose ("Supplied Path      : $($Path)")

    function Get-Markdownheader {
        param(
            $InputString
        )
        switch -regex ($InputString) {
            "^#\s\S*" {
                Write-Verbose ("Header level 1 detected")
                $str = $InputString.Split("#")[1].Trim()
                return ("- [$($str)](#$($str.replace(' ','-').ToLower()))")
            }
            "^##\s\S*" {
                Write-Verbose ("Header level 2 detected")
                $str = $InputString.Split("##")[1].Trim()
                return ("     * [$($str)](#$($str.replace(' ','-').ToLower()))")
            }
            "^###\s\S*" {
                Write-Verbose ("Header level 3 detected")
                $str = $InputString.Split("###")[1].Trim()
                return ("         + [$($str)](#$($str.replace(' ','-').ToLower()))")
            }
            "^####\s\S*" {
                Write-Verbose ("Header level 4 detected")
                $str = $InputString.Split("####")[1].Trim()
                return("             - [$($str)](#$($str.replace(' ','-').ToLower()))")
            }
            "^#####\s\S*" {
                Write-Verbose ("Header level 5 detected")
                $str = $InputString.Split("#####")[1].Trim()
                return("                 * [$($str)](#$($str.replace(' ','-').ToLower()))")
            }
            Default {
                Write-verbose ("unknown switch condition detected")
            }
        }
    }
}
PROCESS {
    $headers = @(Get-Content -Path $Path) -match '^#+'

    if ($headers.count -ne 0) {
        # Determine minimum depth of the headers. It should start with a single #, But in case the document does not start with that, we'll lower the others found.

        [int]$minimumlevel = 1
        [bool]$minimumlevelDetermined = $false
        [string[]]$TOC = $null

        while (!$minimumlevelDetermined) {
            if (($headers -match "^(#{$($minimumlevel)}\ )").count -ge 1) {
                Write-Verbose ("the minimum level of the header is $($minimumlevel) #: ")
                $minimumlevelDetermined = $true
            }
            else {
                if ($minimumlevel -ge 100) {
                    Write-Error ("No valid level could be determined. Please check your markdown!")
                    exit
                }
                $minimumlevel++
            }
        }

        foreach ($header in $headers) {
            if ($minimumlevel -ge 2) {
                $header = $header.ToString().Substring($minimumlevel - 1)
                Write-Verbose ("New header after minimumlevel processing: '$($header)'")
            }
            else {
                Write-Verbose ("Processing '$($header)'")
            }

            $TOC += Get-Markdownheader $header

        }

        Write-Verbose ("Final TOC:")
        foreach ($TocEntry in $TOC) {
            Write-Verbose ($TocEntry)
        }
    }
}
END {
    return $TOC
}