# This is the link to download Python 3.6.7
$pythonUrl = "https://www.python.org/ftp/python/3.6.7/python-3.6.7-amd64.exe"


# #Make the temp folder that holds the install files
$tempDirectory = "C:\temp_provision\"
$pythonNameLoc = $tempDirectory + "python376.exe"
New-Item -ItemType directory -Path $tempDirectory -Force | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(New-Object System.Net.WebClient).DownloadFile($pythonUrl, $pythonNameLoc)


	$Arguments = @()
	$Arguments += "/i"
	$Arguments += "`"$installer`""
	$Arguments += "InstallAllUsers=`"1`""
	$Arguments += "TargetDir=`"C:\Python36`""
	$Arguments += "DefaultAllUsersTargetDir=`"C:\Python36`""
    $Arguments += "AssociateFiles=`"1`""
    $Arguments += "PrependPath=`"1`""
    $Arguments += "Include_doc=`"1`""
    $Arguments += "Include_debug=`"1`""
    $Arguments += "Include_dev=`"1`""
    $Arguments += "Include_exe=`"1`""
    $Arguments += "Include_launcher=`"1`""
    $Arguments += "InstallLauncherAllUsers=`"1`""
    $Arguments += "Include_lib=`"1`""
    $Arguments += "Include_pip=`"1`""
    $Arguments += "Include_symbols=`"1`""
    $Arguments += "Include_tcltk=`"1`""
    $Arguments += "Include_test=`"1`""
    $Arguments += "Include_tools=`"1`""
    $Arguments += "Include_launcher=`"1`""
    $Arguments += "Include_launcher=`"1`""
    $Arguments += "Include_launcher=`"1`""
    $Arguments += "Include_launcher=`"1`""
    $Arguments += "Include_launcher=`"1`""
    $Arguments += "Include_launcher=`"1`""
    $Arguments += "/passive"



#$pythonArgs     = '/quiet InstallAllUsers=1 PrependPath=1 TargetDir="{0}"' -f $installDir

$packageArgs = @{
    packageName    = 'python3'
    fileType       = 'exe'
    file           = $pythonNameLoc
    file64         = $pythonNameLoc
    silentArgs     = $Arguments#'/quiet InstallAllUsers=1 PrependPath=1 TargetDir="{0}"' -f $installDir
    validExitCodes = @(0)
    softwareName   = 'Python*'
}

start-process -FilePath $pythonNameLoc -ArgumentList $packageArgs -wait
start-process -FilePath $cuda90patchLoc -ArgumentList '/S' -wait
