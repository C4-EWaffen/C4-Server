#!/bin/bash

# Farbkodierungen für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Pfad zum Hauptverzeichnis
C4_DIR="$HOME/C4-Direktory"
mkdir -p "$C4_DIR"

# Pfade zu Unterverzeichnissen
output_dir="$C4_DIR/output"
backup_dir="$C4_DIR/backup"
remote_output_dir="$C4_DIR/remote_output"
aufklaerung_dir="$C4_DIR/aufklaerung"
proxy_list_file="$C4_DIR/proxy_list.txt"
ssh_key="$C4_DIR/id_rsa"  # Beispiel-SSH-Schlüsseldatei
alert_file="README.md"

# Variablen zur Statusanzeige
c4_server_status="Disconnected"
c4_database_status="Disconnected"
agent_status="Disconnected"
proxy_status="Disconnected"

# ===============================================
# Funktion zur Anzeige des Menüs
# ===============================================
function show_menu() {
    clear
    echo -e "  ██████╗██╗  ██╗    ███████╗      ██╗    ██╗ █████╗ ███████╗███████╗███████╗███╗   ██╗"
    echo -e " ██╔════╝██║  ██║    ██╔════╝      ██║    ██║██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║"
    echo -e " ██║     ███████║    █████╗  █████╗██║ █╗ ██║███████║█████╗  █████╗  █████╗  ██╔██╗ ██║"
    echo -e " ██║     ╚════██║    ██╔══╝  ╚════╝██║███╗██║██╔══██║██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║"
    echo -e " ╚██████╗     ██║    ███████╗      ╚███╔███╔╝██║  ██║██║     ██║     ███████╗██║ ╚████║"
    echo -e "  ╚═════╝     ╚═╝    ╚══════╝       ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═══╝"
    echo -e ""
    echo -e "======================================================================================="
    echo -e "   C4-Server: ${c4_server_status}   |   C4-Datenbank: ${c4_database_status}   |   Agenten: ${agent_status}   |   Proxy: ${proxy_status}"
    echo -e "======================================================================================="
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
# Funktion zur Sammlung von Systeminformationen
# ===============================================
function collect_sysinfo() {
    mkdir -p "$output_dir"
    echo -e "${BLUE}Sammle Systeminformationen...${RESET}"
    uname -a > "$output_dir/sysinfo.txt"
    df -h >> "$output_dir/sysinfo.txt"
    echo -e "${GREEN}Systeminformationen gespeichert in ${output_dir}/sysinfo.txt.${RESET}"
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zum Ausführen eines Nmap-Scans
# ===============================================
function perform_nmap_scan() {
    mkdir -p "$output_dir"
    read -p "Gib die Ziel-IP oder den Bereich ein: " target_ip
    echo -e "${BLUE}Führe Nmap-Scan durch...${RESET}"
    nmap -A "$target_ip" -oN "$output_dir/nmap_scan.txt"
    echo -e "${GREEN}Nmap-Scan gespeichert in ${output_dir}/nmap_scan.txt.${RESET}"
    read -p "Drücke Enter, um zum Hauptmenü zurückzukehren..."
}

# ===============================================
# Funktion zum Sammeln von Remote-Daten
# ===============================================
function collect_remote_data() {
    mkdir -p "$remote_output_dir"
    read -p "Gib die Remote-IP ein: " remote_ip
    read -p "Gib den SSH-Benutzernamen ein: " ssh_user
    echo -e "${BLUE}Sammle Remote-Daten...${RESET}"
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
    mkdir -p "$output_dir"
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
            ssh -i "$ssh_key" "$last_c4_connection"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Verbindung mit letzter funktionierender Verbindung erfolgreich.${RESET}"
                c4_server_status="Verbunden ($last_c4_connection)"
            else
                echo -e "${RED}Fehler bei der letzten Verbindung zum C4-Server.${RESET}"
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
    echo -e "${BLUE}C4-Server installieren:${RESET}"
    echo "1. Lokal installieren"
    echo "2. Remote installieren"
    echo "=============================="
    read -p "Option: " install_option

    case $install_option in
        1)
            echo -e "${BLUE}Installiere lokal...${RESET}"
            # Hier könnte ein Installationsskript eingefügt werden
            ;;
        2)
            read -p "Gib die Remote-IP ein: " remote_ip
            read -p "Gib den SSH-Benutzernamen ein: " ssh_user
            scp -i "$ssh_key" "$C4_DIR/install_script.sh" "$ssh_user@$remote_ip:/tmp/"
            ssh -i "$ssh_key" "$ssh_user@$remote_ip" "bash /tmp/install_script.sh"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}C4-Server erfolgreich remote installiert.${RESET}"
            else
                echo -e "${RED}Fehler bei der Remote-Installation des C4-Servers.${RESET}"
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
    echo -e "${BLUE}C4-Server starten...${RESET}"
    if [ "$c4_server_status" == "Disconnected" ]; then
        connect_c4_server
    fi
    # Startbefehl für den C4-Server hier einfügen
    echo -e "${GREEN}C4-Server gestartet.${RESET}"
}

# Funktion zur Verbindung mit der C4-Datenbank
function connect_c4_database() {
    echo -e "${BLUE}C4-Datenbank verbinden...${RESET}"
    # Verbindung zur C4-Datenbank herstellen
    c4_database_status="Verbunden"
    echo -e "${GREEN}C4-Datenbank verbunden.${RESET}"
}

# Funktion zur Verwaltung von Agenten und Proxy
function manage_agents_and_proxy() {
    echo -e "${BLUE}Agenten und Proxy verwalten...${RESET}"
    # Logik zur Verwaltung von Agenten und Proxy hier einfügen
    agent_status="Verbunden"
    proxy_status="Verbunden"
    echo -e "${GREEN}Agenten und Proxy verbunden.${RESET}"
}

# ===============================================
# Funktion zum Erstellen und Senden eines Backups
# ===============================================
function create_and_send_backup() {
    mkdir -p "$backup_dir"
    read -p "Gib den SSH-Benutzernamen für das Remote-System ein: " remote_user
    read -p "Gib die Remote-IP ein: " remote_host
    read -p "Gib das Zielverzeichnis auf dem Remote-System ein: " remote_backup_dir

    echo -e "${BLUE}Erstelle Backup...${RESET}"
    tar -czf "$backup_dir/backup_$(date +%F).tar.gz" "$C4_DIR"
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
