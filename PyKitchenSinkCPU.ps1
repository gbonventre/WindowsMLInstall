# Comment out the parts you don't need to reduce isntallation time and disk usage

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

# Install build stuff and C and C++ items needed by some of the Python NLP Libraries to work faster
# You can skip these installs if you are not using any of the NLP Libraries like Gensim or SpaCy
choco install microsoft-build-tools -y
choco install kb2999226 -y
choco install vcredist140 -y
choco install vcredist2017 -y
choco install vcredist-all -y
choco install visualstudio2017buildtools -y
choco install visualcppbuildtools -y
choco install visualstudio2017community -y #Just to get the C++ compiler

# Install 7zip compression software
choco install 7zip -y

#git
choco install git -y
Add-EnvPath 'C:\Program Files\Git\cmd'

# Install a HexEditor hXD
choco install hxd -y

# Install freewhere Hexeditor XVI32
# Needs more work


# Install Python 3.6, Assumes that Python 3.6 is the latest version
# Todo need to check what version of Python 3 is installed
choco install python3 -y

# Update the path variables to facilitate using Pip and Pip3 to install Python packages
Add-EnvExtension '.PY'
Add-EnvExtension '.PYW'
Add-EnvPath 'C:\Program Files\Python36\'
Add-EnvPath 'C:\Program Files\Python36'
Add-EnvPath 'C:\Program Files\Python36\Scripts'
Add-EnvPath 'C:\Python36\Scripts\'
Add-EnvPath 'C:\Python36\'
Add-EnvPath 'C:\Python36\Scripts'
# add also C:\Users\<computer>\AppData\Roaming\Python\Python36\Scripts


# Install C++ compiler. This package installer sometimes has intermitent errors
# You can comment out this part if you are not using any of the NLP Libraries such as GenSim or SpaCy
$isInstalled = $false
For ($i=0; $i -le 10; $i++) {
    try{
        choco install vcpython27 -y
        $isInstalled = $true
        If($isInstalled) {break}
        }
    catch{}
    }

# #Make the temp folder that holds the install files
# $tempDirectory = "C:\temp_provision"
# New-Item -ItemType directory -Path $tempDirectory -Force | Out-Null

# # Download and Install the Visual C++ compiler for Python 2.7 and 3.6
# # make sure 7zip is installed first
# #$visualCppUrl = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=44266"
# $visualCppUrl = "https://download.microsoft.com/download/7/9/6/796EF2E4-801B-4FC4-AB28-B59FBF6D907B/VCForPython27.msi"
# $visualCppLoc = $tempDirectory + "\Cpp.msi"
# Invoke-RestMethod $visualCppUrl -outfile $visualCppLoc
# Start-Process -FilePath $visualCppLoc -Wait -ArgumentList "/q" -Verb runas
# msiexec /i C:\temp_provision\Cpp.msi ALLUSERS=1 /q

# Install Pycharm IDE for Python
choco install pycharm-community -y

# Installs the browser
choco install firefox -y

#c:\python36\python.exe -m pip install --upgrade pip setuptools
# upgrade setup tools 
python -m pip install --upgrade setuptools

# upgrade Pip installer
python -m pip install --upgrade pip
pip install --upgrade pip setuptools

#Install Cython
python -m pip install Cython

#Install SpaCy
python -m pip install -U spacy
# Install the Language Models for SpaCy
pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_lg-2.0.0/en_core_web_lg-2.0.0.tar.gz
#python -m spacy download en
#python -m spacy.en.download all
#python -m spacy download xx
#python -m spacy download en_core_web_lg

# Install Gensim
python -m pip install --upgrade gensim
python -m pip install pyro4

#Install Jupyter
python -m pip install jupyter

python -m pip install --user certifi

#Install SciKitLearn
python -m pip install -U scikit-learn

#Install NLTK
python -m pip install -U nltk

#Make the temp folder that holds NLTK corpora
# Todo issue installing NLTK corpora
$nltkDirectory = "C:\nltk_data"
New-Item -ItemType directory -Path $nltkDirectory -Force | Out-Null
cd C:\nltk_data
# can't get punkt installed
#python -m nltk.downloader punkt 
# Download the NLTK popular corpora
#python -m nltk.downloader popular

# Download all the NLTK corpora
# couldn't get it all installed correctly
#python -m nltk.downloader all

# python -c "import nltk; nltk.download('punkt')"
cd C:\Windows\System32

#Install TextBlob
python -m pip install -U textblob
python -m textblob.download_corpora

#Install MatPlotLib
python -m pip install matplotlib

# Install statsmodels
python -m pip install -U statsmodels

#Install Pandas
python -m pip install pandas

#Install NumPy
python -m pip install numpy

#Install SciPy. Probably already installed from a previous package
python -m pip install scipy

#Instal PatSy
python -m pip install patsy

#Install Seaborne - lots of dependencies needed. So install last
python -m pip install seaborn

#Install Nose Test Suite
python -m pip install nose

#Install  Jinja2
python -m pip install Jinja2

#Install Six
python -m pip install six

python -m pip install --user pipenv

python -m pipenv install requests

python -m pip install tornado

python -m pip install pyyaml

python -m pip install python-dateutil

#Install Bokeh
python -m pip install bokeh

#Install virutal environment
python -m pip install virtualenv

python -m pip install pyqtgraph

python -m pip install flask

python -m pip install virtualenvwrapper-win

python -m pip install django


# X-13ARIMA-SEATS , Todo: Add to installer for this timeseries library

# Todo add install for Stanford CoreNLP python wrapper

#Install Azure PowerShell Tools
Install-Module -Name Azure -Force
Install-Module -Name AzureRM -Force

# Install Azure CLI
choco install azure-cli -y

# Install Azure related Python libraries
python -m pip install azure                # pip install Azure
python -m pip install azure-storage
python -m pip install azure-batch          # Install the latest Batch runtime library
python -m pip install azure-mgmt-scheduler # Install the latest Storage management library
python -m pip install azure-mgmt-compute # will install only the latest Compute Management library
python -m pip install azure-cosmosdb-table  # pip install stuff for storage tables and cosmos bs

# Install Google Cloud PowerShell Library
Install-Module -Name GoogleCloud -Force

# Install Google Cloud Python Client Libraries
python -m pip install --upgrade google-cloud

# Install AWS PowerShell Library
Install-Module -Name AWSPowerShell -Force

#Install Python AWS Client Library
python -m pip install boto3

#install the PYODBC driver for SQL Server
# See full Install Instructions in https://docs.microsoft.com/en-us/sql/connect/python/pyodbc/step-1-configure-development-environment-for-pyodbc-python-development
# download and install this - I think that this can be replaced with the chocolatey package
#https://www.microsoft.com/en-us/download/confirmation.aspx?id=56567
# Todo Make sure that python version is 3.6
cd C:\Python36\Scripts 
python pip -m install pyodbc
# pay attention to which version of the ODBC driver is used becuase each database connection references it

#https://aka.ms/vs/15/release/VC_redist.x64.exe

# The non-GPU version of TensorFlow
pip3 install --upgrade tensorflow

# Install Keras
python -m pip install keras

# Install PyTourch
python -m pip install torch

# Install Cognitive Toolkit (formerly CNTK) non-GPU version
python -m pip install cntk

Restart-Computer -Force




