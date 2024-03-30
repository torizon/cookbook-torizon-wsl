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
        cp /etc/bashrc.template /home/$_user/.bashrc

        # and pass the ownership of the home directory to the user
        chown -R ${_user}:$_user /home/$_user

        # configured, we need to have a way to tell to Windows this
        mkdir -p /mnt/c/Users/Public/.torizon
        touch /mnt/c/Users/Public/.torizon/.configured

        # the first configuration we exit for the wizard to finish
        exit 0
    } else {
        Write-Host -ForegroundColor Red "Error: User not added?"
        exit 69
    }
}

# start docker service ??
/usr/sbin/service docker status
if ($LASTEXITCODE -ne 0) {
    /usr/sbin/service docker start
}

# change the user
Set-Location /home/$_user
sudo -u $_user /bin/bash --noprofile -i

exit 0
