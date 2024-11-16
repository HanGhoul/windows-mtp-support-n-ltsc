param (
    [string]$MsuFile,   # File path to the 'Windows_MediaFeaturePack_x64_1903_V1.msu' file
    [string]$CabFolder, # Folder path to the unpacked 'microsoft-windows-mediafeaturepack-oob-package~31bf3856ad364e35~amd64~~.cab'
    [switch]$Patch      # Install packages
)

# Check if the script is running with elevated privileges
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isElevated) {
    Write-Host "This script must be run as an administrator to apply patches."
    exit
}

# Ensure that either $MsuFile or $CabFolder is provided, but prefer $CabFolder if both are given
if ($MsuFile -and $CabFolder) {
    Write-Host "Both MsuFile and CabFolder are provided. Using CabFolder."
    $MsuFile = $null  # Clear the $MsuFile variable if both are given, fallback to $CabFolder
}

# Validate that one of the parameters is provided
if (-not $CabFolder -and -not $MsuFile) {
    Write-Host -ForegroundColor Red "Error: Either -MsuFile or -CabFolder must be provided."
    exit 1
}

# Get the drive where $env:TEMP is located
$drive = (Get-Item -Path $env:TEMP).PSDrive

# Get free space on that drive in MB
$freeSpaceMB = [math]::Round($drive.Free/1MB)

# Check if the free space is greater than or equal to 500 MB
if ($freeSpaceMB -lt 500) {
    Write-Host -ForegroundColor Red "Not enough free disk space on $drive`: ($freeSpaceMB MB). At least 500 MB is required."
    exit 1
}

# Process MsuFile if provided
if ($MsuFile) {
    if (-not (Test-Path $MsuFile -PathType Leaf)) {
        Write-Host -ForegroundColor Red "Error: MsuFile does not exist or is not a valid file."
        exit 1
    }

    Write-Host -ForegroundColor Green "MsuFile provided: ""$MsuFile""`n"

    try {
        # Define directory to extract the MSU file to
        $MsuFolder = [System.IO.Path]::Combine($env:TEMP, "mtp-install")
        Write-Host "Extracting MSU file ""$MsuFile""`n  to ""$MsuFolder"""

        if (-not (Test-Path $MsuFolder)) {
            New-Item -ItemType Directory -Path $MsuFolder | Out-Null
            Write-Host "Created directory: ""$MsuFolder"""
        }
        expand $MsuFile -F:* $MsuFolder | Out-Null
        Write-Host "MSU extraction complete. Files are located at ""$MsuFolder""`n"
    } catch {
        Write-Host -ForegroundColor Red "Error: Failed to expand MSU file."
        exit 1
    }

    $CabFile = [System.IO.Path]::Combine($MsuFolder, "microsoft-windows-mediafeaturepack-oob-package~31bf3856ad364e35~amd64~~.cab")
    if (-not (Test-Path $CabFile -PathType Leaf)) {
        Write-Host -ForegroundColor Red "Error: CAB file does not exist or is not a valid file."
        exit 1
    }


    try {
        # Define directory to extract the CAB file to
        $CabFolder = [System.IO.Path]::Combine($env:TEMP, "$MsuFolder\cab-extracted")
        Write-Host "Extracting CAB file ""$CabFile""`n  to ""$CabFolder"""

        if (-not (Test-Path $CabFolder)) {
            New-Item -ItemType Directory -Path $CabFolder | Out-Null
            Write-Host "Created directory: ""$CabFolder"""
        }
        expand $CabFile -F:* $CabFolder | Out-Null
        Write-Host "CAB extraction complete. Files are located at ""$CabFolder""`n"
    } catch {
        Write-Host -ForegroundColor Red "Error: Failed to extract CAB file."
        exit 1
    }
}

# Ensure that $CabFolder exists and is a folder
if ($CabFolder) {
    if (-not (Test-Path $CabFolder -PathType Container)) {
        Write-Host -ForegroundColor Red "Error: CabFolder does not exist or is not a valid folder."
        exit 1
    }

    Write-Host -ForegroundColor Green "CabFolder provided: ""$CabFolder""`n"

    # Define the file patterns with regex for matching
    $filePatterns = @(
        "Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~~10\.0\.\d{5}\.1\.mum",
        "Microsoft-Windows-Portable-Devices-multimedia-Package~31bf3856ad364e35~amd64~de-DE~10\.0\.\d{5}\.1\.mum",
        "Microsoft-Windows-Portable-Devices-Package~31bf3856ad364e35~amd64~~10\.0\.\d{5}\.1\.mum"
    )

    # Initialize an array to store matched files
    $matchedFiles = @()

    # Search for .mum files in the specified directory
    $files = Get-ChildItem -Path $CabFolder -Recurse -File -Filter "*.mum"

    # Loop through each file and match against the patterns
    foreach ($file in $files) {
        foreach ($pattern in $filePatterns) {
            if ($file.Name -match $pattern) {
                # Add matching file's full path to the array
                $matchedFiles += $file.FullName
                break
            }
        }
    }

    if ($Patch) {
        # Check if the number of matched files is 3
        if ($matchedFiles.Count -eq 3) {
            Write-Host "Found required files, proceeding install:"
            $matchedFiles | ForEach-Object { Write-Host "- $_" }

            foreach ($file in $matchedFiles) {
                $command = "dism /online /add-package /packagepath:`"$file`" /NoRestart"
                Write-Host -ForegroundColor Cyan "`nRunning command: ""$command"""
                Invoke-Expression $command
            }

            Write-Host -ForegroundColor Green "`nPatching completed."
            $patched = $true
        } else {
            Write-Host "The number of matched files is $($matchedFiles.Count) but expected 3. Something's wrong, skipping install."
        }
    } else {
        $matchedFiles | ForEach-Object { Write-Host "Found file: $_" }
        Write-Host -ForegroundColor Yellow "-Patch switch not provided, skipping install."
    }

    # Clean up extracted files
    if ($MsuFile) {
        Write-Host "Cleaning up extracted MSU & CAB folders: ""$MsuFolder"""
        Remove-Item -Path $MsuFolder -Recurse -Force
    }

    if ($patched) {
        # Ask the user if they want to reboot
        $rebootChoice = Read-Host "Do you want to reboot now? (y/n)"

        if ($rebootChoice -ieq 'y') {
            Write-Host "Rebooting..."
            Restart-Computer
        } else {
            Write-Host -ForegroundColor Yellow "Please reboot your system to apply the changes."
        }
    }
}
