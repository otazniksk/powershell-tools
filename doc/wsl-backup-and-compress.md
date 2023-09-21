# WSL Backup and Compress Script

This script allows you to backup your WSL2 virtual disks using native functions and compress them using 7-Zip. It helps you manage and maintain backups of your WSL distributions easily.

## Inspiration
This script is inspired by [Will Presley's Gist](https://gist.github.com/WillPresley/e662e07fa966de41de7e045b2bf05ff7).

## Usage

### Prerequisites
Before using this script, ensure you have the following:

- Windows Subsystem for Linux 2 (WSL2) installed.
- 7-Zip installed (`7z.exe` should be available in `$env:ProgramFiles\7-Zip\`).

### Parameters
The script accepts the following parameters:

- `BackupDirectory` (Required): The path to the directory where backups will be stored.
- `BackupsToKeep` (Optional, Default: 6): The number of backup files to keep. Older backups will be deleted to maintain this count.

### Instructions

1. Download and save the `wsl-backup-and-compress.ps1` script to your desired location.

2. Open a PowerShell terminal with administrator privileges.

3. Run the script with the required parameters:

   ```powershell
   .\wsl-backup-and-compress.ps1 -BackupDirectory C:\YourBackupDirectory
   ```

Replace `C:\YourBackupDirectory` with the path to the directory where you want to store backups.

4. The script will list available WSL distributions. Enter the number corresponding to the distribution you want to back up.

5. The script will create a backup of the selected WSL distribution, compress it using 7-Zip with maximum compression, and keep the specified number of backup files.

6. The compressed backup files will be saved in the specified `BackupDirectory`.

7. Older backups beyond the specified count will be automatically deleted.

## Example

Here's an example command to run the script:

    ```powershell
    .\wsl-backup-and-compress.ps1 -BackupDirectory C:\WSLBackups -BackupsToKeep 10
    ```
This will back up the selected WSL distribution to the `C:\WSLBackups` directory and maintain the 10 most recent backups.

## Note
- Make sure to regularly review and manage your backups to avoid running out of disk space.
- You can schedule this script to run periodically using Windows Task Scheduler for automated backups.

## License
This script is provided under the MIT License. Feel free to modify and use it according to your needs.

If you encounter any issues or have suggestions for improvement, please [submit an issue](https://github.com/your-repository/issues) on GitHub.