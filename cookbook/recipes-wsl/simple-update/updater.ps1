#!/usr/bin/env pwsh

##
# Check if there is a new version
# then deploy the new files
##

$version = "v0.0.12-rc9"
$versionID = "0.0.12"

try {
    # 1. Check if there is a new version
    $latestData = Invoke-RestMethod -Uri `
        "https://api.github.com/repos/commontorizon/cookbook-torizon-wsl/releases"

    if ($version -eq $latestData[0].tag_name) {
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
        $_fileDeployParsed = $file.deploy -replace "%user%", $env:USER
        Invoke-WebRequest -Uri $file.file -OutFile $_fileDeployParsed

        # make sure to make the file in to the user's ownership
        chown $($env:USER):$($env:USER) $_fileDeployParsed
        # also that the file could be opened/written
        chmod ug+rw $_fileDeployParsed

        if ($file.exec -eq $true) {
            chmod +x $_fileDeployParsed
        }
    }

    # 4. Update the /etc/os-release
    $osRelease = Get-Content -Path /etc/os-release
    $osRelease = $osRelease -replace '(VERSION_ID=).*', "`${1}$versionID"
    $osRelease = $osRelease -replace '(VERSION=).*', "`${1}$versionID"
    $osRelease = $osRelease -replace '(VARIANT=).*', "`${1}`"Docker`""
    $osRelease | Set-Content -Path /etc/os-release
}
catch {
    Write-Host "An error occurred: $_"
}
