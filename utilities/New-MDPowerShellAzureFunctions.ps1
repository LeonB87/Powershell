function New-MDPowerShellAzureFunctions {
    <#
.SYNOPSIS
    Script for generating Markdown documentation based on information in PowerShell script files.

.DESCRIPTION
    All PowerShell script files have synopsis attached on the document. With this script markdown files are generated and saved within the target folder.

.PARAMETER ScriptFolder
    The folder that contains the scripts

.PARAMETER OutputFolder
    The folder were to safe the markdown files

.PARAMETER ExcludeFolders
    Exclude folder for generation. This is a comma seperated list

.PARAMETER KeepStructure
    Specified to keep the structure of the subfolders

.PARAMETER IncludeWikiTOC
Include the TOC from the Azure DevOps wiki to the markdown files

.PARAMETER SummaryLinkPattern
The pattern for the url/ Defaults to '/Powershell/Scripts/'
this will create a link pointing to '/Powershell/Scripts/%script Basename%/%Script Name%.md

.PARAMETER SummaryTitleAsLink
Boolean wheter to add links in the Summary page to the specific powershell MD file

.NOTES
    Version:        1.0.2;
    Author:         3fifty | Maik van der Gaag | Léon Boers;
    Creation Date:  20-04-2020;
    Purpose/Change: Initial script development;
    1.0.0:          Initial Release;
    1.0.2:          Support Github TOC& centralized summary of the scripts;
    1.0.3:          Added links on summary page. New variables SummaryTitleAsLink & SummaryLinkPatern;

.EXAMPLE
    .\New-MDPowerShellScripts.ps1 -ScriptFolder "./" -OutputFolder "docs/powershell"  -ExcludeFolder ".local,test-templates" -KeepStructure $true -IncludeWikiTOC $false
.EXAMPLE
    .\New-MDPowerShellScripts.ps1 -ScriptFolder "./" -OutputFolder "docs/powershell"
.EXAMPLE
    .\New-MDPowerShellScripts.ps1 -ScriptFolder '.\Powershell\scripts\' -OutputFolder '.\Powershell\scripts\' -KeepStructure $true -WikiSummaryOutputfileName 'readme.md' -IncludeWikiSummary $true -IncludeWikiTOC $true -WikiTOCStyle 'Github' -SummaryTitleAsLink $true -SummaryLinkPattern '/Powershell/Scripts/'
#>
    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true, Position = 0)][string]$ScriptFolder,
        [Parameter(Mandatory = $true, Position = 1)][string]$OutputFolder,
        [Parameter(Mandatory = $false, Position = 2)][string]$ExcludeFolders,
        [Parameter(Mandatory = $false, Position = 3)][bool]$KeepStructure = $false,
        [Parameter(Mandatory = $false, Position = 4)][bool]$IncludeWikiTOC = $false,
        [Parameter(Mandatory = $false, Position = 5)][bool]$IncludeWikiSummary = $false,
        [Parameter(Mandatory = $false, Position = 6)][string]$WikiSummaryOutputfileName,
        [Parameter(Mandatory = $false, Position = 7)][ValidateSet('AzureDevOps','Github')][string]$WikiTOCStyle = 'AzureDevOps',
        [Parameter(Mandatory = $false, Position = 8)][bool]$SummaryTitleAsLink = $false,
        [Parameter(Mandatory = $false, Position = 9)][string]$SummaryLinkPattern = '/Powershell/Scripts/'
    )

    BEGIN {
        Write-Output ("ScriptFolder                 : $($ScriptFolder)")
        Write-Output ("OutputFolder                 : $($OutputFolder)")
        Write-Output ("ExcludeFolders               : $($ExcludeFolders)")
        Write-Output ("KeepStructure                : $($KeepStructure)")
        Write-Output ("IncludeWikiTOC               : $($IncludeWikiTOC)")
        Write-Output ("WikiTOCStyle                 : $($WikiTOCStyle)")
        Write-Output ("IncludeWikiSummary           : $($IncludeWikiSummary)")
        Write-Output ("WikiSummaryOutputfileName    : $($WikiSummaryOutputfileName)")

        $arrParameterProperties = @('DefaultValue', 'ParameterValue', 'PipelineInput', 'Position', 'Required')
        $scriptNameSuffix = '.md'
        $option = [System.StringSplitOptions]::RemoveEmptyEntries

        $exclude = $ExcludeFolders.Split(',', $option)

        function process-subproperties {
            param(
                [Parameter(Mandatory = $true)]
                [object]$object
            )
            BEGIN {
                Write-Verbose ("Proccesing '$($object.Name)' properties")

                $subArray = @{}
            }
            PROCESS {
                ("`r`n##### $($object.name) properties") | Out-File -FilePath $outputFile -Append
                ("`r`n| Property | Type | Accepted values | Description |") | Out-File -FilePath $outputFile -Append
                ('|-|-|-|-|') | Out-File -FilePath $outputFile -Append

                if ($object.value.items.type -eq 'string') {

                    $propertyNameFormatted = $object.value.items.type
                    $acceptedValues = $null
                    $description = $object.value.description
                    $propertyType = $object.value.type

                    if ($null -ne $object.value.items.pattern) {
                        $acceptedValues += ("**Pattern**: $($object.value.items.pattern.replace('|','\|'))")
                    }

                    ("| $($propertyNameFormatted) | $propertyType  | $($acceptedValues) | $($description ) |") | Out-File -FilePath $outputFile -Append
                }
                elseif ($object.value.items.type -eq 'object') {
                    foreach ($property in ($object.value.items.properties | Get-Member -type NoteProperty)) {
                        $propertyName = $property.Name
                        $acceptedValues = $null
                        $description = $null
                        $propertyType = ($object.value.items.properties.$propertyName).type


                        if ($object.Value.items.required -contains $property.Name) {
                            $propertyNameFormatted = ("**$($propertyName)**")
                        }
                        else {
                            $propertyNameFormatted = $propertyName
                        }

                        if ($null -ne $object.value.items.properties.$propertyName.enum) {
                            $acceptedValues += ('<ul>')
                            foreach ($item in $object.value.items.properties.$propertyName.enum) {
                                $acceptedValues += ("<li>$($item)</li>")
                            }
                            $acceptedValues += ('</ul>')
                        }

                        if ($null -ne $object.value.items.properties.$propertyName.pattern) {
                            $acceptedValues += ("**Pattern**: $($object.value.items.properties.$propertyName.pattern.replace('|','\|'))")
                        }

                        if ($null -ne $object.value.items.properties.$propertyName.description) {
                            $description = $($object.value.items.properties.$propertyName.description)
                        }

                        if ($propertyType -eq 'array') {
                            $subArray += @{
                                $propertyName = $object.value.items.properties.$propertyName

                            }
                            $description += ('<br><br> **See table below for array properties**')
                        }
                        ("| $($propertyNameFormatted) | $propertyType  | $($acceptedValues) | $($description ) |") | Out-File -FilePath $outputFile -Append
                    }
                }
            }
            END {
                foreach ($item in ($subArray.GetEnumerator())) {
                    process-subproperties -object $item
                }

            }
        }

    }
    PROCESS {
        try {
            Write-Information ("Starting documentation generation for folder $($ScriptFolder)")

            if (!(Test-Path $OutputFolder)) {
                Write-Information ("Output path does not exists creating the folder: $($OutputFolder)")
                New-Item -ItemType Directory -Force -Path $OutputFolder
            }

            # Get the scripts from the folder
            $scripts = Get-ChildItem $ScriptFolder -Filter 'run.ps1' -Recurse

            if ($IncludeWikiSummary) {
                if ($WikiSummaryOutputfileName) {
                    $WikiSummaryFilename = (".\$($WikiSummaryOutputfileName)")
                }
                else {
                    $WikiSummaryFilename = ('.\powershellScripts.md')
                }

                New-Item -Path $WikiSummaryFilename -Force

                if ($IncludeWikiTOC) {
                    if ($WikiTOCStyle -eq 'AzureDevOps') {
                        ("[[_TOC_]]`n") | Out-File -FilePath $WikiSummaryFilename
                        "`n" | Out-File -FilePath $WikiSummaryFilename -Append
                    }
                }
            }


            foreach ($script in $scripts) {
                if (!$exclude.Contains($script.Directory.Name)) {
                    Write-Information ("Documenting file: $($script.FullName)")

                    if ($KeepStructure) {
                        if ($script.DirectoryName -ne $ScriptFolder) {
                            $newfolder = $OutputFolder + '' + $script.Directory.Name
                            if (!(Test-Path $newfolder)) {
                                Write-Information ("Output folder for item does not exists creating the folder: $($newfolder)")
                                New-Item -Path $OutputFolder -Name $script.Directory.Name -ItemType 'directory'
                            }
                        }
                    }
                    else {
                        $newfolder = $OutputFolder
                    }

                    if (Test-Path -Path "$($script.DirectoryName)\function.json") {
                        $function = Get-Content -Path "$($script.DirectoryName)\function.json" | ConvertFrom-Json -Depth 100
                        $functionIn = $function.bindings | Where-Object direction -EQ 'in'
                    }

                    $help = Get-Help $script.FullName -ErrorAction 'SilentlyContinue' -Detailed

                    if ($IncludeWikiSummary) {
                        if ($SummaryTitleAsLink) {
                            ("### [$($script.Name)]($($SummaryLinkPattern)$($script.BaseName)/$($script.BaseName).md)`r") | Out-File -FilePath $WikiSummaryFilename -Append
                        }
                        else {
                            ("### $($script.Name) `r") | Out-File -FilePath $WikiSummaryFilename -Append
                        }
                    }
                    $script | Format-List *
                    if ($help) {
                        $outputFile = ("$($newfolder)\$($script.BaseName)$($scriptNameSuffix)")
                        Out-File -FilePath $outputFile

                        if ($IncludeWikiTOC) {
                            if ($WikiTOCStyle -eq 'AzureDevOps') {
                                ("[[_TOC_]]`n") | Out-File -FilePath $outputFile
                                "`n" | Out-File -FilePath $outputFile -Append
                            }
                        }

                        #synopsis
                        if ($help.Synopsis) {
                            ("## Synopsis`n") | Out-File -FilePath $outputFile -Append
                            ("$($help.Synopsis)") | Out-File -FilePath $outputFile -Append


                            if ($IncludeWikiSummary) {
                                ("$($help.Synopsis)`r") | Out-File -FilePath $WikiSummaryFilename -Append
                            }
                        }
                        else {
                            Write-Warning -Message ("Synopsis not defined in file $($script.fullname)")
                        }

                        #syntax
                        if ($help.Syntax) {

                            $syntaxString = ("$($functionIn.Methods.ToUpper())  \api\$($script.Directory.name)")
                            ("`r``````REST`r $($syntaxString)`r``````") | Out-File -FilePath $outputFile -Append
                        }
                        else {
                            Write-Warning -Message ("Syntax not defined in file $($script.fullname)")
                        }

                        #notes (seperated by (name): and (value);)
                        if ($help.alertSet) {
                            ("`r## Information`r") | Out-File -FilePath $outputFile -Append
                            $text = $help.alertSet.alert.Text.Split(';', $option)
                            foreach ($line in $text) {
                                $items = $line.Trim().Split(':', $option)
                                ("**$($items[0]):** $($items[1])`n") | Out-File -FilePath $outputFile -Append
                            }
                        }
                        else {
                            Write-Warning -Message ("Notes not defined in file $($script.fullname)")
                        }

                        if ($help.Component) {

                            ("## Prerequisites`r") | Out-File -FilePath $outputFile -Append

                            $tables = $help.Component.Split('--', $option)

                            foreach ($table in $tables) {
                                $text = $table.Split(';', $option)
                                $count = 0
                                $headerLine = ''
                                $tableLine = ''
                                $contentLine = ''
                                foreach ($line in $text) {
                                    $contentLine = ''
                                    $items = $line.Trim().Split(':', $option)
                                    if ($count -eq 0) {
                                        foreach ($item in $items) {
                                            $headerLine += ("| $($item) ")
                                            $tableLine += ('|-')
                                        }
                                        $headerLine += ('|')
                                        $tableLine += ('|')
                                        $headerLine | Out-File -FilePath $outputFile -Append
                                        $tableLine | Out-File -FilePath $outputFile -Append
                                    }
                                    else {
                                        foreach ($item in $items) {
                                            $contentLine += ("| $($item) ")
                                        }
                                        $contentLine += ('|')
                                        $contentLine | Out-File -FilePath $outputFile -Append
                                    }
                                    $count++
                                }
                            }
                        }
                        else {
                            Write-Warning -Message ("Component not defined in file $($script.fullname)")
                        }
                        "`r" | Out-File -FilePath $outputFile -Append

                        #description
                        if ($help.Description) {
                            "## Description`r" | Out-File -FilePath $outputFile -Append
                            $help.Description.Text | Out-File -FilePath $outputFile -Append
                            "`r" | Out-File -FilePath $outputFile -Append
                        }
                        else {
                            Write-Warning -Message "Description not defined in file $($script.fullname)"
                        }


                        # New Azure Function data here

                        if (Test-Path -Path "$($script.DirectoryName)\schema.json") {
                            $subProperties = @{}
                            ("`r`n### JSON input Schema`r`n") | Out-File -FilePath $outputFile -Append
                            ("**Bold** properties are required`r`n") | Out-File -FilePath $outputFile -Append

                            $schema = Get-Content -Path "$($script.DirectoryName)\schema.json" | ConvertFrom-Json -Depth 100

                            ("`r`n#### Main input Schema`r`n") | Out-File -FilePath $outputFile -Append
                            ("`r`n| Property | Type | Accepted values | Description |") | Out-File -FilePath $outputFile -Append
                            ('|-|-|-|-|') | Out-File -FilePath $outputFile -Append

                            foreach ($property in ($schema.properties | Get-Member -type NoteProperty)) {
                                $propertyName = $property.Name
                                $acceptedValues = $null
                                $description = $null
                                $propertyType = ($schema.properties.$propertyName).type

                                if ($schema.required -contains $property.Name) {
                                    $propertyNameFormatted = ("**$($propertyName)**")
                                }
                                else {
                                    $propertyNameFormatted = $propertyName
                                }
                                if ($null -ne $schema.properties.$propertyName.enum) {
                                    $acceptedValues += ('<ul>')
                                    foreach ($item in $schema.properties.$propertyName.enum) {
                                        $acceptedValues += ("<li>$($item)</li>")
                                    }
                                    $acceptedValues += ('</ul>')
                                }

                                if ($null -ne $schema.properties.$propertyName.pattern) {
                                    $acceptedValues += ("**Pattern**: $($schema.properties.$propertyName.pattern.replace('|','\|'))")
                                }

                                if ($null -ne $schema.properties.$propertyName.description) {
                                    $description = $($schema.properties.$propertyName.description)
                                }
                                if ($propertyType -eq 'array') {
                                    $subProperties += @{
                                        $propertyName = $schema.properties.$propertyName

                                    }
                                    $description += ('<br><br> **See table below for array properties**')
                                }



                                ("| $($propertyNameFormatted) | $propertyType  | $($acceptedValues) | $($description ) |") | Out-File -FilePath $outputFile -Append
                            }

                            Write-Verbose ("Found '$($subProperties.count)' subproperties to process")

                            foreach ($item in ($subProperties.GetEnumerator())) {
                                process-subproperties -object $item
                            }
                        }


                        #examples
                        if ($help.Examples) {
                            ("## Examples`r") | Out-File -FilePath $outputFile -Append

                            forEach ($item in $help.Examples.Example) {
                                $title = $item.title.Replace('--------------------------', '').Replace('EXAMPLE', 'Example').trim()
                                ("### $($title)`r") | Out-File -FilePath $outputFile -Append
                                if ($item.Code) {
                                    ("``````PowerShell`r`n $($item.Code)`r`n```````r") | Out-File -FilePath $outputFile -Append
                                }
                            }
                        }
                        else {
                            Write-Warning -Message "Examples not defined in file $($script.fullname)"
                        }

                        if ($help.Parameters) {
                            ("`r`n## Parameters`r") | Out-File -FilePath $outputFile -Append
                            forEach ($item in $help.Parameters.Parameter) {
                                ("### $($item.name)`r") | Out-File -FilePath $outputFile -Append
                                $item.description[0].text | Out-File -FilePath $outputFile -Append
                                ('| | |') | Out-File -FilePath $outputFile -Append
                                ('|-|-|') | Out-File -FilePath $outputFile -Append
                                ("| Type: | $($item.Type.Name) |") | Out-File -FilePath $outputFile -Append
                                foreach ($arrParameterProperty in $arrParameterProperties) {
                                    if ($item.$arrParameterProperty) {
                                        ("| $arrParameterProperty : | $($item.$arrParameterProperty)|") | Out-File -FilePath $outputFile -Append
                                    }
                                }
                            }
                            if ($IncludeWikiTOC) {
                                if ($WikiTOCStyle -eq 'Github') {

                                    $TOC = .\utilities\Generate-githubTOC.ps1 -Path $outputFile
                                    $rawContent = Get-Content $outputFile
                                    $TOC | Out-File -FilePath $outputFile
                                    #"`n" | Out-File -FilePath $outputFile -Append
                                    $rawContent | Out-File -FilePath $outputFile -Append
                                }
                            }
                        }
                        else {
                            Write-Warning -Message "Parameters not defined in file $($script.fullname)"
                        }

                    }
                    else {
                        Write-Error -Message ("Synopsis could not be found for script $($script.FullName)")
                    }
                }
            }
        }
        catch {
            Write-Error "Something went wrong while generating the output documentation: $_"
        }
    }
    END {}
}
New-MDPowerShellAzureFunctions -ScriptFolder '..\Powershell\Azure Functions\test-function' -OutputFolder '.\Powershell\Azure Functions\' -KeepStructure $true -IncludeWikiTOC $true -WikiTOCStyle 'Github' -verbose
