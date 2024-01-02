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
    $CopyInfo = Copy-Item -Path $software.arcgisInstallationPath -Destination $tempPath -Force -PassThru
    Mount-DiskImage -ImagePath ($tempPath+'\'+$CopyInfo.Name)
    $DiskImage = Get-DiskImage -ImagePath ($tempPath+'\'+$CopyInfo.Name)
    $PSDrive = New-PSDrive -Name ISOFile -PSProvider FileSystem -Root (Get-Volume -DiskImage $DiskImage).UniqueId

    # Copy Prerequisite Setup Files to Temp folder
    Copy-Item -Path ($localinstallersPath+'\'+$dotnetHostingBundleInstaller) -Destination ($tempPath+'\'+$dotnetHostingBundleInstaller)
    Copy-Item -Path ($localinstallersPath+'\'+$webDeployInstaller) -Destination ($tempPath+'\'+$webDeployInstaller)
    Return $PSDrive
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
    Param($PSDrive)
    Push-Location "$($PSDrive.Name):"
    Start-Process "Builder.exe" -Argument "ACCEPTEULA=yes SERVER_AUTHORIZATION=$($software.serverLicenseFile) GIS_PASSWORD=Enterprise!!12345"
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
}