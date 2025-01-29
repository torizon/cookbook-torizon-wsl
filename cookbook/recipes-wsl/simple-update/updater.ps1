#!/usr/bin/env pwsh

param(
    [string]$User,
    [string]$version="v0.0.19",
    [string]$versionID="0.0.19"
)

##
# Check if there is a new version
# then deploy the new files
##

$MY_SHA = Get-FileHash -Path "/opt/updater/updater.ps1"

try {
    # 1. Check if there is a new version
    $latestData = Invoke-RestMethod -Uri `
        "https://api.github.com/repos/commontorizon/cookbook-torizon-wsl/releases"

    # this updater, or Torizon Development Environment for WSL v0 shoul not be
    # able to update to v1
    if (
        $version -eq $latestData[0].tag_name -or
        [int]::Parse($latestData[0].tag_name[1]) -gt 0
    ) {
        Write-Host "No new version available"
        exit 0
    }

    # 2. Get the list of files to download
    $reqFiles = Invoke-WebRequest -Uri `
        "https://raw.githubusercontent.com/commontorizon/cookbook-torizon-wsl/main/cookbook/recipes-wsl/simple-update/files"
    $files = $reqFiles.Content | ConvertFrom-Json

    # 3. Download the files and deploy them
    foreach ($file in $files.update) {
        Write-Host "Downloading :: $($file.file)"

        # parse the %user% to the actual user
        $_fileDeployParsed = $file.deploy -replace "%user%", $User
        Invoke-WebRequest -Uri $file.file -OutFile $_fileDeployParsed

        # make sure to make the file in to the user's ownership
        chown $User $_fileDeployParsed
        # also that the file could be opened/written
        chmod ug+rw $_fileDeployParsed

        if ($file.exec -eq $true) {
            chmod +x $_fileDeployParsed
        }

        # check if the file is itself
        if ($file.deploy -eq "/opt/updater/updater.ps1") {
            # is different from the current file ?
            $_new_sha = Get-FileHash -Path "/opt/updater/updater.ps1"

            if ($MY_SHA.Hash -ne $_new_sha.Hash) {
                Write-Host "The updater script has been updated, restarting the script"
                pwsh -File $_fileDeployParsed `
                        -User $User `
                        -version $version `
                        -versionID $versionID
                exit 0
            }
        }

        # check if the file should be executed as run updater script
        if ($file.run -eq $true) {
            Write-Host "Running :: $($_fileDeployParsed)"
            bash -f $_fileDeployParsed || true
        }
    }

    # 4. install the dep packages
    $reqPackages = Invoke-WebRequest -Uri `
        "https://raw.githubusercontent.com/commontorizon/cookbook-torizon-wsl/main/cookbook/recipes-wsl/simple-update/packages"
    $depPackages = $reqPackages.Content | ConvertFrom-Json

    foreach ($package in $depPackages.packages) {
        Write-Host "Installing :: $($package)"
        apt-get install -y $package
    }

    # 5. Update the /etc/os-release
    $osRelease = Get-Content -Path /etc/os-release
    $osRelease = $osRelease -replace '(VERSION_ID=).*', "`${1}$versionID"
    $osRelease = $osRelease -replace '(VERSION=).*', "`${1}$versionID"
    $osRelease = $osRelease -replace '(VARIANT=).*', "`${1}`"Docker`""
    $osRelease | Set-Content -Path /etc/os-release

    # 5. Clean the telemetry.lock file
    rm -rf /tmp/telemetry.lock
}
catch {
    Write-Host "An error occurred: $_"
}
