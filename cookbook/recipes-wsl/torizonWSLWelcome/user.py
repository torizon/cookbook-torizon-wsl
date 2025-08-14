#!/usr/bin/env python3
"""Add the user login to the WSL distro"""

import re
import sys
import subprocess


def __is_valid_psswd(login_psswd):
    return bool(re.fullmatch(r'[^:\n]+', login_psswd))


def __is_valid_login(login_name):
    return bool(re.fullmatch(r'[a-z_][a-z0-9_-]{0,31}', login_name))


def __create_login(login_name, login_rep_psswd):
    # create the user
    subprocess.run(
        f"useradd -m {login_name} -p $(openssl passwd -1 {login_rep_psswd})",
        shell=True,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # run the specific init with the new user
    subprocess.run(
        f"su -c '/opt/specific_init.sh' {login_name}",
        shell=True,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )


if __name__ == "__main__":
    # check the arguments
    if len(sys.argv) != 3:
        print("Usage: ./user.py <login_name> <login_password>")
        sys.exit(69)

    l_name = sys.argv[1]
    l_psswd = sys.argv[2]

    if __is_valid_login(l_name) is False:
        print("Error: Invalid login name")
        sys.exit(69)

    if __is_valid_psswd(l_psswd) is False:
        print("Error: Invalid password")
        sys.exit(69)

    print("Creating the login please wait ...")
    __create_login(l_name, l_psswd)

    print("User created, ok")
    print("Configuring, please wait ...")

    sys.exit(0)
