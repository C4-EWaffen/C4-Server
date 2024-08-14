# %%
from kivy.app import App
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.popup import Popup

class C4ControlApp(App):
    def build(self):
        layout = BoxLayout(orientation='vertical', padding=10, spacing=10)
        header = Label(text="C4-Server Control", font_size='24sp', color=(0, 1, 0, 1))

        # Grid layout for buttons
        button_layout = GridLayout(cols=2, spacing=10, size_hint=(1, None))
        button_layout.bind(minimum_height=button_layout.setter('height'))

        # Button Definitions
        buttons = [
            ("C4-Serverstart", self.toggle_c4_server),
            ("Start C4-Webserver", self.toggle_webserver),
            ("Start C4-Datenbank", self.toggle_database),
            ("Start C4-Proxy", self.toggle_proxy),
            ("Start C4-Agenten Netzwerk", self.toggle_agent_network),
            ("Verschlüsselte Kommunikation", self.toggle_encrypted_comm),
            ("Start C4-Terminal Knoten", self.toggle_terminal_node),
            ("Export", self.export_data),
            ("Backup&Wiederherstellung", self.backup_restore),
            ("Einstellungen", self.settings),
            ("Beenden", self.exit_app)
        ]

        for text, callback in buttons:
            btn = Button(text=text, size_hint_y=None, height=40, background_color=(0, 1, 0, 1))
            btn.bind(on_release=callback)
            button_layout.add_widget(btn)

        layout.add_widget(header)
        layout.add_widget(button_layout)

        return layout

    def show_popup(self, title, message):
        popup = Popup(title=title, content=Label(text=message), size_hint=(0.8, 0.4))
        popup.open()

    def toggle_c4_server(self, instance):
        self.show_popup("C4-Serverstart", "C4-Server wird gestartet...")

    def toggle_webserver(self, instance):
        self.show_popup("C4-Webserver", "C4-Webserver wird gestartet...")

    def toggle_database(self, instance):
        self.show_popup("C4-Datenbank", "C4-Datenbank wird gestartet...")

    def toggle_proxy(self, instance):
        self.show_popup("C4-Proxy", "C4-Proxy wird gestartet...")

    def toggle_agent_network(self, instance):
        self.show_popup("C4-Agenten Netzwerk", "C4-Agenten Netzwerk wird gestartet...")

    def toggle_encrypted_comm(self, instance):
        self.show_popup("Verschlüsselte Kommunikation", "Verschlüsselte Kommunikation wird aktiviert...")

    def toggle_terminal_node(self, instance):
        self.show_popup("C4-Terminal Knoten", "C4-Terminal Knoten wird gestartet...")

    def export_data(self, instance):
        self.show_popup("Export", "Daten werden exportiert...")

    def backup_restore(self, instance):
        self.show_popup("Backup&Wiederherstellung", "Backup oder Wiederherstellung wird durchgeführt...")

    def settings(self, instance):
        self.show_popup("Einstellungen", "Einstellungen werden geöffnet...")

    def exit_app(self, instance):
        App.get_running_app().stop()

# Hauptanwendung starten
if __name__ == "__main__":
    C4ControlApp().run()



