#!/bin/bash

# Funktion: Installiere C4-Server und Abhängigkeiten
install_c4_server() {
    if [[ $1 == "lokal" ]]; then
        echo "Installiere C4-Server lokal..."
        sudo apt-get update
        
        echo "Führe Upgrade des Systems durch..."
        sudo apt-get upgrade -y
        
        echo "Installation von Webservern und weiteren Diensten:"
        
        echo "1. NGINX installieren?"
        read -p "(ja/nein): " install_nginx
        if [[ $install_nginx == "ja" ]]; then
            sudo apt-get install nginx -y
            echo "NGINX installiert."
        fi
        
        echo "2. Apache installieren?"
        read -p "(ja/nein): " install_apache
        if [[ $install_apache == "ja" ]]; then
            sudo apt-get install apache2 -y
            echo "Apache installiert."
        fi
        
        echo "3. FTP-Server (vsftpd) installieren?"
        read -p "(ja/nein): " install_ftp
        if [[ $install_ftp == "ja" ]]; then
            sudo apt-get install vsftpd -y
            echo "FTP-Server installiert."
        fi
        
        echo "4. SSH-Server installieren?"
        read -p "(ja/nein): " install_ssh
        if [[ $install_ssh == "ja" ]]; then
            sudo apt-get install openssh-server -y
            echo "SSH-Server installiert."
        fi

        echo "5. Proxy-Server (Squid) installieren?"
        read -p "(ja/nein): " install_squid
        if [[ $install_squid == "ja" ]]; then
            sudo apt-get install squid -y
            echo "Proxy-Server installiert."
        fi

        echo "Installation abgeschlossen."
    elif [[ $1 == "remote" ]]; then
        echo "Installiere C4-Server remote..."
        ssh kali@192.168.188.60 <<EOF
            sudo apt-get update
            sudo apt-get upgrade -y
            
            echo "Installation von Webservern und weiteren Diensten:"
            
            sudo apt-get install nginx -y
            echo "NGINX installiert."
            
            sudo apt-get install apache2 -y
            echo "Apache installiert."
            
            sudo apt-get install vsftpd -y
            echo "FTP-Server installiert."
            
            sudo apt-get install openssh-server -y
            echo "SSH-Server installiert."

            sudo apt-get install squid -y
            echo "Proxy-Server installiert."

            echo "Installation abgeschlossen."
EOF
    else
        echo "Ungültige Option"
    fi
}

# Funktion: Starte C4-Server
start_c4_server() {
    echo "Starte C4-Server..."
    if [[ $1 == "lokal" ]]; then
        if command -v systemctl &> /dev/null; then
            sudo systemctl start nginx apache2 vsftpd ssh squid
        else
            sudo service nginx start
            sudo service apache2 start
            sudo service vsftpd start
            sudo service ssh start
            sudo service squid start
        fi
    elif [[ $1 == "remote" ]]; then
        ssh kali@192.168.188.60 <<EOF
            sudo systemctl start nginx apache2 vsftpd ssh squid || 
            (sudo service nginx start && 
            sudo service apache2 start &&
            sudo service vsftpd start &&
            sudo service ssh start &&
            sudo service squid start)
EOF
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
