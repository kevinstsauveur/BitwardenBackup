$gpg_prog = "${env:ProgramFiles(x86)}" + "\GnuPG\bin\gpg.exe"

function gpgItem{
	param (
        [Parameter(Mandatory=$true)]
		[string]$in_file,
		[Parameter(Mandatory=$true)]
		[string]$out_file,
        [Parameter(Mandatory=$true)]
		[string]$recipients
    )
    & $gpg_prog --output $out_file --encrypt --sign --recipient $recipients $in_file
}