#!/bin/bash

#Common Setup after installing PopOS.
#Part 1 - Update & Upgrade software and install vim
#   apt
#   firmware
#   install vim
#Part 2 - Change common settings
#   Hostname
#   SSH Keys
#   edit .bashrc
#   
#Part 3 - Set up Yubikey and PAM
#Part 4 - Install Software
#   Apt:
#       neofetch
#       openssh-server
#Part 5 - Reminder of additional setup   

Greeting () {
    printf '\nHello!'
    sleep 1s
    printf '\nWelcome to my post installation script for Pop!_OS'
    sleep 1s
    printf '\nIt is not recommended that you run scripts that you find on the internet without knowing exactly what they do.\n\n
This script contains functions that require root privilages.\n'
    sleep 3s
    while true; do
        read -p $'Do you wish to proceed? [y/N]' yn
        yn=${yn:-N}
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo 'Please answer yes or no.';;
        esac
    done
}
#Update and Upgrade system packages
Update () {
    while true; do
        read -p $'Would you like to update the repositories? [Y/n]' yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) sudo apt update; check_exit_status; break;;
            [Nn]* ) break;;
            * ) echo 'Please answer yes or no.';;
        esac
    done
    while true; do
        read -p $'Would you like to upgrade the software? [Y/n]' yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) apt-pkg-upgrade;
                    check_exit_status;;
            [Nn]* ) break;;
            * ) echo 'Please answer yes or no.';;
        esac
    done
    while true; do
        read -p $'Would you like to update the firmware? [Y/n]' yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) sudo fwupdmgr get-devices;
                    check_exit_status;
                    sudo fwupdmgr get-updates;
                    check_exit_status;
                    return 0;;
            [Nn]* ) break;;
            * ) echo 'Please answer yes or no.';;
        esac
    done
}
#upgrade Apt Packages
apt-pkg-upgrade () {
    printf '\nsudo apt -y upgrade\n'
    sudo apt -y upgrade --allow-downgrades;
    check_exit_status
    printf '\nsudo apt -y dist-upgrade\n'
    sudo apt -y dist-upgrade;
    check_exit_status
    printf '\nsudo apt -y autoremove\n'
    sudo apt -y autoremove;
    check_exit_status
    printf '\nsudo apt -y autoclean\n'
    sudo apt -y autoclean;
    check_exit_status
}
#Install VIM
InstallVIM () {
    printf '\nWould you like to install VIM?\n'
    read -r yn
    case $yn in
        [Yy]* ) printf '\nInstalling VIM\n'
                sudo apt install -y vim
                ;;
        [Nn]* ) printf '\nSkipping VIM'
                ;;
            * ) printf '\nPlease enter yes or no.\n'
                ;;
    esac
}
#Change System Hostname
ChHostname () {
    while true; do
        printf "\nYour System Hostname is $HOSTNAME \n"
        read -p $'Would you like to change the hostname? [y/N]' yn
        yn=${yn:-N}
        case $yn in
            [Yy]* ) read -p "Please enter a new Hostname: " NEWHOSTNAME;
                    sudo hostnamectl set-hostname $NEWHOSTNAME
                    return 0;;
            [Nn]* ) echo
                    printf '\nHostname %s will not be changed.\n' $HOSTNAME ;
                    break;;
            * ) echo 'Please answer yes or no.';;
        esac
    done
}
#Generate SSH Key with comment
SSHKeyGen () {
    while true; do
        read -p $'Would you like to generate an SSH key? [Y/n]' yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) read -p "Please enter a type [RSA/dsa]: " keytype;
                    keytype=${keytype:-RSA}
                    read -p "Please enter a modulus [4096]: " modulus;
                    modulus=${modulus:-4096}
                    read -p "Enter a comment to help identify this key [$USER @ $HOSTNAME]: " keycomment;
                    keycomment=${keycomment:-$USER @ $HOSTNAME}
                    read -p "Enter an output file [$HOME/.ssh/$USER\_rsa]: " outfile;
                    outfile=${outfile:-$HOME/.ssh/$USER\_rsa}
                    ssh-keygen -t $keytype -b $modulus -C "$keycomment" -f $outfile;
                    return 0;;
            [Nn]* ) printf '\nSSH Key Not generated\n';
                    break;;
            * ) echo 'Please answer yes or no.';;
        esac
    done
}
#Copy bashrc and vimrc to home folder
CPbashrc () {
    while true; do 
        read -p 'Would you like to copy the bashrc file included with this script to your home folder? [Y/n]' yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) cp ./home/user/bashrc ~/.bashrc;;
            [Nn]* ) printf '\nOK\n'
                    break;;
                * ) echo 'Please answer yes or no.';;
        esac
    done
}
CPvimrc ()  {
    while true; do 
    read -p 'Would you like to copy the vimrc file included with this script to your home folder? [Y/n]' yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) cp ./home/user/vimrc ~/.vimrc
                    break;;
            [Nn]* ) printf '\nOK\n'
                    break;;
                * ) echo 'Please answer yes or no.';;
        esac
    done
}
#Set up Yubikey authentication
ConfigYubikeys () {
    while true; do
        read -p $'Would you like to set up Yubikey authentication? [Y/n]' yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) InstallYubiSW;
                    CreateYubikeyOTP;
                    CPYubikeyFiles;
                    return 0;;
            [Nn]* ) printf "\nSkipping Yubikey setup\n";
                    break;;
            * ) echo 'Please answer yes or no.';;
        esac
    done
}
#Install Yubico Software
InstallYubiSW () {
    printf '\nsudo apt install -y libpam-yubico\n'
    sudo apt install -y libpam-yubico;
    check_exit_status
    printf '\nsudo apt install -y libpam-u2f\n'
    sudo apt install -y libpam-u2f;
    check_exit_status
    printf '\nsudo apt install -y yubikey-manager\n'
    sudo apt install -y yubikey-manager;
    check_exit_status
    printf '\nsudo apt install -y yubikey-personalization\n'
    sudo apt install -y yubikey-personalization;
    check_exit_status
}
#Setup Yubikey OTP Authentication
CreateYubikeyOTP () {
    echo -e "\nSetting up OTP Authentication\n"
    sleep 1s
    authykeys=$USER
    read -p "Please touch your yubikey: " ykey
    ykey12=${ykey:0:12}
    authykeys+=':'
    authykeys+=$ykey12
    while true; do
        read -p "Would you like to add another yubikey? [Y/n]" yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) read -s -p "Please touch your next yubikey: " ykey
    	            ykey12=${ykey:0:12}
                    authykeys+=':'
                    authykeys+=$ykey12;;
            [Nn]* ) printf "\nSkipping\n";
                    echo $authykeys | tee >> ./authorized_yubikeys;
                    break;;
            * ) echo 'Please answer yes or no.';;
        esac
        echo $authykeys | tee >> ./authorized_yubikeys
        echo "Keys saved to ./authorized_yubikeys."
    done
}
#Copy and move Yubikey files to apropriate locations
CPYubikeyFiles () {
    printf "sudo mkdir -p /var/yubico\n"
    sudo mkdir -p /var/yubico
    printf "sudo chown root:root /var/yubico\n"
    sudo chown root:root /var/yubico
    printf "sudo chmod 766 /var/yubico\n"
    sudo chmod 766 /var/yubico
    printf "sudo cp ./authorized_yubikeys /var/yubico/authorized_yubikeys\n"
    sudo cp ./authorized_yubikeys /var/yubico/authorized_yubikeys
    for i in ~/.yubico/*; do
        printf "cp $i $(echo $i | sed "s/challenge/$USER/")\n"
        cp $i $(echo $i | sed "s/challenge/$USER/")
        printf "sudo mv ~/.yubico/$USER* /test/var/yubico/\n"
        sudo mv ~/.yubico/$USER* /test/var/yubico/
        printf "sudo chown root:root /test/var/yubico/*\n"
        sudo chown root:root /test/var/yubico/*
        printf "sudo chmod 600 /test/var/yubico/*\n"
        sudo chmod 600 /test/var/yubico/*
    done
    printf "sudo chmod 700 /var/yubico"
    sudo chmod 700 /var/yubico
    printf "sudo cp ./pam.d/yubikey /etc/pam.d/yubikey"
    sudo cp ./pam.d/yubikey /etc/pam.d/yubikey
    printf "sudo cp ./pam.d/yubikey-sudo /etc/pam.d/yubikey-sudo"
    sudo cp ./pam.d/yubikey-sudo /etc/pam.d/yubikey-sudo
    printf "sudo cp ./pam.d/yubikey-pin /etc/pam.d/yubikey-pin"
    sudo cp ./pam.d/yubikey-pin /etc/pam.d/yubikey-pin
    printf "\nAdd 'include' statements to pam auth files to specify your security preferences."
    sleep 3s

}
InstallSW () {
    while true; do
    read -p $'Would you like to install apt packages? [Y/n]' yn
    yn=${yn:-Y}
    case $yn in
        [Yy]* ) InstallAptSW
                break
                ;;
        [Nn]* ) printf "\nSkipping apt packages\n";
                    break;;
            * ) echo 'Please answer yes or no.';;
        esac
    done

}
InstallAptSW() {
    printf 'Installing Apt Packages'
    sleep 1s
  file='./apps/apt-apps'

  while read -r line <&3; do
    printf 'Would you like to install %s [Y/n]? ' "$line"

    read -r yn
    yn=${yn:-Y}
    case $yn in
      [Yy]*) echo sudo apt install -y "$line" 
            sudo apt install -y "$line"
            check_exit_status
            ;;
      [Nn]*) printf '\nSkipping %s\n' "$line";;
      *) break ;;
    esac
  done 3< "$file"
}
#check process for errors and prompt user to exit script if errors are detected.
check_exit_status() {
    if [ $? -eq 0 ]
    then
        STR=$'\nSuccess\n'
        echo "$STR"
    else
        STR='$\n[ERROR] Process Failed!\n'
        echo "$STR"

        read -p "The last command exited with an error. Exit script? (yes/no) " answer

        if [ "$answer" == "yes" ]
        then
            exit 1
        fi
    fi
}

if Greeting; then
    STR=$'\nProceeding\n'
    echo "$STR"
else
    printf "\nGoodbye\n"; exit
fi

Update

InstallVIM


ChHostname

SSHKeyGen

CPbashrc

CPvimrc

ConfigYubikeys

InstallSW

printf '\nGoodbye\n'
