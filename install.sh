#!/bin/sh

arch=$(cat /etc/os-release | grep "^ID" | cut -d "=" -f2)
shells="bash zsh"

echo Welcome $USER@$HOSTNAME on $arch !

echo "Install dependencies"
yay -S 'stow'

echo -n "Wich shell do you use ?: "
read shell
yay -S "$shell"

echo -n "Install dotfiles? [y/N]: ";
read needdot
if [ "$needdot" = "y" -o "$needdot" = "Y" ]; then
    for folder in $(ls -d */); do
        stow "$folder"
    done
fi

echo -n "Install laptop services? [y/N]: "
read needLaptopServices
if [ "$needLaptopServices" = "y" -o "$needLaptopServices" = "Y" ]; then
    #Lowbat-suspend
    systemctl --user enable lowbat-suspend.timer && 
    systemctl --user start lowbat-suspend.timer

    #Suspend
    systemctl --user enable suspend.service
fi

echo -n "Install U2F config? [y/N]: "
read needU2F
if [ "$needU2F" = "y" -o "$needU2F" = "Y" ]; then
    yay -S pam-u2f
    sudo sed -i '2iauth		sufficient	pam_u2f.so origin=pam://hostname appid=pam://hostname cue [prompt=Please touch the device]' /etc/pam.d/sudo
    sudo sed -i '3iauth		sufficient	pam_u2f.so origin=pam://hostname appid=pam://hostname' /etc/pam.d/login
    sudo sed -i '6iauth		sufficient	pam_u2f.so origin=pam://hostname appid=pam://hostname' /etc/pam.d/i3lock
fi

echo -n "Install spotifyd ? [y/N]: "
read needSpotifyd
if [ "$needSpotifyd" = "y" -o "$needSpotifyd" = "Y" ]; then
    yay spotifyd spotify-tui

    systemctl --user enable spotifyd.service &&
    systemctl --user start spotifyd.service
fi

exit 0
