$LibBitwardencli = "${PSScriptRoot}\lib\Bitwardencli\bw.exe"
$LibKPScript = "${PSScriptRoot}\lib\KeePass\KPScript.exe"
$LibSdelete = "${PSScriptRoot}\lib\sdelete\sdelete64.exe"

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
    #Encrypt files
    Import-Module .\src\gpg\gpg.psm1
    
    $date = Get-Date -Format "yyyy-MM-dd_HHmm"
    $PGPRecipient = "email@recipient.com"

    #Import credentials
    $credentials = Import-CliXml -Path ".\Bitwarden.cred"

    $session = & $LibBitwardencli unlock $credentials.GetNetworkCredential().Password --raw
	
	#Force client synchronisation
	& $LibBitwardencli sync --session $session

    #==========  Encrypted export json ========== 
    $outputFilejson = ".\tmp\Bitwarden_" + $date.ToString() + ".json"
	$outputFilejsonPGP = "..\Bitwarden_" + $date.ToString() + ".json.gpg"

    & $LibBitwardencli export $credentials.GetNetworkCredential().Password --output $outputFilejson --format encrypted_json --session $session
    gpgItem $outputFilejson $outputFilejsonPGP $PGPRecipient

    #========== Encrypted export Keepass ========== 
    $outputFileKeepass = ".\tmp\Bitwarden_" + $date.ToString() + ".kdbx"
    $outputFileKeepassPGP = "..\Bitwarden_" + $date.ToString() + ".kdbx.gpg"
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

    gpgItem $outputFileKeepass $outputFileKeepassPGP $PGPRecipient

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
Import-Module .\src\DeleteItems\deleteItems.psm1
deleteItems $SavePath 'json.gpg'
deleteItems $SavePath 'kdbx.gpg'

exit