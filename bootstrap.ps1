#================================================
#   [PreOS] Update Module
#================================================
# if ((Get-MyComputerModel) -match 'Virtual') {
#     Write-Host -ForegroundColor Green "Setting Display Resolution to 1600x"
#     Set-DisRes 1600
# }

Set-ExecutionPolicy Unrestricted -Force

# # Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
# Install-Module OSD -Force -SkipPublisherCheck

# # Write-Host -ForegroundColor Green "Importing OSD PowerShell Module"
# Import-Module OSD -Force   

# Start-Sleep -Seconds 20

Invoke-WebRequest "https://downloadmirror.intel.com/739771/LAN-Win11-1.1.3.34.zip" -OutFile "C:\LAN-Win11-1.1.3.34.zip"
New-item -Path "C:\" -Name "NUCDrivers" -ItemType Directory -Force
Expand-Archive -Path "C:\LAN-Win11-1.1.3.34.zip" -DestinationPath "C:\NUCDrivers"

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
$Params = @{
    OSVersion  = "Windows 11"
    OSBuild    = "22H2"
    OSEdition  = "Pro"
    OSLanguage = "en-us"
    OSLicense  = "Retail"
    ZTI        = $true
    Firmware   = $false
}

Start-OSDCloud @Params

#Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
# Set-ExecutionPolicy Unrestricted -Force
# & {Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/jwmoss/ronin_puppet/win11/provisioners/windows/OSDCloud/bootstrap.ps1')}

Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
powershell.exe -Command Set-ExecutionPolicy Unrestricted -Force
powershell.exe -Command "& {IEX (IRM 'https://raw.githubusercontent.com/jwmoss/ronin_puppet/win11/provisioners/windows/OSDCloud/bootstrap.ps1')}"
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

Get-ChildItem -Path "C:\NUCDrivers" -Recurse -Filter *.inf | ForEach-Object {
    pnputil.exe /add-driver "$($_.FullName)" /install
}

#& "X:\OSDCloud\Config\Scripts\Shutdown\local_keyvault.ps1"

# if ($env:UserName -eq 'defaultuser0') {
#     if (!(Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore)) {
#         try {
#             Install-Module PSWindowsUpdate -Force -SkipPublisherCheck
#             Import-Module PSWindowsUpdate -Force
#         }
#         catch {
#             Write-Warning 'Unable to install PSWindowsUpdate Driver Updates'
#         }
#     }
#     if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
#         Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
#     }
# }

## Setup driver path
#Write-Host -ForegroundColor Green "Restarting in 20 seconds!"
#Start-Sleep -Seconds 20
#wpeutil reboot

<#
$PathPanther = 'C:\Windows\Panther'
if (-NOT (Test-Path $PathPanther)) {
    New-Item -Path $PathPanther -ItemType Directory -Force | Out-Null
}

$UnattendDrivers = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="offlineServicing">
        <component name="Microsoft-Windows-PnpCustomizationsNonWinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DriverPaths>
                <PathAndCredentials wcm:keyValue="1" wcm:action="add">
                    <Path>C:\Drivers</Path>
                </PathAndCredentials>
            </DriverPaths>
        </component>
    </settings>
</unattend>
'@

$UnattendPath = Join-Path $PathPanther 'Unattend.xml'
Write-Verbose -Verbose "Setting Driver $UnattendPath"
$UnattendDrivers | Out-File -FilePath $UnattendPath -Encoding utf8

#>