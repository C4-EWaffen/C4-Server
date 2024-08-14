#!/bin/bash

# Funktion: Installiere C4-Server
install_c4_server() {
    if [[ $1 == "lokal" ]]; then
        echo "Installiere C4-Server lokal..."
        sudo apt-get update
        sudo apt-get install nginx -y
        # Weitere Installationsschritte...
    elif [[ $1 == "remote" ]]; then
        echo "Installiere C4-Server remote..."
        ssh kali@192.168.188.60 "sudo apt-get update && sudo apt-get install nginx -y"
        # Weitere Installationsschritte...
    else
        echo "Ungültige Option"
    fi
}

# Funktion: Starte C4-Server
start_c4_server() {
    echo "Starte C4-Server..."
    if [[ $1 == "lokal" ]]; then
        sudo systemctl start nginx
    elif [[ $1 == "remote" ]]; then
        ssh kali@192.168.188.60 "sudo systemctl start nginx"
    else
        echo "Ungültige Option"
    fi
}

# Funktionsauswahl: Automatische Installation und Start
echo "Wähle eine Option:"
echo "1. Installiere C4-Server"
echo "2. Starte C4-Server"

read -p "Eingabe: " option

case $option in
    1)
        read -p "Installieren lokal oder remote? (lokal/remote): " target
        install_c4_server $target
        ;;
    2)
        read -p "Starten lokal oder remote? (lokal/remote): " target
        start_c4_server $target
        ;;
    *)
        echo "Ungültige Auswahl"
        ;;
esac
