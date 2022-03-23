<#
This Powershell script sets up a fresh Windows 10 install for most commonly used programs and services:
	Wi-Fi
	Chocolatey
	Network Shares
	WSL 2
	Registry Tweaks

	Required to run "Set-ExecutionPolicy Unrestricted -Force" 
#>

# Continue on error
$ErrorActionPreference = 'silentlycontinue'

# This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {

    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit

}

# WiFiSetup connects you to the outside world with your previously exported wifi profiles
function WiFiSetup {

    # Add WiFi Networks
    Netsh WLAN add profile filename=$PSScriptRoot\Wifi5G.xml
    Set-NetConnectionProfile -Name "Networkname" -NetworkCategory Private
    Start-Sleep -Seconds 2

}

WiFiSetup

function useradd {

	# Set computer name
	$pcname = Read-Host -Prompt "Please enter the computer name you want to use"
	$computername.Rename($pcname)

	# $user_name = Read-Host -Prompt "Please enter the user profile you want to add"
	# $user_password = Read-Host -Prompt "Please enter the user password" -MaskInput

	# New-LocalUser -Name $user_name $user_password -AccountNeverExpires -PasswordNeverExpires

}

useradd

# Housekeeping
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force

#Local discovery
Get-NetFirewallRule -DisplayGroup 'Network Discovery'|Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true -PassThru|Select-Object Name,DisplayName,Enabled,Profile|Format-Table -a
Set-NetConnectionProfile -NetworkCategory Private -PassThru

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
	New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLinkedConnections -Value "1" -Force

	# Remove recycle bin from desktop
	# Get-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace | New-Item -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Force
	# Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value "Recycle Bin" -Force

	# Enable RDP 
	Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value "0"
	Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

	# Disable hibernate and page file
	powercfg /hibernate off
	Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power -Name HibernateEnabled -Value "0" -Force
	Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management -Name ClearPageFileAtShutdown -Value "1" -Force

	# iSCSI service
	Set-Service -Name MSiSCSI -StartupType Automatic
	Start-Service -Name MSiSCSI

}

NetTweaks

# PackageInstall installs most commonly used programs via chocolatey package manager and updates Windows
function PackageInstall {

    # Install WSL
	wsl --install -d Ubuntu-20.04
	Start-Sleep -Seconds 30

    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    choco install librewolf -y
    #Choose your own adventure and add the packages you need most!

    # Update Windows
    Import-Module -Name PSWindowsUpdate
    Get-WindowsUpdate
    Install-WindowsUpdate -AcceptAll 

}

PackageInstall

# Housekeeping
# Reset PS Execution Policy
Set-ExecutionPolicy Restricted

Write-Host "Restarting computer in 3 seconds..."
Start-Sleep 1
Write-Host "                                               3"
Start-Sleep 1
Write-Host "                                               2"
Start-Sleep 1
Write-Host "                                               1"
Start-Sleep 1
Restart-Computer