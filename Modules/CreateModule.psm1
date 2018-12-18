$manifest = @{
    Path          = '.\Computer Information\Computer Information.psd1'
    RootModule    = 'Computer Information.psm1'
    Author        = 'Leon Boers'
    ModuleVersion = "1.0"
}
New-ModuleManifest @manifest