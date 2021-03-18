# BitwardenBackup

This project contains a Powershell script that exports Bitwarden passwords to a KeePass database as well as json encrypted format.

For more details to how the data is stored, see [KeePass project](https://keepass.info/), [Bitwarden encrypted json]https://bitwarden.com/help/article/encrypted-export/) and windows [SecureString](https://docs.microsoft.com/en-us/dotnet/api/system.security.securestring?view=net-5.0#how-secure-is-securestring).

## Dependencies (already included)
* [Bitwarden CLI](https://bitwarden.com/help/article/cli/#download--install)
* [KeePass](https://keepass.info/download.html)
* [KPScript](https://keepass.info/plugins.html)
* [Sdelete](https://docs.microsoft.com/en-us/sysinternals/downloads/sdelete)

## Usage

Simply run the `Export.ps1` script every time you want to backup your vault. It creates a new `kdbx` (KeePass Vault) and a new `json` (encrypted bitwarden's json) each time you run the script `Export.ps1`.

At first, it will ask you for your credentials. Your password is stored in the `Bitwarden.cred` file and it contains your username and password. Your master password will be stored on your hardd rive in an encrypted form and can only be decrypted by your user on your windows computer.

The generated files are saved at the same level as Export.

## Auto execution
This script can be started automatically with the Windows task scheduler each time you connect to your session.

## File Lifecycle and autodelete

The script keeps the files this way:
1. One file per day
2. One file per day for the last week to the last two week
3. One file per week if it's not the last two weeks
4. One file per month if it's not the last two months
5. All the other files are deleted

If you're a visual person, here's an example of the files Lifecycle:
```
Bitwarden_2020-10-31_1250.kdbx //Once a month
Bitwarden_2020-11-30_0944.kdbx
Bitwarden_2020-12-31_0825.kdbx
Bitwarden_2021-01-31_0450.kdbx
Bitwarden_2021-02-03_1210.kdbx //Once a week for the two last months
Bitwarden_2021-02-10_1755.kdbx
Bitwarden_2021-02-17_0900.kdbx
Bitwarden_2021-02-24_2134.kdbx
Bitwarden_2021-03-03_1210.kdbx //Once a day for the last 2 weeks
Bitwarden_2021-03-04_1050.kdbx
Bitwarden_2021-03-07_1954.kdbx
Bitwarden_2021-03-08_1720.kdbx
Bitwarden_2021-03-09_1540.kdbx
Bitwarden_2021-03-10_2015.kdbx
Bitwarden_2021-03-11_0740.kdbx
Bitwarden_2021-03-12_0902.kdbx
Bitwarden_2021-03-13_1129.kdbx
Bitwarden_2021-03-14_1153.kdbx
Bitwarden_2021-03-15_1226.kdbx
Bitwarden_2021-03-16_1254.kdbx
Bitwarden_2021-03-17_1903.kdbx //Today
```
