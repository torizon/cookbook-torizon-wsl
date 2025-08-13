"""Add the user login to the WSL distro"""

import os
import sys
import subprocess


def __automated_login() -> tuple[str, str] |  None:
    _automated_ok = False
    _automated_login_path = "/mnt/c/Users/Public/.torizon/password.txt"

    # for WSL
    if os.path.exists("/mnt/c/Users/Public/.torizon/password.txt"):
        _automated_ok = True
    if os.path.exists("./.conf/password.txt"):
        _automated_ok = True
        _automated_login_path = "./.conf/password.txt"

    if _automated_ok:
        with open(_automated_login_path, "r", encoding="utf-8") as file:
            content = file.read()
            login_name, login_rep_psswd = content.split(':')

            return login_name, login_rep_psswd

    return None


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
    print("Creating the login please wait ...")
    login_info = __automated_login()

    if login_info:
        l_name, l_psswd = login_info
        __create_login(l_name, l_psswd)

        print("User created, ok")
        print("Configuring, please wait ...")

        sys.exit(0)
    else:
        sys.exit(69)
