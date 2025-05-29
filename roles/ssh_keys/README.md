# Rolle: ssh_keys

Diese Rolle konfiguriert SSH-Zugang für den Ziel-Benutzer (target_user).

## Features
- Erstellt `.ssh` Verzeichnis für den Ziel-Benutzer
- Fügt den `tbaer_ssh_pubkey` zu den authorized_keys hinzu
- Deaktiviert Passwort-Login für den Ziel-Benutzer (außer root)
- Setzt korrekte Berechtigungen für SSH-Dateien
- Verifiziert die SSH-Konfiguration

## Variablen
- `target_user`: Der Benutzer, für den SSH konfiguriert werden soll (wird pro Host im Inventory gesetzt)
- `tbaer_ssh_pubkey`: Der SSH-Public-Key der hinzugefügt werden soll (aus `group_vars/all.yml`)

## Sicherheitshinweise
- Passwort-Login wird nur für Nicht-Root-Benutzer deaktiviert
- SSH-Verzeichnis erhält sichere Berechtigungen (700)
- Authorized_keys Datei wird automatisch mit korrekten Berechtigungen erstellt

## Beispiel Inventory
```ini
[desktop]
desktop1 ansible_host=192.168.1.10 target_user=thomas

[server]  
server1 ansible_host=192.168.1.20 target_user=root
```

## Nutzung im Playbook
```yaml
- hosts: all
  become: true
  roles:
    - thomsible_user  # Erst Ansible-Benutzer anlegen
    - ssh_keys        # Dann SSH für Ziel-Benutzer konfigurieren
```

## Abhängigkeiten
- Benötigt die Variable `tbaer_ssh_pubkey` in `group_vars/all.yml`
- Ziel-Benutzer muss bereits auf dem System existieren
