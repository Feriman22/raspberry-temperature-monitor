# Raspberry Temperature Monitor

## Description

Do you know the command to check the actual temperature of your Raspberry? Me neither. I created this script to solve this problem.

## Installation

1. Download the script from GitHub:
>*wget https://raw.githubusercontent.com/Feriman22/raspberry-temperature-monitor/rpi-temp-monitor.sh*
2. Add execute permission:
>*chmod +x ./rpi-temp-monitor.sh*
3. Install the script:
>*sudo ./rpi-temp-monitor.sh --install*

If you run it without any argument, you have 5 options:
1. Portable (any user)
2. Install (root only)
3. Uninstall (root only)
4. Update (root only)
5. Quit

Choose `portable` option to run the Raspberry Temperature Monitor without installation. Every user can run the script in portable mode, no root permission required.

The `install` process will copy the script in */usr/local/sbin* folder, then create a new file */etc/profile.d/rpi-temp-monitor*. It required to use the *temp* alias to run the script easily.

The `uninstall` process remove the script from */usr/local/sbin* folder, remove the file */etc/profile.d/rpi-temp-monitor*.
**WARNING!** You cannot run this script again after this step from */usr/local/sbin* folder and with *temp* alias.

The `update` process will update the installed script. You cannot update it before install!

## Daily use

Type *temp* in command line if the script has been installed. If not yet, you can run it as portable.

Available arugments:

-p, --portable\
  Run the script in portable mode

-i, --install\
  Install the script

-u, --uninstall\
  Uninstall the script without confirmation
  
--update\
  Update the script

## How to update

Run the script and choose "Update" or run with --update argument.

## The future

- Release the script :) Soon...

## Changelog

>25-04-2020
- Initial release

## Do not forget

If you found it useful, **please donate me via PayPal** and I can improve & fix bugs or develop another awesome scripts! (:
[paypal.me/BajzaFerenc](https://www.paypal.me/BajzaFerenc)
