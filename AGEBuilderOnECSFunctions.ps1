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

    # Create content folder
    New-Item -Path "C:\arcgiscontent" -ItemType Directory -Force
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
    
    # Start the silent installation process
    Start-Process ($tempPath+'\Builder\Builder.exe') -Argument "ACCEPTEULA=yes SERVER_AUTHORIZATION=$($software.serverLicenseFile) GIS_PASSWORD=Enterprise!!12345 /qn" -NoNewWindow -Wait -PassThru

    # Ensure the local arcgis account has permissions to installation directories


}

function Invoke-ApplyArcGISFolderPermissions
{
    <#
    .SYNOPSIS
        Apply permissions to the local 'arcgis' account for required folders.
    #>

    # Define list of folders that the 'arcgis' account should receive Full Control permissions to.
    # $RequiredFoldersList = ("C:\Program Files\ArcGIS\Server", "C:\Program Files\ArcGIS\DataStore", "C:\Program Files\ArcGIS\Portal", "C:\arcgis\arcgisportal", "C:\arcgis\arcgisserver", "C:\arcgis\arcgisdatastore")
    $RequiredFoldersList = ("C:\Program Files\ArcGIS\Server", "C:\Program Files\ArcGIS\DataStore", "C:\Program Files\ArcGIS\Portal", "C:\arcgis\arcgisportal")
    # $RequiredFoldersList = ("C:\arcgiscontent")


    # Apply ACL to each folder in the list
    ForEach ($folder in $RequiredFoldersList)
    {
    Write-Output "Applying ACL to $folder"
    $ACL = Get-ACL -Path $folder
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("arcgis","FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $ACL.SetAccessRule($AccessRule)
    $ACL | Set-ACL -Path $folder
    # (Get-ACL -Path $folder).Access | Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize
    }

    }

function Invoke-EnterpriseBuilderConfiguration
{
    <#
    .SYNOPSIS
        Invokes the ArcGIS Enterprise Builder silent configuration parameters.
    #>
    Start-Process $arcgisConfigurationUtilityPath -Argument "-fn Site -ln Administrator -u portaladmin -p portaladmin1 -e portaladmin@esri.com -qi 13 -qa Esri -d C:\arcgiscontent -lf $($software.portalLicenseFile) -ut creatorUT" -NoNewWindow -Wait -PassThru

}

function Invoke-UpdateArcGISEnvironmentVariables
{
    <#
    .SYNOPSIS
        Updates the environment variables in the session to include ArcGIS installation paths.
    #>
    $env:AGSDATASTORE = [System.Environment]::GetEnvironmentVariable('AGSDATASTORE', 'machine')
    $env:AGSSERVER = [System.Environment]::GetEnvironmentVariable('AGSSERVER', 'machine')
    $env:AGSPORTAL = [System.Environment]::GetEnvironmentVariable('AGSPORTAL', 'machine')

}

Function Invoke-RequestSSLCertificate
{
    <#
    .SYNOPSIS
        Request an SSL certificate from certifactory.esri.com and store it in the temporary directory.
    #>
    $sslCertPath = ($tempPath+'\wildcard.pfx')
    $sslCertPassword = "esri1234"
    Invoke-RestMethod -Uri "https://certifactory.esri.com/api/wildcard.pfx?password=$sslCertPassword" -OutFile $sslCertPath
}

Function Invoke-UpdateWindowsIISCertBinding
{    
    <#
    .SYNOPSIS
        Update any IIS websites that contain an https binding to use an SSL certificate.
    #>
    
    #dev 
    $sslCertPath = "C:\AGEBuilderOnECS\prereqs\wildcard.pfx"
    $sslCertPasswordSecure = ConvertTo-SecureString $sslCertPassword -AsPlainText -Force
    
    Import-Module WebAdministration
    
    $newCert = Import-PfxCertificate `
      -FilePath $sslCertPath `
      -CertStoreLocation "Cert:\LocalMachine\My" `
      -password $sslCertPasswordSecure
    
      $sites = Get-ChildItem -Path IIS:\Sites
    
      foreach ($site in $sites)
      {
          foreach ($binding in $site.Bindings.Collection)
          {
              if ($binding.protocol -eq 'https')
              {
                  $search = "Cert:\LocalMachine\My\$($binding.certificateHash)"
                  $certs = Get-ChildItem -path $search -Recurse
                  $hostname = hostname
                  
                  if (($certs.count -gt 0))
                  {
                    # Write-Output "Updating $hostname, site: `"$($site.name)`", binding: `"$($binding.bindingInformation)`", current cert: `"$($certs[0].Subject)`", Expiry Date: `"$($certs[0].NotAfter)`""
                    #   Invoke-LogEntry -logTarget $node.FQDN -logStatus "info" -logFunction "Update-WindowsIISCertBinding" -logMessage "Updating $hostname, site: `"$($site.name)`", binding: `"$($binding.bindingInformation)`", current cert: `"$($certs[0].Subject)`", Expiry Date: `"$($certs[0].NotAfter)`"" -logError $_.Exception -logTrace $_.ScriptStackTrace
    
                      $binding.AddSslCertificate($newCert.Thumbprint, "my")
                  }
              }
          }
      }

} 