<#
This Powershell script sets up a fresh Windows 10 install for most commonly used programs and services:
    Wi-Fi
    Windows 10 Debloat
    Chocolatey
    Network Shares
    WSL 2
#>

# WiFiSetup connects you to the outside world with your previously exported wifi profiles
function WiFiSetup {

    # Where am I?
    $PSScriptRoot

    # Add WiFi Networks
    Netsh WLAN add profile filename=$PSScriptRoot\Wifi5G.xml
    Netsh WLAN add profile filename=$PSScriptRoot\Wifi2G.xml

}

WiFiSetup

# Housekeeping
Install-PackageProvider -Name NuGet -Force

# Windows10 GUI debloater script from GitHub
Invoke-WebRequest -useb https://git.io/debloat|Invoke-Expression

# NetTweaks modifies network neighborhood and installs Windows Subsystem for Linux
function NetTweaks {

    # NetBIOS modifications
    # https://www.truenas.com/community/resources/how-to-kill-off-smb1-netbios-wins-and-still-have-windows-network-neighbourhood-better-than-ever.106/
    New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE
    Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters | New-Item -Name 'SMB1' -Force
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Name SMB1 -Value "0" -Force
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\fdPHost -Name Start -Value "2" -Force
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\FDResPub -Name Start -Value "2" -Force

    WscriptNetwork = New-Object -ComObject "Wscript.Network"
    WscriptNetwork.MapNetworkDrive("W:", "\\SERVER\Share", $True, 'User', 'Password')

    # Install WSL
    wsl --install -d Ubuntu-20.04
    wsl --shutdown

}

NetTweaks

# PackageInstall installs most commonly used programs via chocolatey package manager and updates Windows
function PackageInstall {

    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    choco install pdfxchangeeditor -y
    choco install github-desktop -y
    choco install librewolf -y
    choco install putty -y
    choco install rufus.install -y
    choco install foobar2000 -y
    choco install freeencoderpack -y
    choco install libreoffice-fresh -y
    choco install vlc -y
    choco install openvpn-connect -y
    choco install wireguard -y
    choco install msiafterburner -y
    choco install winrar -y
    choco install gimp -y
    choco install vscode.install -y
    choco install winscp.install -y
    choco install spotify -y
    choco install nvidia-display-driver --params "'/DCH'" -y

    # Update Windows
    Install-Module -Name PSWindowsUpdate -Force
    Import-Module -Name PSWindowsUpdate
    Get-WindowsUpdate
    Install-WindowsUpdate -AcceptAll 

}

PackageInstall

# Housekeeping
# Reset PS Execution Policy
Set-ExecutionPolicy Restricted