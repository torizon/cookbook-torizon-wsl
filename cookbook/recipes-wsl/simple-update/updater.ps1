#!/usr/bin/env pwsh

##
# Check if there is a new version
# then deploy the new files
##

$version = "v0.0.10-rc7"

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
        Invoke-WebRequest -Uri $file.file -OutFile $file.deploy

        if ($file.exec -eq $true) {
            chmod +x $file.deploy
        }
    }
}
catch {
    Write-Host "An error occurred: $_"
}
