# Rolle: user_config

Diese Rolle konfiguriert einen Ziel-Benutzer basierend auf der `target_user` Variable.

## Features
- Erstellt `.config` und `tools` Verzeichnisse im HOME des Ziel-Benutzers
- Installiert fish shell aus System-Repositories
- Setzt fish als Standard-Shell für Ziel-Benutzer (außer root)
- Konfiguriert PATH für `$HOME/local/bin` in fish und bash
- Erstellt eine Beispiel-Konfigurationsdatei
- Setzt korrekte Besitzer und Berechtigungen

## Shell-Konfiguration
- **Fish Shell**: Wird als Standard-Shell gesetzt (außer für root)
- **PATH-Konfiguration**: `$HOME/local/bin` wird zu PATH hinzugefügt
- **Cross-Shell**: PATH wird sowohl für fish als auch bash konfiguriert
- **GitHub-Tools**: Installierte Tools sind sofort verfügbar

## Variablen
- `target_user`: Der Benutzer, dessen Konfiguration angepasst werden soll (wird pro Host im Inventory gesetzt)

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
    - user_config     # Dann Ziel-Benutzer konfigurieren
```
