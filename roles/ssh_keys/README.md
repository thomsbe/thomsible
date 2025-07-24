# Rolle: ssh_keys

Diese Rolle konfiguriert SSH-Zugang für den Ziel-Benutzer (target_user).

## Features
- Erstellt `.ssh` Verzeichnis für den Ziel-Benutzer
- Fügt den `tbaer_ssh_pubkey` zu den authorized_keys hinzu
- Setzt korrekte Berechtigungen für SSH-Dateien
- Verifiziert die SSH-Konfiguration

**HINWEIS**: Passwort-Deaktivierung wurde entfernt, da sie alle Logins (auch lokale Konsole) blockiert!

## Variablen
- `target_user`: Der Benutzer, für den SSH konfiguriert werden soll (wird pro Host im Inventory gesetzt)
- `tbaer_ssh_pubkey`: Der SSH-Public-Key der hinzugefügt werden soll (aus `group_vars/all.yml`)

## Sicherheitshinweise
- SSH-Verzeichnis erhält sichere Berechtigungen (700)
- Authorized_keys Datei wird automatisch mit korrekten Berechtigungen erstellt
- **WICHTIG**: Passwort-Deaktivierung wurde entfernt - sie blockierte alle Logins!

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
