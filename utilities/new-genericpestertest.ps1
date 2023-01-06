param (
    [Parameter(Mandatory = $false)]
    [string] $folder = "\"
)

BeforeDiscovery {
    function Get-PSRuleAnalyzerArray($a) {
        $array = @()
        $a | ForEach-Object { $array += @{
                rulename = $_.RuleName
            } }
        return $array
    }

    $powershellScripts = Get-ChildItem $folder -Recurse -Filter "*.ps1"

    $RawPSRuleDefinitions = Get-ScriptAnalyzerRule
    $PSRuleDefinitions = Get-PSRuleAnalyzerArray $RawPSRuleDefinitions
    $files = @()

    foreach ($powershellScript in $powershellScripts) {
        $help = Get-Help $powershellScript -Detailed

        $parameters = @()
        foreach ($param in $help.parameters.parameter) {
            $parameters += @{
                name        = $param.Name
                description = $param.description.Text
            }
        }

        $examples = @()
        foreach ($example in $help.examples.example) {
            $examples += @{
                title = $example.title
                code  = $example.code
            }
        }


        $helpDefinition = @{
            help       = $help
            parameters = $parameters
            examples   = $examples
        }

        $files += @{
            name           = $powershellScript.Name
            fullName       = $powershellScript.FullName
            helpDefinition = $helpDefinition
            analyzerTests  = $PSRuleDefinitions
        }
    }
}

Describe "<name>" -ForEach $files {
    BeforeEach {
        $scriptanalyzerResults = Invoke-ScriptAnalyzer -Path $fullName
    }
    Context "Help" {
        It "should have synopsis defined" {
            $helpDefinition.help.synopsis  | Should -Not -BeNullOrEmpty
        }

        It "should have synopsis with minimal length of 40" {
            $helpDefinition.help.synopsis.Length  | Should -BeGreaterOrEqual 40
        }

        It "Should have a description" {
            $helpDefinition.help.description | Should -Not -BeNullOrEmpty
        }

        It "Should have a description with minimal length of 120" {
            $helpDefinition.help.description[0].Text.Length | Should -BeGreaterOrEqual 120
        }

        It "Should have an example" {
            $helpDefinition.help.examples.example.count | Should -BeGreaterOrEqual 1
        }

        It "'<title>' should be defined" -ForEach $helpDefinition.examples {
            $code | Should -Not -BeNullOrEmpty
        }

        It "Synopsis Parameter '<name>' should be described" -ForEach $helpDefinition.parameters {
            $description | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name "PSScriptAnalyzer" {
        It " - '<RuleName>' should pass" -ForEach $analyzerTests {
            $scriptanalyzerResults.RuleName -contains $rulename | Should -Be $false
        }
    }
}