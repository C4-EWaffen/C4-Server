import tkinter as tk
from tkinter import messagebox
import subprocess

class C4ControlApp:
    def __init__(self, root):
        self.root = root
        self.root.title("C4-Server Control")
        self.root.configure(bg='black')

        # Überschrift
        title = tk.Label(root, text="C4-Server Control", font=("Arial", 24), fg='limegreen', bg='black')
        title.pack(pady=10)

        # Button-Definitionen
        self.buttons = {
            "C4-Serverstart": self.toggle_c4_server,
            "Start C4-Webserver": self.toggle_webserver,
            "Start C4-Datenbank": self.toggle_database,
            "Start C4-Proxy": self.toggle_proxy,
            "Start C4-Agenten Netzwerk": self.toggle_agent_network,
            "Verschlüsselte Kommunikation": self.toggle_encrypted_comm,
            "Start C4-Terminal Knoten": self.toggle_terminal_node,
            "Export": self.export_data,
            "Backup&Wiederherstellung": self.backup_restore,
            "Einstellungen": self.settings,
            "Beenden": self.exit_app
        }

        # Button-Erstellung
        self.button_objs = {}
        for button_text, command in self.buttons.items():
            button = tk.Button(root, text=button_text, font=("Arial", 14), width=30, bg='black', fg='limegreen',
                               activebackground='limegreen', activeforeground='black', command=command)
            button.pack(pady=5)
            self.button_objs[button_text] = button

    def toggle_button_state(self, button_text, started):
        """Update button text and color based on the service state."""
        if started:
            self.button_objs[button_text].config(text=button_text.replace("Start", "Stop"), bg='green')
        else:
            self.button_objs[button_text].config(text=button_text.replace("Stop", "Start"), bg='red')

    def toggle_c4_server(self):
        # Start/Stop the entire C4 environment
        self.toggle_button_state("C4-Serverstart", True)

    def toggle_webserver(self):
        # Start/Stop the C4 Webserver
        self.toggle_button_state("Start C4-Webserver", True)

    def toggle_database(self):
        # Start/Stop the C4 Database
        self.toggle_button_state("Start C4-Datenbank", True)

    def toggle_proxy(self):
        # Start/Stop the C4 Proxy
        self.toggle_button_state("Start C4-Proxy", True)

    def toggle_agent_network(self):
        # Start/Stop the C4 Agent Network
        self.toggle_button_state("Start C4-Agenten Netzwerk", True)

    def toggle_encrypted_comm(self):
        # Enable/Disable encrypted communication
        self.toggle_button_state("Verschlüsselte Kommunikation", True)

    def toggle_terminal_node(self):
        # Start/Stop the C4 Terminal Node
        self.toggle_button_state("Start C4-Terminal Knoten", True)

    def export_data(self):
        # Export data function
        messagebox.showinfo("Export", "Exporting data...")

    def backup_restore(self):
        # Backup & Restore function
        messagebox.showinfo("Backup&Wiederherstellung", "Starting backup/restore...")

    def settings(self):
        # Open settings window
        messagebox.showinfo("Einstellungen", "Opening settings...")

    def exit_app(self):
        # Exit the application
        self.root.quit()

# Hauptanwendung ausführen
if __name__ == "__main__":
    root = tk.Tk()
    app = C4ControlApp(root)
    root.mainloop()
