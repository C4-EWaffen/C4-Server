#!/bin/bash

# Warnung anzeigen
echo "Warnung: Dieses Skript setzt das Raspberry Pi OS auf die Werkseinstellungen zurück und löscht alle Daten."
echo "Möchten Sie fortfahren? (y/n)"
read confirmation

if [ "$confirmation" != "y" ]; then
    echo "Abbruch."
    exit 1
fi

# Rücksetzung des Systems
echo "Starte Rücksetzung auf Werkseinstellungen..."
sudo rm -rf /home/*
sudo apt-get --reinstall install raspberrypi-bootloader raspberrypi-kernel raspberrypi-ui-mods raspberrypi-sys-mods
sudo apt-get purge --auto-remove -y

# Benutzerdefinierte Einstellungen hinzufügen
mkdir -p /home/pi/.config/lxsession/LXDE-pi/
echo "@/pfad/zur/software" >> /home/pi/.config/lxsession/LXDE-pi/autostart

mkdir -p /home/pi/.config/pcmanfm/LXDE-pi/
echo "[*]" > /home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf
echo "wallpaper=/pfad/zum/hintergrundbild.jpg" >> /home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf

echo "Rücksetzung abgeschlossen. System wird neu gestartet."
sudo reboot


