Function DownloadPython367
{
  <#
  .SYNOPSIS
  Download the 64 bit Exe install file from Python.org to the target destination and name
  .DESCRIPTION
  Installs Python Onto a Windows machine for all users with symbols and all tools
  #>
  Param (
[string]$savePathAndName
   )
   $pythonUrl = "https://www.python.org/ftp/python/3.6.7/python-3.6.7-amd64.exe"
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   (New-Object System.Net.WebClient).DownloadFile($pythonUrl, $savePathAndName) 
}


Function InstallPythonExe
{
  <#
  .SYNOPSIS
  Installs an already downloaded Python exe onto a Windows machine
  .DESCRIPTION
  Installs Python Onto a Windows machine for all users with symbols and all tools
  #>
    Param(
    [string]$fileToInstall
) 
	$Arguments = @()
	$Arguments += "/i"
	$Arguments += 'InstallAllUsers="1"'
	$Arguments += 'TargetDir="C:\Python36"'
	$Arguments += 'DefaultAllUsersTargetDir="C:\Python36"'
	$Arguments += 'AssociateFiles="1"'
	$Arguments += 'PrependPath="1"'
	$Arguments += 'Include_doc="1"'
	$Arguments += 'Include_debug="1"'
	$Arguments += 'Include_dev="1"'
	$Arguments += 'Include_exe="1"'
	$Arguments += 'Include_launcher="1"'
	$Arguments += 'InstallLauncherAllUsers="1"'
	$Arguments += 'Include_lib="1"'
	$Arguments += 'Include_pip="1"'
	$Arguments += 'Include_symbols="1"'
	$Arguments += 'Include_tcltk="1"'
	$Arguments += 'Include_test="1"'
	$Arguments += 'Include_tools="1"'
	$Arguments += "/passive"
	Start-Process $fileToInstall -ArgumentList $Arguments -Wait
}


Function GetAndInstallPython367
{
  <#
  .SYNOPSIS
  Download and Install Python onto a Windows Machine
  .DESCRIPTION
  Downloads from Python.org and installs Python Onto a Windows machine for all users with symbols and all tools
  #>
      Param (
    [string]$saveDirectory = "C:\temp"
   )
   New-Item -ItemType directory -Path $saveDirectory -Force | Out-Null
   $pyFile = "python367.exe"
   $pythonNameLoc = Join-Path $saveDirectory $pyFile
   DownloadPython367 $pythonNameLoc
   InstallPythonExe $pythonNameLoc
}


Function Get-EnvVariableNameList {
  <#
  .SYNOPSIS
  returns the names of all the envirnomental variables as an array list
  .DESCRIPTION
  returns the names of all the envirnomental variables as an array list
  #>
    [cmdletbinding()]
    $allEnvVars = Get-ChildItem Env:
    $allEnvNamesArray = $allEnvVars.Name
    $pathEnvNamesList = New-Object System.Collections.ArrayList
    $pathEnvNamesList.AddRange($allEnvNamesArray)
    return ,$pathEnvNamesList
}


Function Add-EnvVarIfNotPresent {
  <#
  .SYNOPSIS
  Append an environmental variable to Machine, process and user if that variable name isn't already present
  .DESCRIPTION
  Checks if the environmental variable name is present. If it doesn't then the method adds and updates it to machine, process and user
  #>
#[cmdletbinding()]
Param (
[string]$variableNameToAdd,
[string]$variableValueToAdd
   ) 
    $nameList = Get-EnvVariableNameList
    $alreadyPresentCount = ($nameList | Where{$_ -like $variableNameToAdd}).Count
    #$message = ''
    if ($alreadyPresentCount -eq 0)
    {
    [System.Environment]::SetEnvironmentVariable($variableNameToAdd, $variableValueToAdd, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable($variableNameToAdd, $variableValueToAdd, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable($variableNameToAdd, $variableValueToAdd, [System.EnvironmentVariableTarget]::User)
        $message = "Enviromental variable added to machine, process and user to include $variableNameToAdd"
    }
    else
    {
        $message = 'Environmental variable already exists. Consider using a different function to modify it'
    }
    Write-Information $message
}


Function Get-EnvExtensionList {
  <#
  .SYNOPSIS
  returns the env path extensions as an array list
  .DESCRIPTION
  returns the env path extensions as an array list
  #>
    [cmdletbinding()]
    $pathExtArray =  ($env:PATHEXT).Split("{;}")
    $pathExtList = New-Object System.Collections.ArrayList
    $pathExtList.AddRange($pathExtArray)
    return ,$pathExtList
}


Function Add-EnvExtension {
  <#
  .SYNOPSIS
  Append a path extension to Machine, process and user paths
  .DESCRIPTION
  Checks if the $env:PATHEXT has the path entered. If it doesn't then the method adds and updates it to machine, process and user
  #>
#[cmdletbinding()]
Param (
[string]$pathExtToAdd
   ) 
    $pathList = Get-EnvExtensionList
    $alreadyPresentCount = ($pathList | Where{$_ -like $pathToAdd}).Count
    #$message = ''
    if ($alreadyPresentCount -eq 0)
    {
        $pathList.Add($pathExtToAdd)
        $returnPath = $pathList -join ";"
        [System.Environment]::SetEnvironmentVariable('pathext', $returnPath, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable('pathext', $returnPath, [System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('pathext', $returnPath, [System.EnvironmentVariableTarget]::User)
        $message = "Path extension added to machine, process and user paths to include $pathExtToAdd"
    }
    else
    {
        $message = 'Path extension already exists'
    }
    Write-Information $message
}


Function Remove-EnvExtension {
  <#
  .SYNOPSIS
  Remove a path extension from machine, process and user paths
  .DESCRIPTION
  Checks if the $env:PATHEXT has the path entered. If it does, then it removes it from machine, process and user
  #>
    #[cmdletbinding()]
    Param (
    [string]$PathExtToRemove
       ) 
    # End of Parameters
    $preRemovalExtArray = Get-EnvExtensionList
    $pathList = New-Object System.Collections.ArrayList
    $pathList = $preRemovalExtArray | Where{!($_ -like $PathExtToRemove)}
    [int] $dif = $preRemovalExtArray.Count - $pathList.Count
    If($dif -gt 0)
    {
    $returnPath = $pathList -join ";"
    [System.Environment]::SetEnvironmentVariable('pathext', $returnPath, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('pathext', $returnPath, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('pathext', $returnPath, [System.EnvironmentVariableTarget]::User)
    }
    $message = "Removed " + $dif.ToString() + " paths fom the machine, process, and user environments."
    Write-InformatioN $message
}


Function Get-EnvPathList {
  <#
  .SYNOPSIS
  returns the env paths as an array list
  .DESCRIPTION
  returns the env paths as an array list
  #>
    [cmdletbinding()]
    $pathArray =  ($env:PATH).Split("{;}")
    $pathList = New-Object System.Collections.ArrayList
    $pathList.AddRange($pathArray)
    return ,$pathList
}


Function Add-EnvPath {
  <#
  .SYNOPSIS
  Append a path to Machine, process and user paths
  .DESCRIPTION
  Checks if the $env:Path has the path entered. If it doesn't then the method adds and updates it to machine, process and user
  #>
#[cmdletbinding()]
Param (
[string]$pathToAdd
   ) 
    $pathList = Get-EnvPathList
    $alreadyPresentCount = ($pathList | Where{$_ -like $pathToAdd}).Count
    #$message = ''
    if ($alreadyPresentCount -eq 0)
    {
        $pathList.Add($pathToAdd)
        $returnPath = $pathList -join ";"
        [System.Environment]::SetEnvironmentVariable('path', $returnPath, [System.EnvironmentVariableTarget]::Machine)
        [System.Environment]::SetEnvironmentVariable('path', $returnPath, [System.EnvironmentVariableTarget]::Process)
        [System.Environment]::SetEnvironmentVariable('path', $returnPath, [System.EnvironmentVariableTarget]::User)
        $message = "Path added to machine, process and user paths to include $pathToAdd"
    }
    else
    {
        $message = 'Path already exists'
    }
    Write-Information $message
}


Function Remove-EnvPath {
  <#
  .SYNOPSIS
  Remove a path from machine, process and user paths
  .DESCRIPTION
  Checks if the $env:Path has the path entered. If it does, then it removes it from machine, process and user
  #>
    #[cmdletbinding()]
    Param (
    [string]$PathToRemove
       ) 
    # End of Parameters
    $preRemovalPathArray = Get-EnvPathList
    $pathList = New-Object System.Collections.ArrayList
    $pathList = $preRemovalPathArray | Where{!($_ -like $PathToRemove)}
    [int] $dif = $preRemovalPathArray.Count - $pathList.Count
    If($dif -gt 0)
    {
    $returnPath = $pathList -join ";"
    [System.Environment]::SetEnvironmentVariable('path', $returnPath, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('path', $returnPath, [System.EnvironmentVariableTarget]::Process)
    [System.Environment]::SetEnvironmentVariable('path', $returnPath, [System.EnvironmentVariableTarget]::User)
    }
    $message = "Removed " + $dif.ToString() + " paths fom the machine, process, and user environments."
    Write-InformatioN $message
}


# Set timezone of the server
Set-TimeZone -Name "Eastern Standard Time"

Set-ExecutionPolicy Bypass -Scope Process -Force

# Ensure PS remoting is enabled, although this is enabled by default for Azure VMs
Enable-PSRemoting -Force

# Create rule in Windows Firewall
New-NetFirewallRule -Name "WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP

# Create Self Signed certificate and store thumbprint
$thumbprint = (New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My).Thumbprint

# Run WinRM configuration on command line. DNS name set to computer hostname, you may wish to use a FQDN
$cmd = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$env:computername""; CertificateThumbprint=""$thumbprint""}"
cmd.exe /C $cmd

#Install Nuget Package provider
Install-PackageProvider -Name NuGet -Force

# Install Powershell Get to facilitate installing packages from PowerShellGallery.com
Install-Module -Name PowerShellGet -Force 

# Facilitates using the Windows package installer Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#choco install chocolatey-core.extension


# Download and install Python 3.6.7
GetAndInstallPython367

# Update the path variables to facilitate using Pip and Pip3 to install Python packages
Add-EnvExtension '.PY'
Add-EnvExtension '.PYW'
Add-EnvPath 'C:\Program Files\Python36\'
Add-EnvPath 'C:\Program Files\Python36'
Add-EnvPath 'C:\Program Files\Python36\Scripts'
Add-EnvPath 'C:\Python36\Scripts\'
Add-EnvPath 'C:\Python36\'
Add-EnvPath 'C:\Python36\Scripts'


# upgrade setup tools 
python -m pip install --upgrade setuptools
python -m pip install -U wheel

# upgrade Pip installer
python -m pip install --upgrade pip
python -m pip install --upgrade pip setuptools
pip3 install --upgrade pip


# Install the Intel optimized libraries for Python machine learning
python -m pip install intel-scikit-learn
python -m pip install intel-numpy

# This wheel is only for Linux
#https://software.intel.com/en-us/articles/intel-optimization-for-tensorflow-installation-guide
#python -m pip install https://storage.googleapis.com/intel-optimized-tensorflow/tensorflow-1.11.0-cp36-cp36m-linux_x86_64.whl

# This is not the Intel optimized version of Tensorflow
pip3 install --upgrade tensorflow
