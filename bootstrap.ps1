#================================================
#   [PreOS] Update Module
#================================================
# if ((Get-MyComputerModel) -match 'Virtual') {
#     Write-Host -ForegroundColor Green "Setting Display Resolution to 1600x"
#     Set-DisRes 1600
# }

Set-ExecutionPolicy Unrestricted -Force

# Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force

# Write-Host -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force   

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "22H2"
    OSEdition = "Pro"
    OSLanguage = "en-us"
    OSLicense = "Retail"
    ZTI = $true
    Firmware = $false
}

# Try {
Start-OSDCloud @Params
# }
# Catch {
#     $_
#     Start-Sleep -Seconds 30
# }

#Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
# Set-ExecutionPolicy Unrestricted -Force
# & {Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/jwmoss/ronin_puppet/win11/provisioners/windows/OSDCloud/bootstrap.ps1')}

Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
powershell.exe -Command Set-ExecutionPolicy RemoteSigned -Force
powershell.exe -Command "& {IEX (IRM 'https://raw.githubusercontent.com/jwmoss/ronin_puppet/win11/provisioners/windows/OSDCloud/bootstrap.ps1')}"
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

& "X:\OSDCloud\Config\Scripts\Startup\local_keyvault.ps1"

Write-Host -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot