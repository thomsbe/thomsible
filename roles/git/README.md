# Rolle: git

Diese Rolle installiert git und konfiguriert es für den Ziel-Benutzer.

## Features
- Installiert git-Paket auf dem System
- Erstellt grundlegende git-Konfiguration für den Ziel-Benutzer
- Setzt sinnvolle Defaults (main branch, nano editor, etc.)
- Konfiguriert Benutzer-spezifische git-Einstellungen
- Verifiziert Installation und Konfiguration

## Variablen
- `target_user`: Der Benutzer, für den git konfiguriert werden soll (wird pro Host im Inventory gesetzt)

## Konfiguration
Die Rolle erstellt automatisch eine `.gitconfig` mit folgenden Einstellungen:
- **Name**: `target_user`
- **Email**: `target_user@hostname.local`
- **Default Branch**: `main`
- **Pull-Strategie**: `rebase = false`
- **Editor**: `nano`

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
    - ssh_keys        # SSH für Ziel-Benutzer konfigurieren
    - git             # Git installieren und konfigurieren
```

## Abhängigkeiten
- Benötigt die Variable `target_user` im Inventory
- Ziel-Benutzer muss bereits auf dem System existieren
- Rolle sollte mit sudo-Berechtigung ausgeführt werden

## Verhalten
- Überschreibt keine bestehende `.gitconfig`
- Erstellt nur eine Basis-Konfiguration wenn keine vorhanden
- Setzt korrekte Besitzer-Berechtigungen für Konfigurationsdateien
