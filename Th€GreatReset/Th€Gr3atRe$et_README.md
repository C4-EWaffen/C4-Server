# The Great Reset
## Extremes Reinigungstool
Die Software die nach Botnetzen Viren und anderen Berdrohungen sucht und alles Restlos entfernt. Mit Kompilierer um Pakete zu erstellen.
### Schritte zur Umsetzung: 

## Schlüsselpaar erzeugen : 
Wir verwenden  openssl, um ein asymmetrisches Schlüsselpaar (RSA) zu erzeugen.

## Daten symmetrisch verschlüsseln : 
Mit dem öffentlichen Schlüssel wird eine AES-Verschlüsselung durchgeführt. Der AES-Schlüssel wird durch den RSA-privaten Schlüssel geschützt.

## Sichere Speicherung des privaten Schlüssels : 
Der private Schlüssel wird in einem sicheren Verzeichnis abgelegt, das nur vom Benutzer lesbar ist.

## Schlüssel im Software-Code einbetten : 
Der AES-Schlüssel wird automatisch in den Software-Code eingefügt. 

## Quelltext verschlüsseln/obfuskieren : 
Der Quellcode wird verschlüsselt oder obfuskiert, damit er ohne den richtigen Schlüssel unlesbar ist. 

## Software kompilieren : 
Der verschlüsselte oder obfuskierte Quelltext wird kompiliert, um eine ausführbare Datei zu erzeugen. 

## Erstellung einer ausführbaren  .txt-Datei : 
Die ausführbare Datei wird in eine  .txt-Datei eingebettet, die bei Doppelklick automatisch ausgeführt wird.

## Beispielskript

### 1. Schlüsselpaar erzeugen und sichere Speicherung des privaten Schlüssels:

    #!/bin/bash

    # Verzeichnisse erstellen
        mkdir -p /home/pi/secure_keys
        chmod 700 /home/pi/secure_keys

    # Schlüsselpaar erzeugen
        openssl genpkey -algorithm RSA -out /home/pi/secure_keys/private_key.pem -aes256
        openssl rsa -pubout -in /home/pi/secure_keys/private_key.pem -out /home/pi/secure_keys/public_key.pem

    echo "Schlüsselpaar erstellt und sicher gespeichert."

### 2. Daten symmetrisch verschlüsseln: 

        #!/bin/bash

        # AES-Schlüssel erzeugen und verschlüsseln
        openssl rand -base64 32 > /home/pi/secure_keys/aes_key.txt
        openssl rsautl -encrypt -inkey /home/pi/secure_keys/public_key.pem -pubin -in /home/pi/secure_keys/aes_key.txt -out /home/pi/secure_keys/encrypted_aes_key.bin

        echo "AES-Schlüssel generiert und mit dem öffentlichen Schlüssel verschlüsselt."


### 3. Einbettung des AES-Schlüssels in den Software-Code (Python-Beispiel):
       
        import base64

        # Lade den AES-Schlüssel
        with open('/home/pi/secure_keys/aes_key.txt', 'r') as key_file:
            aes_key = key_file.read().strip()

        # Schreibe den AES-Schlüssel in den Python-Code
        with open('software.py', 'a') as code_file:
            code_file.write(f"\nAES_KEY = '{aes_key}'\n")

        print("AES-Schlüssel erfolgreich in den Software-Code eingebettet.")

### 4. Quellcode verschlüsseln und obfuskieren: 

        from cryptography.fernet import Fernet

            # AES-Schlüssel (aus dem eingebetteten Schlüssel) verwenden
            cipher = Fernet(base64.urlsafe_b64encode(aes_key.encode()))

            with open('software.py', 'rb') as file:
                original_code = file.read()

            encrypted_code = cipher.encrypt(original_code)

            with open('software_encrypted.py', 'wb') as file:
                file.write(encrypted_code)

            print("Quellcode erfolgreich verschlüsselt.")

### 5. Software kompilieren: 

Du kannst  PyInstaller verwenden, um eine ausführbare Datei zu erstellen: 

        bash 

        pip install pyinstaller
        pyinstaller --onefile software_encrypted.py

### 6. Ausführbare Datei in  .txt umwandeln: 

        bash 

        base64 software_encrypted | fold -w 80 > software_executable.txt
        echo "Die ausführbare Datei wurde in eine TXT-Datei umgewandelt."

### 7. Ausführen der  .txt Datei: 

Die Ausführung einer  .txt-Datei als Programm ist nicht direkt möglich. Stattdessen kannst du in deinem Skript eine Methode verwenden, um die Datei in ein ausführbares Format zurückzuwandeln und dann auszuführen:

        #!/bin/bash

        # In .sh-Datei umwandeln
        base64 -d software_executable.txt > software_encrypted.sh
        chmod +x software_encrypted.sh
        ./software_encrypted.sh

        echo "Programm ausgeführt."

## Zusammenfassung: 

Dieses Skript und der begleitende Python-Code erzeugen ein asymmetrisches Schlüsselpaar, verschlüsseln eine Datei mit einem symmetrischen AES-Schlüssel, betten diesen Schlüssel in den Code ein, verschlüsseln den Quellcode, kompilieren ihn zu einer ausführbaren Datei und betten diese in eine .txt-Datei ein, die den verschlüsselten Code enthält.
