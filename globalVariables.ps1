# Contains global variables required for the script to run

# The .csv that contains a matrix of software information to use for sourcing installation and license files
$softwareVersionsPath = "$PSScriptRoot\BuilderVersions.csv"
# The root directory that contains both IIS prerequisite setup files
$localinstallersPath = "\\cpde-ess-data\ess-data\static_data\software\IIS_Modules"
$dotnetHostingBundleInstaller = "dotnet-hosting-6.0.15-win.exe"
$webDeployInstaller = "WebDeploy_amd64_en-US.msi"

# The temporary directory to which all setup files are downloaded on the local machine
$tempPath = "C:\temp\AGEBuilderOnECS"
$arcgisConfigurationUtilityPath = "C:\Program Files\ArcGIS\Server\tools\configurebasedeployment\configurebasedeployment.bat"
$sslCertPath = ($tempPath+'\wildcard.pfx')
$sslCertPassword = "esri1234"

#Dev 
# $localinstallersPath = "C:\AGEBuilderOnECS\prereqs"
# $dotnetHostingBundleInstaller = "dotnet-hosting-6.0.25-win.exe"
# $webDeployInstaller = "WebDeploy_amd64_en-US.msi"