#!/usr/bin/xonsh

##
# Check if there is a new version
# then deploy the new files
##

import hashlib
import json
import os
import requests
import shutil
import subprocess
import sys

def get_file_hash(file_path):
    sha256_hash = hashlib.sha256()
    with open(file_path, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()


MY_SHA = get_file_hash("/opt/updater/updater.xsh")


try:
    # 1. Check if there is a new version
    response = requests.get("https://api.github.com/repos/torizon/cookbook-torizon-wsl/releases")
    latest_data = response.json()

    if version == latest_data[0]['tag_name']:
        print("No new version available")
        sys.exit(0)

    # 2. Get the list of files to download
    response = requests.get("https://raw.githubusercontent.com/torizon/cookbook-torizon-wsl/main/cookbook/recipes-wsl/simple-update/files")
    files = response.json()

    # 3. Download the files and deploy them
    for file in files['update']:
        print(f"Downloading :: {file['file']}")

        # parse the %user% to the actual user
        file_deploy_parsed = file['deploy'].replace("%user%", User)
        response = requests.get(file['file'])
        with open(file_deploy_parsed, 'wb') as f:
            f.write(response.content)

        # make sure to make the file in to the user's ownership
        shutil.chown(file_deploy_parsed, user=User)
        # also that the file could be opened/written
        os.chmod(file_deploy_parsed, 0o664)

        if file['exec']:
            os.chmod(file_deploy_parsed, 0o775)

        # check if the file is itself
        if file['deploy'] == "/opt/updater/updater.xsh":
            # is different from the current file ?
            new_sha = get_file_hash("/opt/updater/updater.xsh")

            if MY_SHA != new_sha:
                print("The updater script has been updated, restarting the script")
                subprocess.run(["pwsh", "-File", file_deploy_parsed, "-User", User, "-version", version, "-versionID", versionID])
                sys.exit(0)

        # check if the file should be executed as run updater script
        if file['run']:
            print(f"Running :: {file_deploy_parsed}")
            subprocess.run(["bash", "-f", file_deploy_parsed], check=False)

    # 4. install the dep packages
    response = requests.get("https://raw.githubusercontent.com/commontorizon/cookbook-torizon-wsl/main/cookbook/recipes-wsl/simple-update/packages")
    dep_packages = response.json()

    for package in dep_packages['packages']:
        print(f"Installing :: {package}")
        subprocess.run(["apt-get", "install", "-y", package])

    # 5. Update the /etc/os-release
    with open("/etc/os-release", "r") as f:
        os_release = f.read()

    os_release = re.sub(r'(VERSION_ID=).*', f"\\1{versionID}", os_release)
    os_release = re.sub(r'(VERSION=).*', f"\\1{versionID}", os_release)
    os_release = re.sub(r'(VARIANT=).*', r'\\1"Docker"', os_release)

    with open("/etc/os-release", "w") as f:
        f.write(os_release)

except Exception as e:
    print(f"An error occurred: {e}")
