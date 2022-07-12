<p align="center">
    <a href="https://github.com/kevinstsauveur/BitwardenBackup">
        <img src="../assets/logo.png"/>
    </a>
    <br/><br/>
    <a href="https://github.com/kevinstsauveur/bitwardenbackup/releases/latest">
        <img src="https://img.shields.io/github/v/release/kevinstsauveur/bitwardenbackup.svg" />
    </a>
    <a href="https://github.com/kevinstsauveur/BitwardenBackup/actions/workflows/powershell.yml">
        <img alt="GitHub Workflow Status (branch)" src="https://img.shields.io/github/workflow/status/kevinstsauveur/bitwardenbackup/PSScriptAnalyzer/main?label=PSScriptAnalyzer">
    </a>
    <a href="https://github.com/kevinstsauveur/BitwardenBackup/blob/main/LICENSE">
        <img alt="GitHub" src="https://img.shields.io/github/license/kevinstsauveur/bitwardenbackup?color=blue">
    </a>
    <a href="https://www.codacy.com/gh/kevinstsauveur/BitwardenBackup/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=kevinstsauveur/BitwardenBackup&amp;utm_campaign=Badge_Grade">
        <img alt="Codacy branch grade" src="https://img.shields.io/codacy/grade/1a1c0864204e463592bcb2cc72f625ba/main?color=succes">
    </a>
</p>

---

# Summary

This project contains a Powershell script that exports Bitwarden passwords to a KeePass database as well as json encrypted format.

For more details on how the data is stored, see [KeePass](https://keepass.info/), [Bitwarden encrypted json](https://bitwarden.com/help/article/encrypted-export/) and Windows [SecureString](https://docs.microsoft.com/en-us/dotnet/api/system.security.securestring?view=net-5.0).

## Dependencies

-   [Bitwarden CLI](https://bitwarden.com/help/article/cli/#download--install)
-   [KeePass](https://keepass.info/download.html)
-   [KPScript](https://keepass.info/plugins.html)
-   [Sdelete](https://docs.microsoft.com/en-us/sysinternals/downloads/sdelete)

## Usage

Simply run the `Export.ps1` script every time you want to backup your vault. It creates a new `kdbx` (KeePass Vault) and a new `json` (encrypted bitwarden's json) each time you run the script `Export.ps1`.

At first, it will ask you for your Bitwarden credentials. You will need your [API Key](https://bitwarden.com/help/personal-api-key/) that you can find in your online vault's settings. Those are your OAuth 2.0 Client Credentials that will be used to authenticate. Your client_id and your client_secret will be needed. Once those are logged in, your master password will be asked.

The generated encrypted files are saved at the same level as `Export`.

:warning: Be sure that you're using a secure trusted computer while doing a backup of your passwords.

### Problems?

If you have any problem when you connect, you entered the wrong password or the script shows errors, you can reset BitwardenBackup to ask for your credentials again by deleting `Bitwarden.cred` in `/Export`.

## Installation

### Bundled pack
The Releases contains everything that’s needed. There's no need to do those steps. If you would like to do it yourself, feel free to follow those below.

### Manual install

The directory we will need to extract files are all in `./Export/lib/`.

```bash
└───Export
    ├───lib
    │   ├───Bitwardencli
    │   ├───KeePass
    │   └───sdelete
    └───src
        └───deleteItems
```

1.  Download and extract the latest version of Bitwardencli, `bw.exe` must be in `./Export/lib/Bitwardencli`. I encourage you to validate the [checksum](https://github.com/bitwarden/cli/releases) of the file.
2.  Download and extract the latest version of KeePass (.zip portable version), `KeePass.exe` must be in `./Export/lib/KeePass`. I encourage you to validate the [signature](https://keepass.info/integrity.html) of the file.
3.  Download and extract the latest version of KPScript for Keepass, `KPScript.exe` must be in `./Export/lib/KeePass`. I encourage you to validate the [signature](https://keepass.info/integrity_etc.html) of the file.
4.  Download and extract the latest version of sdelete, `sdelete64.exe` must be in `./Export/lib/KeePass`.
5.  Create a new empty KeePass vault. The format of the vault should be KDBX 4, named `Empty.kdbx` and its password should be `.`. The file must be in `./Export/`. Be sure to use secure vault settings. This vault will be used to import your passwords and its password will be replaced by your main password.

## Auto execution

This script can be started automatically with the Windows task scheduler each time you connect to your session.

## File Lifecycle and autodelete

The following intervals are used and they each have a maximum number of files that will be kept for each.

**1 Hour**
For the first day, the youngest version of every day is kept.

**2 week**
For the last two week, one file per day is kept.

**2 month**
For the last two month, one file per week is kept.

**>2 month**
For the files that are older than two months, the youngest version of every month is kept.

This means that there is only one version in each interval and as files age they will be deleted unless when the interval they are entering is empty.
