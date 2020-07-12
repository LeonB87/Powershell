$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "false should be false" {
    It "test localhost" {
        .\Test-ipBlacklist -IP 127.0.0.1 | Should -Be $false
    }
}
