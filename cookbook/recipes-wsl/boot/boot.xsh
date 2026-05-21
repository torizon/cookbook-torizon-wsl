#!/usr/bin/xonsh

##
# Bootstrapping the Windows Subsystem for Linux (WSL)
# We use this script instead the [boot] section because
# it does not work on Windows 10 and below.
##

import os
import sys
import configparser
from torizon_templates_utils.colors import print,BgColor,Color
from torizon_templates_utils.errors import Error_Out, Error, last_return_code

# check if there already another user setup than root
# get all regular users
def get_user():
    user = None
    not_configured = True

    with open('/etc/passwd') as f:
        for line in f:
            fields = line.split(':')
            if fields[2] == '1000':
                user = fields[0]
                break

    # check if the file lock exists
    if os.path.exists('/usr/welcome/.user-configured'):
        not_configured = False

    return user, not_configured


# we already have a user???
_user, _no_configured = get_user()

if (_user is not None) and (_no_configured is True):
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

    echo @(f"{_user} ALL=(ALL) SETENV: NOPASSWD: /usr/bin/tdx-info") >> /etc/sudoers
    echo @(f"{_user} ALL=(ALL) SETENV: NOPASSWD: /opt/updater/updater.xsh") >> /etc/sudoers

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
    touch /usr/welcome/.user-configured

    # the first configuration we exit for the wizard to finish
    sys.exit(1)

elif _user is None:
    Error_Out(
        "Error: user not created",
        Error.ETOMCRUISE
    )


# start docker service ??
_ret = !(/usr/sbin/service docker status)
if last_return_code() != 0:
    print(f"Starting Docker service ...", bg_color=BgColor.BLUE, color=Color.WHITE)
    _ret = !(sudo /usr/sbin/service docker start)
    if last_return_code() != 0:
        print(f"Not possible to start Docker service", color=Color.RED)
    else:
        print(f"Docker service OK", color=Color.GREEN)
else:
    print(f"Docker service OK", color=Color.GREEN)

# still having controll to the flow
cd /home/@(_user)
