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

- [Quecto Project Gaia Core](https://github.com/quectoproject/gaia);

<p align="center">
    <img
        src="https://docs.toradex.com/114683-quectowithbackgroundsmall.png"
        alt="This is a Quecto Project based cookbook"
        width="200" />
    <img
        src="https://docs.toradex.com/114684-nostresslogosmall.png"
        alt="Torizon 💘 WSL 2"
        width="200" />
</p>

## Image Generated

### Testing Tricks

#### Set Login and Password

Is hard to automate tests for the configuration UI from the Windows side, so we have some tricks to help you test the configuration.

The configuration GUI will automatically set the login and password for you if you set a file under `c:\users\public\.torizon\password.txt` with the following content:

```txt
login:password
```

> ⚠️ **Warning**: This will be used only on the first boot of the Torizon Environment for WSL 2.

#### Debug installation

There is cases where the tester already have the Torizon Environment for WSL 2 installed and want to test a fresh installation. To do that, you can set the environment variable `DEBUG_INSTALLATION` to `1` before running the installer.

> ⚠️ **Warning**: This will only work if the user is installing the Torizon Environment for WSL 2 using the VS Code IDE wizard.
