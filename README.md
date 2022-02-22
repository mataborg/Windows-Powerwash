# New Windows 10 Install Auto-Setup
[![made-with-powershell](https://img.shields.io/badge/PowerShell-1f425f?logo=Powershell)](https://microsoft.com/PowerShell)
![GitHub](https://img.shields.io/github/license/mataborg/windows-powerwash)
[![PSScriptAnalyzer](https://github.com/mataborg/WindowsAutoSetup/actions/workflows/powershell.yml/badge.svg?branch=main)](https://github.com/mataborg/WindowsAutoSetup/actions/workflows/powershell.yml)

This repo contains a powershell script designed to automatically connect, debloat (or "Powerwash!" and setup your most commonly used programs on Windows 10.

## WARNING
* This Script requires "Bypass" execution policy in Powershell and automatically downloads and runs the Windows 10 debloater script. Please review the code before running it on your system!
  

## Usage:
Initial setup is easiest before reimaging the target computer.
Download the Repository to a local folder. Clone via `git`, or download the repo .zip locally.
The Wireless XML profiles provided are examples for formatting. To obtain your desired WiFi profiles, you can modify the examples or perform the following:

* In an administrative Powershell, run:
```
Install-Module -Name wifiprofilemanagement
```
```
(Get-WiFiProfile -ProfileName WiFi2G).XML | Out-File $RepoDirectory\WiFi2G.xml -Encoding utf8
(Get-WiFiProfile -ProfileName WiFi5G).XML | Out-File $RepoDirectory\WiFi5G.xml -Encoding utf8
```

Then edit the script to include/exclude functionality required or not, i.e. network shares or chocolatey packages.
To run the script on a fresh Windows 10 install, the privileges need to be elevated to run scripts in powershell. 
* In an administrative Powershell, run:
```
Set-ExecutionPolicy Bypass -Force
$RepoDirectory\powerwashed.ps1
```

And enjoy your newly setup computer!
