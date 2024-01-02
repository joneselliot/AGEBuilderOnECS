<#
.SYNOPSIS
    Installs ArcGIS Enterprise via ArcGIS Enterprise Builder given a specified arcgisVersion.
#>

Param($ageVersionInput)
$ageVersionInput = "11.2" #debug

# Load global variables and functions
. $PSScriptRoot\globalVariables.ps1
. $PSScriptRoot\AGEBuilderOnECSFunctions.ps1

# Locate Software item that contains the appropriate ArcGIS Enterprise information
$software = Import-Csv -Path $softwareVersionsPath | Where-Object -Property arcgisVersion -eq $ageVersionInput
Write-Output $software

Write-Output "Run Invoke-EnterpriseBuilderPrep"
$PSDrive = Invoke-EnterpriseBuilderPrep

Write-Output "Run EnterpriseBuilderInstallPrerequisites"
Invoke-EnterpriseBuilderInstallPrerequisites 

Write-Output "Run EnterpriseBuilderInstall"
Invoke-EnterpriseBuilderInstall ($PSDrive)

# Invoke-EnterpriseBuilderWaitCondition

# Invoke-EnterpriseBuilderConfiguration