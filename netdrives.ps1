<#
This Powershell script sets up network drives under a non-privileged setting

	Required to run "Set-ExecutionPolicy Unrestricted -Force" 
#>

# Continue on error
$ErrorActionPreference = 'silentlycontinue'

# netdrives maps local SMB shares
function netdrives {
	
	# SMB shares
	$SMB_User = Read-Host -Prompt "SMB Share Username" -MaskInput
	$SMB_Password = Read-Host -Prompt "SMB Share Password" -MaskInput
	$WscriptNetwork = New-Object -ComObject "Wscript.Network"
	$WscriptNetwork.MapNetworkDrive("W:", "\\SERVER\user", $True, $SMB_User, $SMB_Password)
	$WscriptNetwork.MapNetworkDrive("S:", "\\SERVER\share1", $True)
	$WscriptNetwork.MapNetworkDrive("X:", "\\SERVER\share2", $True)

	# New-SmbMapping -LocalPath 'W:' -RemotePath '\\SERVER\user' -UserName $SMB_User -Password $SMB_Password -Persistent $True -SaveCredentials -GlobalMapping
	# New-SmbMapping -LocalPath 'S:' -RemotePath '\\SERVER\share1' -Persistent $True -GlobalMapping
	# New-SmbMapping -LocalPath 'X:' -RemotePath '\\SERVER\share2' -Persistent $True -GlobalMapping

 }

netdrives
