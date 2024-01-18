<#
.SYNOPSIS
    Installs ArcGIS Enterprise via ArcGIS Enterprise Builder given a specified arcgisVersionInput.
#>

Param(
    [Parameter(Mandatory=$true)]
    [String]$ageVersionInput
    )

# Load global variables and functions
. $PSScriptRoot\globalVariables.ps1
. $PSScriptRoot\AGEBuilderOnECSFunctions.ps1

# Locate Software item that contains the appropriate ArcGIS Enterprise information
$software = Import-Csv -Path $softwareVersionsPath | Where-Object -Property arcgisVersion -eq $ageVersionInput
# Write-Output $software

Write-Output "Run Invoke-EnterpriseBuilderPrep"
Invoke-EnterpriseBuilderPrep 

Write-Output "Run EnterpriseBuilderInstallPrerequisites"
Invoke-EnterpriseBuilderInstallPrerequisites 

Write-Output "Invoke-CreateWindowsIISCertBinding"
Invoke-CreateWindowsIISCertBinding

Write-Output "Run Invoke-RequestSSLCertificate"
Invoke-RequestSSLCertificate

Write-Output "Run Invoke-UpdateWindowsIISCertBinding"
Invoke-UpdateWindowsIISCertBinding

Write-Output "Run EnterpriseBuilderInstall"
Invoke-EnterpriseBuilderInstall

Write-Output "Run Invoke-ApplyArcGISFolderPermissions"
Invoke-ApplyArcGISFolderPermissions

Write-Output "Run Invoke-UpdateArcGISEnvironmentVariables"
Invoke-UpdateArcGISEnvironmentVariables

Write-Output "Run EnterpriseBuilderConfiguration"
Invoke-EnterpriseBuilderConfiguration