#!/usr/bin/env pwsh

##
# Bootstrapping the Windows Subsystem for Linux (WSL)
# We use this script instead the [boot] section because
# it does not work on Windows 10 and below.
##

# check if there already another user setup than root
# get all regular users
function Get-User {
    $user = $null
    $user = Get-Content /etc/passwd | ForEach-Object {
        $fields = $_.Split(':')
        if ($fields[2] -eq 1000) {
            $fields[0]
        }
    }

    return $user
}

$_user = Get-User

if ($null -eq $_user) {
    $env:WAYLAND_DISPLAY=$null
    # no users found, create a new user
    Set-Location /usr/welcome
    ./torizonWSLWelcome

    $_user = Get-User
    if ($null -ne $_user) {
        # add user to sudo group
        usermod -aG sudo $_user

        # docker config
        usermod -aG docker $_user

        # create the .bashrc
        cp /etc/bash.bashrc /home/$_user/.bashrc

        # make sure that /bin/sh is pointing to bash
        ln -sf /bin/bash /bin/sh

        # and pass the ownership of the home directory to the user
        chown -R ${_user}:$_user /home/$_user

        # change the default shell to bash
        chsh -s /bin/bash $_user

        # add the /usr/sbin/service to the sudoers
        # we need this do be able to start docker without issues
        Write-Output "$_user ALL=(ALL) SETENV: NOPASSWD: /usr/sbin/service" >> /etc/sudoers

        # add the /opt/telemetry/telemetry to the sudoers
        Write-Output "$_user ALL=(ALL) SETENV: NOPASSWD: /opt/telemetry/telemetry" >> /etc/sudoers
        Write-Output "$_user ALL=(ALL) SETENV: NOPASSWD: /usr/bin/tdx-info" >> /etc/sudoers
        Write-Output "$_user ALL=(ALL) SETENV: NOPASSWD: /opt/updater/updater.ps1" >> /etc/sudoers
        Write-Output "$_user ALL=(ALL) SETENV: NOPASSWD: /opt/torizon-emulator-manager/wslSocket" >> /etc/sudoers

        # vscode settings
        mkdir -p /home/$_user/.vscode-server/data/Machine
        cp /root/.vscode-server/data/Machine/settings.json /home/$_user/.vscode-server/data/Machine/settings.json

        # add the cap to ping
        chmod 4711 /usr/bin/ping
        setcap cap_net_raw+ep /usr/bin/ping

        # add the user to the /etc/wsl.conf
        Install-Module -Name PsIni -Force
        Import-Module PsIni
        $_wslConf = Get-IniContent /etc/wsl.conf
        $_wslConf['user'].default = $_user
        Remove-Item -Force /etc/wsl.conf
        $_wslConf | Out-IniFile -FilePath /etc/wsl.conf

        # configured, we need to have a way to tell to Windows this
        mkdir -p /mnt/c/Users/Public/.torizon
        touch /mnt/c/Users/Public/.torizon/.configured

        # the first configuration we exit for the wizard to finish
        exit 1
    } else {
        Write-Host -ForegroundColor Red "Error: User not added?"
        exit 69
    }
}

# start docker service ??
/usr/sbin/service docker status
if ($LASTEXITCODE -ne 0) {
    sudo /usr/sbin/service docker start
}

# still having controll to the flow
Set-Location /home/$_user
