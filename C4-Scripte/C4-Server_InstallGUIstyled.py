import tkinter as tk
from tkinter import messagebox
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
    root.geometry("800x600")
    root.configure(bg="black")  # Schwarzer Hintergrund

    # Überschrift mit ASCII-Art-Stil und Farbcodierung
    header = tk.Label(root, text="""
  \033[0;34m  ██████╗██╗  ██╗    ███████╗      ██╗    ██╗ █████╗ ███████╗███████╗███████╗███╗   ██╗
  ██╔════╝██║  ██║    ██╔════╝      ██║    ██║██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║
  ██║     ███████║    █████╗  █████╗██║ █╗ ██║███████║█████╗  █████╗  █████╗  ██╔██╗ ██║
  ██║     ╚════██║    ██╔══╝  ╚════╝██║███╗██║██╔══██║██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║
  ╚██████╗     ██║    ███████╗      ╚███╔███╔╝██║  ██║██║     ██║     ███████╗██║ ╚████║
   ╚═════╝     ╚═╝    ╚══════╝       ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═══╝
  """, font=("Courier", 12), fg="white", bg="black")
    header.pack()

    # Eingabefelder für IP- und Port-Konfiguration
    ip_label = tk.Label(root, text="Server IP:", fg="white", bg="black", font=("Arial", 10))
    ip_label.pack(pady=5)
    ip_entry = tk.Entry(root, width=20)
    ip_entry.pack(pady=5)

    port_label = tk.Label(root, text="Apache Port:", fg="white", bg="black", font=("Arial", 10))
    port_label.pack(pady=5)
    port_entry = tk.Entry(root, width=20)
    port_entry.pack(pady=5)

    mysql_port_label = tk.Label(root, text="MySQL Port:", fg="white", bg="black", font=("Arial", 10))
    mysql_port_label.pack(pady=5)
    mysql_port_entry = tk.Entry(root, width=20)
    mysql_port_entry.pack(pady=5)

    # Buttons zur Installation und Konfiguration
    btn_apache = tk.Button(root, text="Apache installieren", command=lambda: install_server("Apache"), bg="blue", fg="white")
    btn_apache.pack(pady=10)

    btn_mysql = tk.Button(root, text="MySQL installieren", command=lambda: install_server("MySQL"), bg="blue", fg="white")
    btn_mysql.pack(pady=10)

    btn_sqlite = tk.Button(root, text="SQLite installieren", command=lambda: install_server("SQLite"), bg="blue", fg="white")
    btn_sqlite.pack(pady=10)

    btn_proxy = tk.Button(root, text="Nginx (Proxy) installieren", command=lambda: install_server("Proxy"), bg="blue", fg="white")
    btn_proxy.pack(pady=10)

    # Fußbereich mit Statusanzeigen
    status_frame = tk.Frame(root, bg="black")
    status_frame.pack(side=tk.BOTTOM, fill=tk.X)

    def update_status():
        apache_status = "Verbunden" if check_connection(ip_entry.get(), int(port_entry.get())) else "Nicht verbunden"
        mysql_status = "Verbunden" if check_connection(ip_entry.get(), int(mysql_port_entry.get())) else "Nicht verbunden"
        sqlite_status = "Verfügbar"  # SQLite benötigt keinen Port, daher immer verfügbar
        proxy_status = "Verbunden" if check_connection(ip_entry.get(), 443) else "Nicht verbunden"
        terminal_status = "Bereit" if check_connection(ip_entry.get(), 8080) else "Nicht bereit"
        gui_status = "Bereit" if check_connection(ip_entry.get(), 5000) else "Nicht bereit"

        lbl_apache.config(text=f"Apache: {apache_status}", fg="green" if apache_status == "Verbunden" else "red")
        lbl_mysql.config(text=f"MySQL: {mysql_status}", fg="green" if mysql_status == "Verbunden" else "red")
        lbl_sqlite.config(text=f"SQLite: {sqlite_status}", fg="green")
        lbl_proxy.config(text=f"Proxy: {proxy_status}", fg="green" if proxy_status == "Verbunden" else "red")
        lbl_terminal.config(text=f"Terminal: {terminal_status}", fg="green" if terminal_status == "Bereit" else "red")
        lbl_gui.config(text=f"GUI: {gui_status}", fg="green" if gui_status == "Bereit" else "red")

    lbl_apache = tk.Label(status_frame, text="Apache: Überprüfe...", font=("Arial", 10), bg="black", fg="white")
    lbl_apache.pack(anchor="w")

    lbl_mysql = tk.Label(status_frame, text="MySQL: Überprüfe...", font=("Arial", 10), bg="black", fg="white")
    lbl_mysql.pack(anchor="w")

    lbl_sqlite = tk.Label(status_frame, text="SQLite: Verfügbar", font=("Arial", 10), bg="black", fg="green")
    lbl_sqlite.pack(anchor="w")

    lbl_proxy = tk.Label(status_frame, text="Proxy: Überprüfe...", font=("Arial", 10), bg="black", fg="white")
    lbl_proxy.pack(anchor="w")

    lbl_terminal = tk.Label(status_frame, text="Terminal: Überprüfe...", font=("Arial", 10), bg="black", fg="white")
    lbl_terminal.pack(anchor="w")

    lbl_gui = tk.Label(status_frame, text="GUI: Überprüfe...", font=("Arial", 10), bg="black", fg="white")
    lbl_gui.pack(anchor="w")

    update_status()
    root.mainloop()

if __name__ == "__main__":
    create_gui()
