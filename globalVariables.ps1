# Contains global variables required for the script to run
$softwareVersionsPath = "$PSScriptRoot\BuilderVersions.csv"
$localinstallersPath = "\\cpde-ess-data\ess-data\static_data\software\IIS_Modules"
$dotnetHostingBundleInstaller = "dotnet-hosting-6.0.15-win.exe"
$webDeployInstaller = "WebDeploy_amd64_en-US.msi"
$tempPath = "C:\temp\AGEBuilderOnECS"
$arcgisConfigurationUtilityPath = "C:\Program Files\ArcGIS\Server\tools\configurebasedeployment\configurebasedeployment.bat"

#Dev 
# $localinstallersPath = "C:\AGEBuilderOnECS\prereqs"
# $dotnetHostingBundleInstaller = "dotnet-hosting-6.0.25-win.exe"
# $webDeployInstaller = "WebDeploy_amd64_en-US.msi"