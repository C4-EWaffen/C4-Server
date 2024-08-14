# ===============================================
# Funktion zur Installation des C4-Servers
# ===============================================
function install_c4_server() {
    echo -e "${BLUE}C4-Server Installation:${RESET}"
    echo "1. Lokal installieren"
    echo "2. Remote installieren"
    echo "=============================="
    read -p "Option: " install_option

    case $install_option in
        1)
            echo -e "${BLUE}Installiere C4-Server lokal...${RESET}"
            # Aktualisieren und notwendige Pakete installieren
            sudo apt-get update
            sudo apt-get install -y apache2 mysql-server

            # Überprüfen, ob die Dienste erfolgreich installiert wurden
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Apache2 und MySQL erfolgreich installiert.${RESET}"
            else
                echo -e "${RED}Fehler bei der Installation von Apache2 und MySQL.${RESET}"
                return
            fi

            # Konfigurationen für den C4-Server
            # Hier können weitere spezifische Konfigurationen hinzugefügt werden
            echo -e "${BLUE}Konfiguriere C4-Server...${RESET}"
            # Beispiel: Firewall konfigurieren
            sudo ufw allow 'Apache'
            sudo ufw allow 3306
            sudo systemctl enable apache2
            sudo systemctl enable mysql

            echo -e "${GREEN}C4-Server erfolgreich lokal installiert und konfiguriert.${RESET}"
            ;;
        2)
            read -p "Gib die Remote-IP ein: " remote_ip
            read -p "Gib den SSH-Benutzernamen ein: " ssh_user
            echo -e "${BLUE}Installiere C4-Server auf Remote-System...${RESET}"
            # Aktualisieren und notwendige Pakete auf dem Remote-System installieren
            ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo apt-get update && sudo apt-get install -y apache2 mysql-server"

            # Überprüfen, ob die Installation erfolgreich war
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Apache2 und MySQL erfolgreich auf dem Remote-System installiert.${RESET}"
            else
                echo -e "${RED}Fehler bei der Installation auf dem Remote-System.${RESET}"
                return
            fi

            # Remote-Konfigurationen für den C4-Server
            ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo ufw allow 'Apache' && sudo ufw allow 3306 && sudo systemctl enable apache2 && sudo systemctl enable mysql"

            echo -e "${GREEN}C4-Server erfolgreich auf Remote-System installiert und konfiguriert.${RESET}"
            ;;
        *)
            echo -e "${RED}Ungültige Option!${RESET}"
            ;;
    esac
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}
