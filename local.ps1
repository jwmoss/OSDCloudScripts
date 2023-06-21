## Install Windows ADK and Windows PE Addon
<#
https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
* ADK
* PE Add-on for ADK
#>

New-OSDCloudTemplate

## Creates C:\ProgramData\OSDCloud\*

## Create a script locally under path below to bootstrap vault.yaml
## (Get-OSDCloudWorkspace) + "\Config\Scripts\StartNet"
<#
$vault_yaml = @"
---
win_adminpw: "xxxxx"
win_vncpw_hash: "hash"
win_readonly_vncpw_hash: "different hash" ## I will put theses in 1password if they are not there
taskcluster_access_token: "xxxxxxx"
tooltool_tok: "a token that may not be needed"
"@
if (-Not (Test-Path "C:\ProgramData")) {
    throw "Unable to find C:\ProgramData"
}
New-Item -Path "C:\ProgramData" -Name "secrets" -ItemType "Directory" -Force
New-Item -Path "C:\ProgramData\secrets" -Name "vault.yaml" -ItemType "File" -Value $vault_yaml
#>

New-OSDCloudWorkspace -WorkspacePath $WorkingDir -Verbose
$WorkingDir = "C:\OSDCloud"
$DriverPath = "C:\DriverPath\LAN-Win11-1.1.3.34"
$Startnet = @'
Start-Process /Wait PowerShell -NoLogo -Command Install-Module OSD -Force -Verbose
'@

$cloudwinpe = @{
    WorkspacePath = $WorkingDir
    WebPSScript   = "https://raw.githubusercontent.com/jwmoss/OSDCloudScripts/main/bootstrap.ps1"
    #CloudDriver = "IntelNet"
    PSModuleInstall = "PSWindowsUpdate"
    #StartNet = $Startnet
    DriverPath    = $DriverPath
}

Edit-OSDCloudWinPE @cloudwinpe

# Path to iso
# C:\OSDCloud\OSDCloud_NoPrompt.iso

<#
Links
https://akosbakos.ch/tag/osdcloud/
https://akosbakos.ch/osdcloud-1-basics/
https://akosbakos.ch/osdcloud-4-oobe-customization/
#>