#!/usr/bin/xonsh

##
# Bootstrapping the Windows Subsystem for Linux (WSL)
# We use this script instead the [boot] section because
# it does not work on Windows 10 and below.
##

import os
import sys
import configparser
from torizon_templates_utils.errors import Error_Out, Error, last_return_code

# check if there already another user setup than root
# get all regular users
def get_user():
    user = None

    with open('/etc/passwd') as f:
        for line in f:
            fields = line.split(':')
            if fields[2] == '1000':
                user = fields[0]
                break

    return user


# we already have a user???
_user = get_user()


if _user is None:
    # no users found, create a new user
    cd /usr/welcome
    pipenv run python main.py

    # now we should have an user
    _user = get_user()

    if _user is not None:
        # add user to sudo group
        usermod -aG sudo @(_user)

        # docker config
        usermod -aG docker @(_user)

        # create the .bashrc
        cp /etc/bash.bashrc /home/@(_user)/.bashrc

        # make sure that /bin/sh is pointing to bash
        ln -sf /bin/bash /bin/sh

        # and pass the ownership of the home directory to the user
        chown -R @(_user):@(_user) /home/@(_user)

        # change the default shell to bash
        chsh -s /bin/bash @(_user)

        # add the /usr/sbin/service to the sudoers
        # we need this do be able to start docker without issues
        echo @(f"{_user} ALL=(ALL) SETENV: NOPASSWD: /usr/sbin/service") >> /etc/sudoers

        # add the /opt/telemetry/telemetry to the sudoers
        # TODO: telemetry
        # echo @(f"{_user} ALL=(ALL) SETENV: NOPASSWD: /opt/telemetry/telemetry") >> /etc/sudoers
        echo @(f"{_user} ALL=(ALL) SETENV: NOPASSWD: /usr/bin/tdx-info") >> /etc/sudoers
        echo @(f"{_user} ALL=(ALL) SETENV: NOPASSWD: /opt/updater/updater.xsh") >> /etc/sudoers
        echo @(f"{_user} ALL=(ALL) SETENV: NOPASSWD: /opt/torizon-emulator-manager/wslSocket") >> /etc/sudoers

        # vscode settings
        mkdir -p /home/@(_user)/.vscode-server/data/Machine
        cp /root/.vscode-server/data/Machine/settings.json /home/@(_user)/.vscode-server/data/Machine/settings.json

        # set the .vscode-server ownership to the user
        chown -R @(_user):@(_user) /home/@(_user)/.vscode-server
        # also set write permissions
        chmod -R ug+rw /home/@(_user)/.vscode-server

        # add the cap to ping
        chmod 4711 /usr/bin/ping
        setcap cap_net_raw+ep /usr/bin/ping

        # add the user to the /etc/wsl.conf
        _config = configparser.ConfigParser()
        _wslConf_raw = $(cat /etc/wsl.conf)
        _config.read_string(_wslConf_raw)

        _config['user']['default'] = _user
        rm -rf /etc/wsl.conf

        # write the /etc/wsl.conf back
        with open('/etc/wsl.conf', 'w') as _wslConf:
            _config.write(_wslConf)

        # configured, we need to have a way to tell to Windows this
        mkdir -p /mnt/c/Users/Public/.torizon
        touch /mnt/c/Users/Public/.torizon/.configured

        # the first configuration we exit for the wizard to finish
        sys.exit(1)
    else:
        Error_Out(
            "Error: User not added?",
            Error.ETOMCRUISE
        )


# start docker service ??
/usr/sbin/service docker status
if last_return_code() != 0:
    sudo /usr/sbin/service docker start

# still having controll to the flow
cd /home/@(_user)
