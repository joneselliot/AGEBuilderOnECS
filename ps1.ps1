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

Invoke-CreateWindowsIISCertBinding