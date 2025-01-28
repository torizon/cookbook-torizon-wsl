#!/usr/bin/xonsh

from torizon_templates_utils.colors import print,BgColor,Color

# for now the only thing we need to do is to sync the pipenv
cd /opt/torizonver
pipenv sync

print("USER INIT DONE", color=Color.GREEN)
print("CONTINUING WITH THE BOOT CONFIGURATION", color=Color.YELLOW)
