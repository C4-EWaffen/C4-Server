import tkinter as tk
from tkinter import messagebox
import os
import socket

# Funktion zur Überprüfung, ob ein bestimmter Port erreichbar ist
def check_connection(host, port):
    try:
        with socket.create_connection((host, port), timeout=1):
            return True
    except OSError:
        return False

# Funktion zur Installation und Konfiguration des Servers
def install_server(component):
    if component == "Apache":
        os.system("sudo apt-get install -y apache2")
        messagebox.showinfo("Installation", "Apache erfolgreich installiert!")
    elif component == "MySQL":
        os.system("sudo apt-get install -y mysql-server")
        messagebox.showinfo("Installation", "MySQL erfolgreich installiert!")
    elif component == "SQLite":
        os.system("sudo apt-get install -y sqlite3")
        messagebox.showinfo("Installation", "SQLite erfolgreich installiert!")
    elif component == "Proxy":
        os.system("sudo apt-get install -y nginx")
        messagebox.showinfo("Installation", "Nginx (Proxy) erfolgreich installiert!")

# Haupt-GUI-Funktion
def create_gui():
    root = tk.Tk()
    root.title("C4-Server Installation")
    root.geometry("600x400")

    # Überschrift mit ASCII-Art-Stil
    header = tk.Label(root, text="""
   _____   _____ _    _ 
  / ____| |_   _| |  | |
 | |        | | | |  | |
 | |        | | | |  | |
 | |____   _| |_| |__| |
  \_____| |_____\____/ 
""", font=("Courier", 14))
    header.pack()

    # Buttons zur Installation und Konfiguration
    btn_apache = tk.Button(root, text="Apache installieren", command=lambda: install_server("Apache"))
    btn_apache.pack(pady=10)

    btn_mysql = tk.Button(root, text="MySQL installieren", command=lambda: install_server("MySQL"))
    btn_mysql.pack(pady=10)

    btn_sqlite = tk.Button(root, text="SQLite installieren", command=lambda: install_server("SQLite"))
    btn_sqlite.pack(pady=10)

    btn_proxy = tk.Button(root, text="Nginx (Proxy) installieren", command=lambda: install_server("Proxy"))
    btn_proxy.pack(pady=10)

    # Fußbereich mit Statusanzeigen
    status_frame = tk.Frame(root)
    status_frame.pack(side=tk.BOTTOM, fill=tk.X)

    def update_status():
        apache_status = "Verbunden" if check_connection("127.0.0.1", 80) else "Nicht verbunden"
        mysql_status = "Verbunden" if check_connection("127.0.0.1", 3306) else "Nicht verbunden"
        sqlite_status = "Verfügbar"  # SQLite benötigt keinen Port, daher immer verfügbar
        proxy_status = "Verbunden" if check_connection("127.0.0.1", 443) else "Nicht verbunden"
        terminal_status = "Bereit" if check_connection("127.0.0.1", 8080) else "Nicht bereit"
        gui_status = "Bereit" if check_connection("127.0.0.1", 5000) else "Nicht bereit"

        lbl_apache.config(text=f"Apache: {apache_status}", fg="green" if apache_status == "Verbunden" else "red")
        lbl_mysql.config(text=f"MySQL: {mysql_status}", fg="green" if mysql_status == "Verbunden" else "red")
        lbl_sqlite.config(text=f"SQLite: {sqlite_status}", fg="green")
        lbl_proxy.config(text=f"Proxy: {proxy_status}", fg="green" if proxy_status == "Verbunden" else "red")
        lbl_terminal.config(text=f"Terminal: {terminal_status}", fg="green" if terminal_status == "Bereit" else "red")
        lbl_gui.config(text=f"GUI: {gui_status}", fg="green" if gui_status == "Bereit" else "red")

    lbl_apache = tk.Label(status_frame, text="Apache: Überprüfe...", font=("Arial", 10))
    lbl_apache.pack(anchor="w")

    lbl_mysql = tk.Label(status_frame, text="MySQL: Überprüfe...", font=("Arial", 10))
    lbl_mysql.pack(anchor="w")

    lbl_sqlite = tk.Label(status_frame, text="SQLite: Überprüfe...", font=("Arial", 10))
    lbl_sqlite.pack(anchor="w")

    lbl_proxy = tk.Label(status_frame, text="Proxy: Überprüfe...", font=("Arial", 10))
    lbl_proxy.pack(anchor="w")

    lbl_terminal = tk.Label(status_frame, text="Terminal: Überprüfe...", font=("Arial", 10))
    lbl_terminal.pack(anchor="w")

    lbl_gui = tk.Label(status_frame, text="GUI: Überprüfe...", font=("Arial", 10))
    lbl_gui.pack(anchor="w")

    update_status()
    root.mainloop()

if __name__ == "__main__":
    create_gui()

