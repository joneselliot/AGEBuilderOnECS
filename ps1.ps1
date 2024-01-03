$tempPath = "C:\temp\AGEBuilderOnECS\"
$softwareVersionsPath = "$PSScriptRoot\BuilderVersions.csv"

#Dev 
$localinstallersPath = "C:\AGEBuilderOnECS\prereqs"
$dotnetHostingBundleInstaller = "dotnet-hosting-6.0.25-win.exe"
$webDeployInstaller = "WebDeploy_amd64_en-US.msi"


#   # Copy ArcGIS Enterprise Builder setup files and mount drive
# #   $CopyInfo = Copy-Item -Path $software.arcgisInstallationPath -Destination $tempPath -Force -PassThru
# #   Mount-DiskImage -ImagePath ($tempPath+'\'+$CopyInfo.Name)
# #   $DiskImage = Get-DiskImage -ImagePath ($tempPath+'\'+$CopyInfo.Name)
#    Mount-DiskImage -ImagePath ($tempPath+'\'+"ArcGIS_Enterprise_Builder_Windows_112_188275.iso")
#    $DiskImage = Get-DiskImage -ImagePath ($tempPath+'\'+"ArcGIS_Enterprise_Builder_Windows_112_188275.iso")
#   $PSDrive = New-PSDrive -Name ISOFile -PSProvider FileSystem -Root (Get-Volume -DiskImage $DiskImage).UniqueId

  # Mount the ISO file
$isoPath = "C:\AGEBuilderOnECS\prereqs\ArcGIS_Enterprise_Builder_Windows_112_188275.iso"
$mountPath = 'D:'
$mountInfo = Mount-DiskImage -ImagePath $isoPath -StorageType ISO -PassThru
$driveLetter = ($mountInfo | Get-Volume).DriveLetter

# Copy files from the mounted virtual disk to the destination folder
$sourcePath = $isoPath
$destinationPath = $tempPath
Copy-Item -Path ($driveLetter+':\*') -Destination $destinationPath -Recurse
# Unmount the virtual disk
Dismount-DiskImage -ImagePath $isoPath
