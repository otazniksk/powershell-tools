WSL Distribution Optimizer
==========================

This PowerShell script helps you optimize VHDX files for your installed WSL (Windows Subsystem for Linux) distributions.

Prerequisites
-------------

- Windows 10 or Windows 11 with WSL 2 enabled.
- Windows PowerShell (or PowerShell Core).
- Administrative privileges (if needed for VHDX file access).

Usage
-----

1. Open a PowerShell terminal.

2. Run the `Optimize-WSL.ps1` script:

   ```powershell
   .\wsl-optimize.ps1
   ```
3. The script will display a list of available WSL distributions:

    ```powershell
    Available WSL Distributions:
    [1] Ubuntu
    [2] Debian
    [3] Fedora
    ```
4. Enter the number corresponding to the WSL distribution you want to optimize and press Enter.

5. The script will perform the following steps:

    - Find the VHDX file associated with the selected distribution.
    - Display the original size of the VHDX file in gigabytes (GB).
    - Optimize the VHDX file using the optimize-vhd command with "full" mode.
    - Display the new optimized size of the VHDX file in GB.

6. The optimization process is complete, and your selected WSL distribution's VHDX file is now optimized.

## Troubleshooting

If you encounter errors or issues during the optimization process, please check the error messages for more information.

    - Make sure you have administrative privileges if the script requires them for VHDX file access.
    - Ensure that the VHDX file for the selected distribution exists in the specified path.

## License
This script is provided under the MIT License. See LICENSE for more information.