$LibBitwardencli = "${PSScriptRoot}\lib\Bitwardencli\bw.exe"
$LibKPScript = "${PSScriptRoot}\lib\KeePass-2.47\KPScript.exe"
$LibSdelete = "${PSScriptRoot}\lib\sdelete\sdelete64.exe"

Import-Module .\src\DeleteItems\deleteItems.psm1

#Saving credentials
if(-not [System.IO.File]::Exists(".\Bitwarden.cred")){
    & $LibBitwardencli logout
    $credentials = Get-Credential
    $credentials | Export-CliXml -Path ".\Bitwarden.cred"
	
    $codetype = Read-Host -Prompt 'Two Step Login - Please enter numeric value 0) Authenticator 1) Email 3) Yubikey'
    $code = Read-Host -Prompt 'Please enter code'
    & $LibBitwardencli login  $credentials.UserName $credentials.GetNetworkCredential().Password --method $codetype --code $code
    & $LibBitwardencli lock
}


if([System.IO.File]::Exists(".\Bitwarden.cred")){
    $date = Get-Date -Format "yyyy-MM-dd_HHmm"

    #Import credentials
    $credentials = Import-CliXml -Path ".\Bitwarden.cred"

    $session = & $LibBitwardencli unlock $credentials.GetNetworkCredential().Password --raw

    #==========  Encrypted export json ========== 
    $outputFilejson = "..\Bitwarden_" + $date.ToString() + ".json"

    & $LibBitwardencli export $credentials.GetNetworkCredential().Password --output $outputFilejson --format encrypted_json --session $session

    #========== Encrypted export Keepass ========== 
    $outputFileKeepass = "..\Bitwarden_" + $date.ToString() + ".kdbx"
    $tempfile = "./tmp/tmp.json"

    #Create new file "Empty.kdbx" and change password
    Copy-Item .\Empty.kdbx -Destination $outputFileKeepass -force
    & $LibKPScript /KPScript -c:ChangeMasterKey $outputFileKeepass -pw:empty -newpw:$credentials.GetNetworkCredential().Password

    #Export data to temporary unencrypted json file
	New-Item -ItemType Directory -Force -Path .\tmp
    & $LibBitwardencli export $credentials.GetNetworkCredential().Password --output $tempfile --format json --session $session
	
	& $LibBitwardencli lock

    #Import data from json to keepass
    & $LibKPScript /KPScript -c:Import $outputFileKeepass -pw:$credentials.GetNetworkCredential().Password -Format:"Bitwarden JSON" -File:$tempfile

    #Erase temp json from disk (secure erase for HDD)
		$LibSdelete -p 5 -r -s -nobanner .\tmp
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