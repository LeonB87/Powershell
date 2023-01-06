<#
.SYNOPSIS
Checks if all required abobe recommendations are set.

.DESCRIPTION
Checks if all required abobe recommendations are set. If verifies if the regiostry settings are in place and set to the required value.
if one registry setting is not properly set, the script will abort and have Intune call the remediation script

This can be run locally as well.

.EXAMPLE
.\Get-MicrosoftSecurityRecommendations

.NOTES
Version:        1.0.0;
Author:         Léon Boers;
Creation Date:  06-01-2023;
Purpose/Change: List;
1.0.0:  Initial release with several flash/javascript recommendations by Microsoft Security Center.
#>

$securityRecommendations = @(
    @{name = 'Disable JavaScript on Adobe DC'               ; key = 'bDisableJavaScript'; requiredValue = '1';  type = 'DWord'; path = 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown'}
    @{name = 'Disable JavaScript on Adobe Acrobat Pro XI'   ; key = 'bDisableJavaScript'; requiredValue = '1';  type = 'DWord'; path = 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\11.0\FeatureLockDown'}
    @{name = 'Disable Flash on Adobe Acrobat Pro XI'        ; key = 'bEnableFlash'      ; requiredValue = '0';  type = 'DWord'; path = 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\11.0\FeatureLockDown'}
    @{name = 'Disable JavaScript on Adobe Reader DC'        ; key = 'bDisableJavaScript'; requiredValue = '1';  type = 'DWord'; path = 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'}
    @{name = 'Disable Flash on Adobe Reader DC'             ; key = 'bEnableFlash'      ; requiredValue = '0';  type = 'DWord'; path = 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'}
)

foreach ($recommendation in $securityRecommendations) {
    $currentValue = Get-ItemProperty -Path $recommendation.path -Name $recommendation.key -ErrorAction SilentlyContinue

    If (!$currentValue) {
        "'$($recommendation.name)' is not yet implemented."
        exit 1
    }
    Else {
        if ($currentValue -ne $recommendation.requiredValue) {
            Write-Output ("'$($recommendation.name)' is remediated.")
        }
        else {
            Write-Output ("'$($recommendation.name)' is not remediated.")
        }
    }

}