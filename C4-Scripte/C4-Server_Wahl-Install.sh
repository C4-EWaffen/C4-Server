# ===============================================
# Funktion zur Installation des C4-Servers mit erweiterten Optionen
# ===============================================
function install_c4_server() {
    echo -e "${BLUE}C4-Server Installation:${RESET}"
    echo "1. Lokal installieren"
    echo "2. Remote installieren"
    echo "=============================="
    read -p "Option: " install_option

    # Auswahl der Ports
    read -p "Gib den Apache-Port ein (Standard: 80): " apache_port
    apache_port=${apache_port:-80}

    read -p "Gib den MySQL-Port ein (Standard: 3306): " mysql_port
    mysql_port=${mysql_port:-3306}

    echo "Wähle die Datenbank:"
    echo "1. MySQL"
    echo "2. SQLite"
    read -p "Option: " db_option

    case $install_option in
        1)
            echo -e "${BLUE}Installiere C4-Server lokal...${RESET}"
            sudo apt-get update

            if [[ $db_option -eq 1 ]]; then
                sudo apt-get install -y apache2 mysql-server
            else
                sudo apt-get install -y apache2 sqlite3
            fi

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Apache2 und Datenbank erfolgreich installiert.${RESET}"
            else
                echo -e "${RED}Fehler bei der Installation.${RESET}"
                return
            fi

            echo -e "${BLUE}Konfiguriere C4-Server...${RESET}"
            sudo ufw allow "$apache_port"
            sudo ufw allow "$mysql_port"
            sudo systemctl enable apache2
            [ $db_option -eq 1 ] && sudo systemctl enable mysql

            # Konfiguration für Apache-Port
            sudo sed -i "s/Listen 80/Listen $apache_port/g" /etc/apache2/ports.conf
            sudo systemctl restart apache2

            echo -e "${GREEN}C4-Server erfolgreich lokal installiert und konfiguriert.${RESET}"
            ;;
        2)
            read -p "Gib die Remote-IP ein: " remote_ip
            read -p "Gib den SSH-Benutzernamen ein: " ssh_user
            echo -e "${BLUE}Installiere C4-Server auf Remote-System...${RESET}"
            
            ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo apt-get update"
            if [[ $db_option -eq 1 ]]; then
                ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo apt-get install -y apache2 mysql-server"
            else
                ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo apt-get install -y apache2 sqlite3"
            fi

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Apache2 und Datenbank erfolgreich auf dem Remote-System installiert.${RESET}"
            else
                echo -e "${RED}Fehler bei der Installation auf dem Remote-System.${RESET}"
                return
            fi

            ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo ufw allow '$apache_port' && sudo ufw allow '$mysql_port' && sudo systemctl enable apache2"
            [ $db_option -eq 1 ] && ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo systemctl enable mysql"

            ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo sed -i 's/Listen 80/Listen $apache_port/g' /etc/apache2/ports.conf && sudo systemctl restart apache2"

            echo -e "${GREEN}C4-Server erfolgreich auf Remote-System installiert und konfiguriert.${RESET}"
            ;;
        *)
            echo -e "${RED}Ungültige Option!${RESET}"
            ;;
    esac
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}
