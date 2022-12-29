<#
    .SYNOPSIS
    Script to create a Tree view of a folder

    .DESCRIPTION
    Script to create a Tree view of a folder. It recurses through the folder and will collect all folders and files.
    It returns a Powershell Object by default and optionally Json

    .PARAMETER Path
    the root path you want to create a treesize off

    .PARAMETER outputType
    The defined output. This defaults to an Object.
    Accepts the following input;  Object (default), Json

    .EXAMPLE
    .\Get-FolderStructure -Path "C:\MyFolder"

    .EXAMPLE
    .\Get-FolderStructure -Path ".\" -outputType Json

    .NOTES
    Version:        1.0.0;
    Author:         Léon Boers;
    Creation Date:  22-03-2020;
    Purpose/Change: Initial script development;

    #>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Object", "Json")]
    [string]$outputType = "Object"
)
BEGIN {
    $FolderStructure = @()
    $CurrentFolderContent = @()
}
PROCESS {
    $folderItems = Get-ChildItem -Path $Path

    foreach ($item in $folderItems) {

        if ($item.PSIsContainer -eq "True") {
            $subtree = Get-FolderStructure -Path $item.FullName
            $FolderObject = [PSCustomObject]@{
                Name    = $item.name
                Type    = "Folder"
                content = $subtree

            }
            $CurrentFolderContent += $FolderObject
        }
        else {
            #is not a folder
            $FileObject = [PSCustomObject]@{
                Name = $item.name
                Type = "File"
            }

            $CurrentFolderContent += $FileObject
        }
    }
    $FolderStructure += ($CurrentFolderContent)
}
END {
    switch ($outputType) {
        "Object" {
            return $FolderStructure
        }
        "Json" {
            return $FolderStructure | ConvertTo-Json -Depth 100 -Compress
        }
        Default {}
    }
    return $FolderStructure
}