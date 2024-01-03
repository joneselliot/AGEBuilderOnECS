function Invoke-EnterpriseBuilderPrep
{
    <#
    .SYNOPSIS 
        Copies the ArcGIS Enterprise Builder setup file to the executing machine and mounts the image.
    .DESCRIPTION
        Using the BuilderManifest.csv file and arcgisVersion input string, copies the .iso file containing the ArcGIS Enterprise Builder setup files to the machine that is executing the function, then mounts the .iso file.
    #>

    # Ensure temp folder exists, else, create
    If(-not(Test-Path $tempPath))
    {New-Item $tempPath -ItemType Directory -Force}

    # Copy ArcGIS Enterprise Builder setup files and mount drive
    Copy-Item -Path $software.arcgisInstallationPath -Destination $tempPath -Force -PassThru
    $arcgisInstallationName = Split-Path $software.arcgisInstallationPath -leaf
    $mountResult = Mount-DiskImage -ImagePath ($tempPath+'\'+$arcgisInstallationName) -StorageType ISO -PassThru
    $driveLetter = ($mountResult | Get-Volume).DriveLetter

    $destinationPath = ($tempPath+'\'+'Builder')
    # Create destination folder within $tempPath
    New-Item -Path $destinationPath -ItemType Directory -Force
    # Copy files from the mounted virtual disk to the destination folder
    Write-Host $destinationPath
    Copy-Item -Path ($driveLetter+':\*') -Destination $destinationPath -Recurse -Force
    # Unmount the virtual disk
    Dismount-DiskImage -ImagePath ($tempPath+'\'+$arcgisInstallationName)

    # Copy Prerequisite Setup Files to Temp folder
    Copy-Item -Path ($localinstallersPath+'\'+$dotnetHostingBundleInstaller) -Destination ($tempPath+'\'+$dotnetHostingBundleInstaller)
    Copy-Item -Path ($localinstallersPath+'\'+$webDeployInstaller) -Destination ($tempPath+'\'+$webDeployInstaller)
}

function Invoke-EnterpriseBuilderInstallPrerequisites
{
    <#
    .SYNOPSIS 
        Installs IIS prerequisites for ArcGIS Enterprise to avoid UI prompt in Builder silent install.
    #>
    # Install required IIS Features
    Install-WindowsFeature -Name Web-Server,Web-Windows-Auth,Web-App-Dev,Web-Net-Ext45,Web-Asp-Net45,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-WebSockets,Web-Mgmt-Tools,Web-Mgmt-Console,Web-Scripting-Tools,Web-Mgmt-Service
    # Install .NET Hosting Bundle
    Start-Process -Wait ($tempPath+'\'+$dotnetHostingBundleInstaller) -Argument "/install /quiet /norestart"
    # Install Microsoft Web Deploy
    Start-Process -Wait MsiExec.exe -Argument "/i $tempPath\$webDeployInstaller ADDLOCAL=ALL /qn /norestart LicenseAccepted='0'" 
}
function Invoke-EnterpriseBuilderInstall
{
    <#
    .SYNOPSIS
        Invokes the ArcGIS Enterprise Builder silent install parameters.
    #>
    
    Start-Process ($tempPath+'\Builder\Builder.exe') -Argument "ACCEPTEULA=yes SERVER_AUTHORIZATION=$($software.serverLicenseFile) GIS_PASSWORD=Enterprise!!12345 /qn" -NoNewWindow -Wait -PassThru
}

function Invoke-EnterpriseBuilderWaitCondition
{
    <#
    .SYNOPSIS
        Waits for ArcGIS Enterprise to be installed before attempting configuration.
    #>
   
}

function Invoke-EnterpriseBuilderConfiguration
{
    <#
    .SYNOPSIS
        Invokes the ArcGIS Enterprise Builder silent configuration parameters.
    #>
    Start-Process $arcgisConfigurationUtilityPath -Argument "-fn Site -ln Administrator -u portaladmin -p portaladmin1 -e portaladmin@esri.com -qi 13 -qa Esri -d C:\arcgis -lf $($software.portalLicenseFile) -ut creatorUT" -NoNewWindow -Wait -PassThru

}