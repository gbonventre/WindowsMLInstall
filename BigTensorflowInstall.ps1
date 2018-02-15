# https://www.tensorflow.org/install/install_windows
# http://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/
# https://developer.nvidia.com/cuda-90-download-archive?target_os=Windows&target_arch=x86_64&target_version=Server2016&target_type=exelocal
# https://developer.nvidia.com/cudnn
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-6
# https://codingbee.net/tutorials/powershell/powershell-make-a-permanent-change-to-the-path-environment-variable
# PATH LINK USEFUL: https://kevinmarquette.github.io/2016-10-21-powershell-installing-msi-files/
# https://social.technet.microsoft.com/Forums/ie/en-US/6badd078-f4b4-4506-aa38-121e7c6740cd/automatic-installation-via-powershell?forum=winserverpowershell
# http://developer.download.nvidia.com/compute/cuda/9.0/Prod/docs/sidebar/CUDA_Installation_Guide_Windows.pdf

#Install Nuget Package provider
Install-PackageProvider -Name NuGet -Force

# Install Powershell Get to facilitate installing packages from PowerShellGallery.com
Install-Module -Name PowerShellGet -Force 

# Facilitates using the Windows package installer Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#choco install chocolatey-core.extension

#Installs the Firefox Browser
choco install firefox -y

#chocolatey may need a restart of the shell

#Installs the Google Chrome Browser
choco install googlechrome -y



#Install Git
choco install git -y

#Install Git SourceTree
#choco install sourcetree -y

#Install Adobe Reader
choco install adobereader -y

#Install 7zip
choco install 7zip.install -y

# Install Python 3.6
#choco install python3 -y

#Install Visual Studio 2017 Community Edition With Add ins
choco install visualstudio2017community -y
choco install vcredist2017 -y
choco install microsoft-build-tools -y

#Install PowerShell Unit Testing Framework
choco install pester -y

#Install the lightweight IDE with relevant add ins
choco install visualstudiocode -y
choco install vscode-powershell -y
choco install vscode-docker -y
choco install vscode-csharp -y
choco install vscode-azurerm-tools -y
choco install vscode-gitlens -y

# Install SQL Server Managerment Studio
choco install sql-server-management-studio -y

#Install Azure storage Explorer
choco install microsoftazurestorageexplorer -y

# Installs the Azure commandlets
Install-Module -Name AzureRM -AllowClobber

#Install Azure CLI
choco install azure-cli -y

#Install AzCopy
choco install azcopy -y

# Install the AWS PowerShell Commandlets
Install-Module -Name AWSPowerShell 

#Install testing framework for POwerShell
choco install pester -y

# Install Git visualization tool
choco install sourcetree -y

# Install Postman API utility
choco install postman -y

#Install The Tailblazer log utility
choco install tailblazer -y

# Install Docker
choco install docker -y



# Make the temp that holds the large install files
$tempDirectory = "C:\temp_provision"
md -Force $tempDirectory | Out-Null

#Download Nvidia drivers for NC, NCv2, and ND Windows instances on Azure - This doesn't get NVIDIA Tesla drivers for NV series instances
$gpuDriverUrl = "http://us.download.nvidia.com/Windows/Quadro_Certified/385.54/385.54-tesla-desktop-winserver2016-international.exe"
$gpuDriverLoc = $tempDirectory + "\gpuDriver.zip"
irm $gpuDriverUrl -outfile $gpuDriverLoc

# Unpack the file with 7zip and then install using the exe
$gpuDriverLoc = $tempDirectory + "\"
$uncompressLoc = $tempDirectory + "\unpacked"
md -Force $uncompressLoc | Out-Null
Get-ChildItem $gpuDriverLoc*.zip | % {& "C:\Program Files\7-Zip\7z.exe" "x" $_.fullname "-o$uncompressLoc"}
$setupLoc = $uncompressLoce + "\setup.exe"
Start-Process -FilePath $setupLoc -Wait -NoNewWindow

# Delete all items
Get-ChildItem -Path $tempDirectory -Include * | remove-Item -recurse


#Download Nvidia driver Patches for NC, NCv2, and ND Windows instances on Azure - This doesn't get NVIDIA Tesla driver patches for NV series instances
$gpuDriverUrl = "https://developer.nvidia.com/compute/cuda/9.0/Prod/patches/1/cuda_9.0.176.1_windows-exe"
$gpuDriverLoc = $tempDirectory + "\gpuDriver.zip"
irm $gpuDriverUrl -outfile $gpuDriverLoc

# Unpack the file with 7zip and then install using the exe
$gpuDriverLoc = $tempDirectory + "\"
$uncompressLoc = $tempDirectory + "\unpacked"
md -Force $uncompressLoc | Out-Null
Get-ChildItem $gpuDriverLoc*.zip | % {& "C:\Program Files\7-Zip\7z.exe" "x" $_.fullname "-o$uncompressLoc"}
$setupLoc = $uncompressLoc + "\setup.exe"
Start-Process -FilePath $setupLoc -Wait -NoNewWindow

# Delete all items
Get-ChildItem -Path $tempDirectory -Include * | remove-Item -recurse





# download and install the Cuda 9.0 toolkit from the web
$cuda90toolkitUrl = "https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda_9.0.176_win10-exe"
$cuda90ToolkitLoc = $tempDirectory + "\cuda_9.0.176_win10.exe"
irm $cuda90toolkitUrl -outfile $cuda90ToolkitLoc
Start-Process -FilePath $cuda90ToolkitLoc -ArgumentList "-s compiler_8.0" -Wait -NoNewWindow

# download and install the Cuda 9.0 toolkit patch
$cuda90PatchUrl = "https://developer.nvidia.com/compute/cuda/9.0/Prod/patches/1/cuda_9.0.176.1_windows-exe"
$cuda90patchLoc = $tempDirectory + "\cuda_9.0.176_win10_patch.exe"
irm $cuda90PatchUrl -outfile $cuda90patchLoc
start-process -FilePath $cuda90patchLoc -ArgumentList '/S' -wait
#Start-Process -FilePath $cuda90patchLoc -ArgumentList "-s compiler_8.0" -Wait -NoNewWindow


#Install cuDNN v6.0



# Delete all items
Get-ChildItem -Path $tempDirectory -Include * | remove-Item -recurse


# MAX_PATh limitation of 260 characters needs to be disabled by POwerShell

# download and install Python 3.6
#$python3Url = "https://www.python.org/ftp/python/3.6.2/python-3.6.2-amd64.exe"
#$python3Loc = $tempDirectory + "\python3.exe"
#irm $python3Url -outfile $python3Loc
#start-process -FilePath $python3Loc -wait


# check to see if path extensions .py and .pyw exist then update
[string]$tempPathExt = $env:PATHEXT
[string]$currentPathExt = $env:PATHEXT
If (-NOT($curentPathExt -like "*.PY*")) { $tempPathExt += ";.PY" } 
If (-NOT($curentPathExt -like "*.PYW*")) { $tempPathExt += ";.PYW" } 
[System.Environment]::SetEnvironmentVariable('pathext', $tempPathExt, [System.EnvironmentVariableTarget]::Machine)
refreshenv


[string]$tempPath = $env:PATH
[string]$currentPath = $env:PATH
If (
    (-NOT($curentPath -like "C:\Python36\;*")) -and
    (-NOT($curentPath -like "*C:\Python36\;*")) -and 
    (-NOT($curentPath -like "*C:\Python36\"))
    ) { $tempPath += ";C:\Python36\" } 
If (
    (-NOT($curentPath -like "C:\Program Files\Python36;*")) -and
    (-NOT($curentPath -like "*C:\Program Files\Python36;*")) -and 
    (-NOT($curentPath -like "*C:\Program Files\Python36"))
    ) { $tempPath += ";C:\Program Files\Python36" } 
If (
    (-NOT($curentPath -like "C:\Program Files\Python36\Scripts\;*")) -and
    (-NOT($curentPath -like "*C:\Program Files\Python36\Scripts\;*")) -and 
    (-NOT($curentPath -like "*C:\Program Files\Python36\Scripts\"))
    ) { $tempPath += ";C:\Program Files\Python36" } 
If (
    (-NOT($curentPath -like "C:\Python36\Scripts\;*")) -and
    (-NOT($curentPath -like "*C:\Python36\Scripts\;*")) -and 
    (-NOT($curentPath -like "*C:\Python36\Scripts\"))
    ) { $tempPath += ";C:\Python36\Scripts\" } 


[System.Environment]::SetEnvironmentVariable('path', $tempPath, [System.EnvironmentVariableTarget]::Machine)




# Refresh the environment variables
 refreshenv

# Install Pycharm community Edition Python IDE
choco install pycharm-community -y





# Install Non-GPU version of Tensorflow
python -m pip install --upgrade tensorflow


# Set timezone of the server
Set-TimeZone -Name "Eastern Standard Time"






#Start-Process -FilePath $cuda90ToolkitLoc -ArgumentList "-s compiler_8.0" -Wait -NoNewWindow



