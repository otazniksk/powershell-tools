# Backup WSL2 virtual disks using native functions and compress them using 7zip
## Inspirated Will Presley https://gist.github.com/WillPresley/e662e07fa966de41de7e045b2bf05ff7

param (
    [string]$BackupDirectory,
    [int]$BackupsToKeep = 6
)

# Define the log directory and log file
$LogDirectory = "$BackupDirectory\Logs"
$LogFile = "$LogDirectory\backup_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Function to log messages
function Log-Message {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Type] $Message"
    Write-Output $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

# Create the log directory if it doesn't exist
if (-not (Test-Path -Path $LogDirectory -PathType Container)) {
    New-Item -Path $LogDirectory -ItemType Directory | Out-Null
}

# Check if the $BackupDirectory parameter is provided
if (-not $BackupDirectory) {
    Log-Message "BackupDirectory is a required parameter. Please provide a valid directory path, e.g., C:\Backup." "ERROR"
    return
}

# Check if the specified directory exists
if (-not (Test-Path -Path $BackupDirectory -PathType Container)) {
    Log-Message "The specified directory '$BackupDirectory' does not exist." "ERROR"
    return
}

# Define the registry path where information about WSL installations is stored
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"

# Get all subkeys in the specified registry key
$Subkeys = Get-ChildItem -Path $RegistryPath -Recurse | Where-Object { $_.PSIsContainer }

# Iterate through all subkeys and retrieve their values containing WSL installation paths
$WSLInfo = foreach ($Subkey in $Subkeys) {
    $Props = $Subkey.GetValueNames() | ForEach-Object {
        $PropName = $_
        $PropValue = $Subkey.GetValue($_)
        [PSCustomObject]@{
            Name  = $PropName
            Value = $PropValue
        }
    }
    [PSCustomObject]@{
        DistributionName = $Props | Where-Object { $_.Name -eq "DistributionName" } | Select-Object -ExpandProperty Value
    }
}

# Get a list of available distributions
$AvailableDistributions = $WSLInfo | Select-Object -ExpandProperty DistributionName

# Display a menu with available distributions and wait for user input
Write-Host "Available WSL Distributions:"
for ($i = 0; $i -lt $AvailableDistributions.Count; $i++) {
    Write-Host "[$($i + 1)] $($AvailableDistributions[$i])"
}

# Get user input
$Selection = Read-Host "Select a WSL Distribution (enter the number)"
# Check if the input is valid and select the distribution based on the input
if ([int]::TryParse($Selection, [ref]$null)) {
    $SelectedIndex = [int]$Selection - 1
    if ($SelectedIndex -ge 0 -and $SelectedIndex -lt $AvailableDistributions.Count) {
        $SelectedDistribution = $AvailableDistributions[$SelectedIndex]

        Log-Message "Selected WSL '$SelectedDistribution' distribution"

        #### http://mats.gardstad.se/matscodemix/2009/02/05/calling-7-zip-from-powershell/ 
        # Alias for 7-zip
        if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {
            Log-Message "$env:ProgramFiles\7-Zip\7z.exe needed" "ERROR"
            throw "$env:ProgramFiles\7-Zip\7z.exe needed"
        }
        set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
        #### Alternative native PS 7-zip: https://www.sans.org/blog/powershell-7-zip-module-versus-compress-archive-with-encryption/

        ################### Variables ###################
        $currentDate = (Get-Date).ToString('yyyy-MM-dd')
        #$BackupDirectory = "./wsl-backup-and-compress.ps1 -BackupDirectory D:\wsl2-custom\backupDir"
        #$BackupDirectory = "X:\{{ENTER_DIRECTORY_STRUCTURE_HERE}}"
        #$BackupsToKeep = 6
        $filePath = -join("$BackupDirectory", "\", "$SelectedDistribution", "_", "$currentDate", ".tar")
        ################ End of Variables ###############

        try {
            ## Run the export to get the .tar file
            wsl --export "$SelectedDistribution" "$filePath"
            Log-Message "Exported WSL distribution '$SelectedDistribution' to '$filePath'"

            ## Let's compress it using 7zip and max compression, and use -sdel to delete the original file after successful compression
            sz a -t7z -mx=9 -sdel "$filePath.7z" "$filePath"
            Log-Message "Compressed '$filePath' to '$filePath.7z' using 7zip"

            ## Let's remove everything except the last X backups (X month history)
            gci "$BackupDirectory" -Recurse| where{-not $_.PsIsContainer} | sort LastWriteTime -desc | select -Skip $BackupsToKeep | Remove-Item -Force
            Log-Message "Removed old backups, keeping the last $BackupsToKeep backups"
        } catch {
            Log-Message "An error occurred: $_" "ERROR"
        }
    } else {
        Log-Message "Invalid selection. Please enter a valid number." "ERROR"
    }
} else {
    Log-Message "Invalid input. Please enter a number." "ERROR"
}
