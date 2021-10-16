# BitwardenBackup

This project contains a Powershell script that exports Bitwarden passwords to a KeePass database as well as json encrypted format.

For more details on how the data is stored, see [KeePass](https://keepass.info/), [Bitwarden encrypted json](https://bitwarden.com/help/article/encrypted-export/) and Windows [SecureString](https://docs.microsoft.com/en-us/dotnet/api/system.security.securestring?view=net-5.0).

## Dependencies (already included)
* [Bitwarden CLI](https://bitwarden.com/help/article/cli/#download--install)
* [KeePass](https://keepass.info/download.html)
* [KPScript](https://keepass.info/plugins.html)
* [Sdelete](https://docs.microsoft.com/en-us/sysinternals/downloads/sdelete)

## Usage

Simply run the `Export.ps1` script every time you want to backup your vault. It creates a new `kdbx` (KeePass Vault) and a new `json` (encrypted bitwarden's json) each time you run the script `Export.ps1`.

At first, it will ask you for your Bitwarden credentials. It will be stored in `Bitwarden.cred` and it contains your username and password. Your master password will be stored in an encrypted form and can only be decrypted by your user on your Windows computer.

The generated encrypted files are saved at the same level as `Export`.

:warning: This script temporally stores the content of your vault for a really short period of time in a `json` file in `Export/tmp/`. This script securely delete this temp file by overwriting it 5 times to prevent a recovery tool to be able to recover anything. Even if this script securely deletes the file, I encourage you to perform a full disk encryption.

:warning: To prevent unauthorized access to this temporary file for the moment it's in your computer, you can use [Windows controlled folder access](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/controlled-folders) and [only authorize requested applications](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/customize-controlled-folders) and protect the directory where you store this script. This will add an additional layer of security to protect your passwords.

## Auto execution
This script can be started automatically with the Windows task scheduler each time you connect to your session.

## KeePass

### Encryption
The provided KeyPass Vault use this encryption parameter:
* Database file encryption algorithm: ChaCha20 (256-bit key, RFC 7539)

### Key transformation
The provided KeePass Vault may not use the perfect Key transformation parameters that fits your needs. The provided one is created with these parameters:
* Key derivation function: Argon2d
* Iterations: 10
* Memory: 512 MB
* Parallelism: 4
It generally takes ~1s to open/save KeePass.

There's more details the way these parameters impact the security on [KeePass's website in the Protection against Dictionary Attacks section](https://keepass.info/help/base/security.html).

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
Bitwarden_2021-02-03_1210.kdbx //Once a week for the last two months
Bitwarden_2021-02-10_1755.kdbx
Bitwarden_2021-02-17_0900.kdbx
Bitwarden_2021-02-24_2134.kdbx
Bitwarden_2021-03-03_1210.kdbx //Once a day for the last two weeks
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
