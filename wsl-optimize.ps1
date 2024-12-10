# Define the log directory and log file
$LogDirectory = "$env:USERPROFILE\WSL_Optimize_Logs"
$LogFile = "$LogDirectory\optimize_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

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
        BasePath         = $Props | Where-Object { $_.Name -eq "BasePath" } | Select-Object -ExpandProperty Value
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
        
        Log-Message "Selected WSL distribution: '$SelectedDistribution'"

        # Find information about the selected distribution
        $SelectedWSL = $WSLInfo | Where-Object { $_.DistributionName -eq $SelectedDistribution }
        $BasePath = $SelectedWSL.BasePath.Replace("\\?\", "") # Remove the prefix \\?\
        
        # Check if the VHDX file exists in the BasePath
        $VhdxPath = Join-Path -Path $BasePath -ChildPath "ext4.vhdx"
        Log-Message "VHDX path for distribution '$SelectedDistribution' is '$VhdxPath'"

        if (Test-Path -Path $VhdxPath -PathType Leaf) {
            try {
                # Get the size of the VHDX file before optimization
                $OriginalSize = (Get-Item $VhdxPath).Length
                Log-Message ("Original size of VHDX: {0:N2} GB" -f ($OriginalSize / 1GB))

                # Perform optimization for the VHDX file
                $OptimizeCommand = "optimize-vhd -Path $VhdxPath -Mode full"
                Invoke-Expression -Command $OptimizeCommand
                Log-Message "Optimization of VHDX for distribution '$SelectedDistribution' completed successfully."

                # Get the size of the VHDX file after optimization
                $OptimizedSize = (Get-Item $VhdxPath).Length
                Log-Message ("New optimized size of VHDX is: {0:N2} GB" -f ($OptimizedSize / 1GB))
            } catch {
                Log-Message "An error occurred during optimization: $_" "ERROR"
            }
        } else {
            Log-Message "VHDX file for distribution '$SelectedDistribution' was not found in the path $VhdxPath." "ERROR"
        }
    } else {
        Log-Message "Invalid selection. Please enter a valid number." "ERROR"
    }
} else {
    Log-Message "Invalid input. Please enter a number." "ERROR"
}
