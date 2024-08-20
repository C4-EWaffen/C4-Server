#!/bin/bash

# Fest eingebetteter öffentlicher Schlüssel
public_key="MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArMvPDrE0c3P..."

# Pfade definieren
reset_software_template="reset_software_template.sh"
reset_software="reset_software.sh"
encrypted_reset_software="encrypted_reset_software.bin"
compiled_reset_software="compiled_reset_software"

# Öffentlichen Schlüssel in die Reset-Software einfügen
sed "s|<PUBLIC_KEY_PLACEHOLDER>|$public_key|g" "$reset_software_template" > "$reset_software"

# Verschlüsseln der Reset-Software mit dem öffentlichen Schlüssel
openssl rsautl -encrypt -inkey <(echo "$public_key") -pubin -in "$reset_software" -out "$encrypted_reset_software"

# Kompilieren der verschlüsselten Software
gcc -o "$compiled_reset_software" -x c - <<EOF
#include <stdio.h>
#include <stdlib.h>
int main() {
char command[1024];

snprintf(command, sizeof(command), "openssl rsautl -decrypt -inkey <(echo \"$public_key\") -in %s -out decrypted_reset.sh", "$encrypted_reset_software");

if (system(command) != 0) {
	printf("Fehler: Entschlüsselungsfehler.\\n");
	return 1;
	}
	
	system("bash decrypted_reset.sh");
	remove("decrypted_reset.sh");
	
	return 0;
	}
	EOF
	
	chmod +x "$compiled_reset_software"
	echo "Verschlüsselte und kompilierte Reset-Software wurde erfolgreich erstellt: $compiled_reset_software"
	
