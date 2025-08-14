# Torizon Environment for WSL 2 Cookbook

<p align="center">
    <img
        src="https://docs.toradex.com/114682-torizonloveswsl2512.png?v=1"
        alt="Torizon 💘 WSL 2"
        width="200" />
</p>

This cookbook provides a collection of recipes to help you get started with Torizon on Windows Subsystem for Linux 2 (WSL 2).

This was especially designed for have an already set up development environment for [Torizon](https://www.torizon.io/) and the [Torizon IDE Extension for Visual Studio Code](https://developer.toradex.com/torizon/application-development/ide-extension/) in an easy way.

## Prerequisites

- [Gaia project Gaia Core](https://github.com/gaiaBuildSystem/gaia);

<p align="center">
    <img
        src="https://github.com/gaiaBuildSystem/.github/raw/main/profile/GaiaBuildSystemLogoDebCircle.png"
        alt="This is a Gaia Project based cookbook"
        width="170" />
</p>

## Build an Image

```bash
./gaia/scripts/bitcook/gaia.ts --buildPath /home/user/workdir --distro ./cookbook-torizon-wsl/distro-<arch>.json
```

## Image Generated

### Testing Tricks

#### Installing

Supposing that the path for the creation of the VM `.vhdx` is the same where the `.tar` is located:

```bash
wsl --import TorizonTest . ./wsl-amd64-1-0-2.img.tar --version 2
```

#### Set Login and Password

The WSL Torizon distro was not designed to be used without the Torizon IDE Extension. The flow of configuring a non root login during the first boot is implemented on the IDE side. For tests puposes the `/usr/welcome/user.py` can be used directly:

```bash
wsl -d TorizonTest /usr/welcome/user.py test test-secure-password
```

Where user will be `test` and password will be `test-secure-password`. After this run the WSL distro:

```bash
wsl -d TorizonTest
```

This ran, after the ran of the `/usr/welcome/user.py` will then configure the boot flow to use the new user created. The next calls then will be ok to be used as normal WSL distro.

#### Debug installation

There is cases where the tester already have the Torizon Environment for WSL 2 installed and want to test a fresh installation. To do that, you can set the environment variable `DEBUG_INSTALLATION` to `1` before running the installer.

> ⚠️ **Warning**: This will only work if the user is installing the Torizon Environment for WSL 2 using the VS Code IDE wizard.
