## Synopsis

Checks if all required abobe recommendations are set.
```PowerShell .\Get-MicrosoftSecurityRecommendations.ps1 [<CommonParameters>]```
## Information
**Version:**         1.0.0

**Author:**          Léon Boers

**Creation Date:**   06-01-2023

**Purpose/Change:**  List

**1.0.0:**   Initial release with several flash/javascript recommendations by Microsoft Security Center.


## Description
Checks if all required abobe recommendations are set. If verifies if the regiostry settings are in place and set to the required value.
if one registry setting is not properly set, the script will abort and have Intune call the remediation script

This can be run locally as well.

## Examples
### Example 1
```PowerShell
 .\Get-MicrosoftSecurityRecommendations
```
