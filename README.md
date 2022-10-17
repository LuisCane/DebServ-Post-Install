# DebServ-post-install
Cat: General

NOTE: This script is no longer updated and is deprecated in favor of https://github.com/LuisCane/Debian-Post-Install which provides more features and combines the functinos of this script and the desktop post install script.
Script to perform common tasks after installation of Debian based servers

The script will perform the following tasks:
Part 1 - Update & Upgrade software and install vim
   apt
   firmware
   install vim
Part 2 - Change common settings
   Hostname
   SSH Keys
   edit bashrc and vimrc   
Part 3 - Set up Yubikey and PAM
Part 4 - Install Software
   Apt: See ./apps/apt-apps
Part 5 - Reminder of additional setup

Customize what apps are installed in the files within the ./apps/ directory.
To install CD into the master directory, ensure that the DevServ-post-install.sh is executable and run it.
