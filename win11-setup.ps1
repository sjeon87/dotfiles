################################################################################
# Pre-requisites                                                               #
################################################################################
# Run `Set-ExecutionPolicy Unrestricted` as Administrator

$samsung = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer -match "samsung"

function UpdateRegistryInt {
  param (
    [Parameter(Mandatory=$true)]
    [string]$path
    [Parameter(Mandatory=$true)]
    [string]$name
    [Parameter(Mandatory=$true)]
    [string]$prompt
  )

  $updated = $false
  if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
    $updated = $true
  }

  $inputValue = Read-Host $prompt
  $newValue = $inputValue -as [int]
  if ($newValue -eq $null) {
    return $updated
  }
  $currentValue = Get-ItemPropertyValue -Path $path -Name $name -ErrorAction SilentlyContinue
  if ($currentValue - eq $null -or $currentValue -ne $newValue) {
    Set-ItemProperty -Path $path -Name $name -Value $newValue
    $updated = $true
  }
  return $updated
}

function InstallWingetPkg {
  param (
    [Parameter(Mandatory=$true)]
    [string]$appId,
    [Parameter(Mandatory=$false)]
    [string]$appName,
    [Parameter(Mandatory=$false)]
    [string]$source = "winget"
  )
  if (-not $appName) {
    $appName = $appId
  }

  $null = winget list --id $appId --exact 2>$null
  if ($LASTEXITCODE -eq 0) {
    Write-Host "$appName is already installed."
  } else {
    Write-Host "Installing $appName..."
    winget install $appId --source $source --silent --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) {
      Write-Host "$appName is successfully installed."
    } else {
      Write-Host "Encountered an error during $appName installation. Error code: $LASTEXITCODE."
    }
  }
}

$shouldRestartExplorer = $false
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name "AppsUseLightTheme" -prompt "Use dark mode to apps (0: light mode, 1: dark mode)?"
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name "SystemUsesLightTheme" -prompt "Use dark mode to system (0: light mode, 1: dark mode)?"
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -prompt "Hide Home folder on desktop (0: show, 1: hide)?"
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -prompt "Hide Computer on desktop (0: show, 1: hide)?"
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -name "{645FF040-5081-101B-9F08-00AA002F954E}" -prompt "Hide Trash bin on desktop (0: show, 1: hide)?"
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -prompt "Hide Network on desktop (0: show, 1: hide)?"
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -prompt "Hide Control panel on desktop (0: show, 1: hide)?"
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name "HideFileExt" -prompt "Hide file extension (0: show, 1: hide)?"
$shouldRestartExplorer = $shouldRestartExplorer -or UpdateRegistryInt -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name "EnableTaskGroups" -prompt "Enable grouping of snapped windows? (0: disable, 1: enable)?"
if ($shouldRestartExplorer -eq $true) {
  Stop-Process -Name explorer -Force
}

################################################################################
# Install softwares                                                            #
################################################################################
InstallWingetPkg("Git.Git")
InstallWingetPkg("Microsoft.PowerShell")
InstallWingetPkg("Microsoft.PowerToys")
InstallWingetPkg("voidtools.Everything")
InstallWingetPkg("Notepad++.Notepad++")
InstallWingetPkg("Neovim.Neovim")
InstallWingetPkg("Bandisoft.Bandizip")
InstallWingetPkg("Bitwarden.Bitwarden")
InstallWingetPkg("Microsoft.VisualStudioCode")
InstallWingetPkg("Obsidian.Obsidian")
InstallWingetPkg("OpenJS.NodeJS")
InstallWingetPkg("GoLang.Go")
InstallWingetPkg("Python.Python.3.14")
InstallWingetPkg("NSSM.NSSM")
InstallWingetPkg("JohnMacFarlane.Pandoc")
if ($samsung) {
  InstallWingetPkg -appName "Samsung Update" -appId 9NQ3HDB99VBF -source msstore
  InstallWingetPkg -appName "Samsung Settings 1.5" -appId 9P2TBWSHK6HJ -source msstore
}

Write-Host "`nPress any key to close:"
$null = [System.Console]::ReadKey($true)

