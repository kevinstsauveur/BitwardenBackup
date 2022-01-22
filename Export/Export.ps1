$LibBitwardencli = "${PSScriptRoot}\lib\Bitwardencli\bw.exe"
$LibKPScript = "${PSScriptRoot}\lib\KeePass\KPScript.exe"
$LibSdelete = "${PSScriptRoot}\lib\sdelete\sdelete64.exe"

Import-Module .\src\DeleteItems\deleteItems.psm1

#Saving credentials
if(-not [System.IO.File]::Exists(".\Bitwarden.cred")){
    & $LibBitwardencli logout
	clear
    & $LibBitwardencli login --apikey
	& $LibBitwardencli lock
	clear

    $Bitwarden_password = Read-Host -Prompt 'Please enter your master password'
	clear
    $Bitwarden_password_SecureString = ConvertTo-SecureString $Bitwarden_password -AsPlainText -Force
    $Bitwarden = New-Object System.Management.Automation.PSCredential (' ', $Bitwarden_password_SecureString)
    $Bitwarden | Export-CliXml -Path ".\Bitwarden.cred"
}


if([System.IO.File]::Exists(".\Bitwarden.cred")){
    $date = Get-Date -Format "yyyy-MM-dd_HHmm"

    #Import credentials
    $credentials = Import-CliXml -Path ".\Bitwarden.cred"

    $session = & $LibBitwardencli unlock $credentials.GetNetworkCredential().Password --raw
	
	#Force client synchronisation
	& $LibBitwardencli sync --session $session

    #==========  Encrypted export json ========== 
    $outputFilejson = "..\Bitwarden_" + $date.ToString() + ".json"

    & $LibBitwardencli export $credentials.GetNetworkCredential().Password --output $outputFilejson --format encrypted_json --session $session

    #========== Encrypted export Keepass ========== 
    $outputFileKeepass = "..\Bitwarden_" + $date.ToString() + ".kdbx"
    $tempfile = "./tmp/tmp.json"

    #Create new file "Empty.kdbx" and change password
    Copy-Item .\Empty.kdbx -Destination $outputFileKeepass -force
    & $LibKPScript /KPScript -c:ChangeMasterKey $outputFileKeepass -pw:. -newpw:$credentials.GetNetworkCredential().Password

    #Export data to temporary unencrypted json file
	New-Item -ItemType Directory -Force -Path .\tmp
    & $LibBitwardencli export $credentials.GetNetworkCredential().Password --output $tempfile --format json --session $session
	
	& $LibBitwardencli lock

    #Import data from json to keepass
    & $LibKPScript /KPScript -c:Import $outputFileKeepass -pw:$credentials.GetNetworkCredential().Password -Format:"Bitwarden JSON" -File:$tempfile

    #Erase temp json from disk (secure erase for HDD)
		& $LibSdelete -p 5 -r -s -nobanner .\tmp
	#If you have an SSD it's useless so erase normaly instead
		#Remove-Item '.\tmp' -Recurse
	
	#Flush temp var
	$session = $null
	$credentials = $null
}

[string]$SavePath = (Get-Item ../).FullName;

#Delete files
deleteItems $SavePath 'json'
deleteItems $SavePath 'kdbx'
exit