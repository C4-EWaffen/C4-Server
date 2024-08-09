# C4-Server
![tower-31235_960_720-645792324](https://github.com/user-attachments/assets/d270746b-56af-40b1-ae0f-c16a5bb5d42e)

Einfacher Script, welcher unterschiedliche Server startet und den Zugriff auf die C4-Anwendungen bereit stellt. Über diese Verbindungen sollten Daten von z.B dem C4-Terminal Script an den C&C Server übertragen werden und die Persistens der Agententen erfolgen. Zu Beginn sollte ein http/https Server installiert werden und gestartet werden können. Des Weiteren, sollten der Proxy-Server gestartet werden nachdem dieser Installiert wurde. Die wichtigsten Funktionen sind die Kommunikation mit den Agenten, sowie aller C4-Software Komponenten. Die Agenten können sich nach dem Start der sysget Datei an dem C&C-Server anmelden und die ersten Informationen übertragen. Die C4-Server Anwendung sollte auch das einrichten eines Dienstes automatisch ausführen und starten. 

- HTTP/HTTPS Server
- FTP/FTPS Server
- Proxy-Server
- Onion-Share
