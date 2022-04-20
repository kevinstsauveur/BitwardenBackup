$LibBitwardencli = "${PSScriptRoot}\Export\lib\Bitwardencli\bw.exe"
$LibKPScript = "${PSScriptRoot}\Export\lib\KeePass\KPScript.exe"
$LibSdelete = "${PSScriptRoot}\Export\lib\sdelete\sdelete64.exe"

Import-Module .\Export\src\DeleteItems\deleteItems.psm1

function Export {
  param(
	  [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Path of where the backup should be created. If not specified, the backup will be created in the current directory.")]
    [Alias("d")]
    [string]
    $directory = '.\',
    [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Path of where the backup should be created. If not specified, the backup will be created in the current directory.")]
    [Alias("p")]
    [string]
    $password
  )

  try
  {
    #Saving credentials
    if(-not [System.IO.File]::Exists(".\\Export\\Bitwarden.cred")){
        & $LibBitwardencli logout
        clear
        & $LibBitwardencli login --apikey
        & $LibBitwardencli lock
        clear

        $Bitwarden_password_SecureString = Read-Host -Prompt 'Please enter your master password' -AsSecureString
        clear
        $Bitwarden = New-Object System.Management.Automation.PSCredential (' ', $Bitwarden_password_SecureString)
        $Bitwarden | Export-CliXml -Path ".\\Export\\Bitwarden.cred"
    }

    if([System.IO.File]::Exists(".\Export\Bitwarden.cred")){
        $date = Get-Date -Format "yyyy-MM-dd_HHmm"

        #Import credentials
        $credentials = Import-CliXml -Path ".\Export\Bitwarden.cred"

        $session = & $LibBitwardencli unlock $credentials.GetNetworkCredential().Password --raw
        
        #Force client synchronisation
        & $LibBitwardencli sync --session $session

        #==========  Encrypted export json ========== 
        $outputFilejson = ".\Bitwarden_" + $date.ToString() + ".json"
        if(Test-Path $directory -PathType Container){
          $outputFilejson = $directory + "\Bitwarden_" + $date.ToString() + ".json"
        }

        & $LibBitwardencli export $credentials.GetNetworkCredential().Password --output $outputFilejson --format encrypted_json --session $session

        #========== Encrypted export Keepass ========== 
        $outputFileKeepass = ".\Bitwarden_" + $date.ToString() + ".kdbx"
        if(Test-Path $directory -PathType Container){
          $outputFileKeepass = $directory + "\Bitwarden_" + $date.ToString() + ".kdbx"
        }
        $tempfile = "./Export/tmp/tmp.json"

        #Create new file "Empty.kdbx" and change password
        Copy-Item .\Export\Empty.kdbx -Destination $outputFileKeepass -force
        if ($null -ne $password) {
          & $LibKPScript /KPScript -c:ChangeMasterKey $outputFileKeepass -pw:. -newpw:$password
        }else{
          & $LibKPScript /KPScript -c:ChangeMasterKey $outputFileKeepass -pw:. -newpw:$credentials.GetNetworkCredential().Password
        }

        #Export data to temporary unencrypted json file
        New-Item -ItemType Directory -Force -Path .\Export\tmp
        if ($null -ne $password) {
          & $LibBitwardencli export $password --output $tempfile --format json --session $session
        }else{
          & $LibBitwardencli export $credentials.GetNetworkCredential().Password --output $tempfile --format json --session $session
        }
        
        & $LibBitwardencli lock

        #Import data from json to keepass
        if ($null -ne $password) {
          & $LibKPScript /KPScript -c:Import $outputFileKeepass -pw:$password -Format:"Bitwarden JSON" -File:$tempfile
        }else{
          & $LibKPScript /KPScript -c:Import $outputFileKeepass -pw:$credentials.GetNetworkCredential().Password -Format:"Bitwarden JSON" -File:$tempfile
        }

        #Erase temp json from disk (secure erase for HDD)
            & $LibSdelete -p 5 -r -s -nobanner .\Export\tmp
        #If you have an SSD it's useless so erase normaly instead
            #Remove-Item '.\Export\tmp' -Recurse
        
        #Flush temp var
        $session = $null
        $credentials = $null
    }

    [string]$SavePath = (Get-Item ./).FullName;

    #Delete files
    deleteItems $SavePath 'json'
    deleteItems $SavePath 'kdbx'
    exit
  }
  catch
  {
    Write-Output 'An error occured during the backup process.'
  }
}

Export