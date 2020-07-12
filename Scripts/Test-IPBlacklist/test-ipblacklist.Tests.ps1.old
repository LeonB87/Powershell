$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\$sut"

Describe "Running blacklist check" {
    $result =  .\test-ipBlacklist.ps1 -IP "127.0.0.1"

    It "should return False" {
        $result | should -Be $false
    }

}
