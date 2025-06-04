# Technische Details und Patterns

## Technologiestack
- **Ansible**: Automatisierung und Konfiguration
- **YAML**: Für Playbooks, Variablen und Inventories
- **Modularer Aufbau**: Jede Rolle ist ein eigenständiges Modul

## Patterns und Best Practices

### Benutzer-Management
- **Zwei-Benutzer-System**: Trennung von ausführendem Benutzer (konfigurierbar via `ansible_user_name`) und Ziel-Benutzer (`target_user`)
- **Zwei-Phasen-Deployment**: Erst Ansible-Benutzer anlegen, dann mit diesem arbeiten
- **Pro-Host target_user**: Flexible Konfiguration je nach System (Server: `root`, Desktop: `thomas`)
- **Konfigurierbarer Ansible-Benutzer**: Name über `ansible_user_name` anpassbar (Standard: "thomsible")

### Rollen-Design
- **Eine Rolle pro Tool**: Jede Rolle installiert ein einzelnes Programm oder Tool
- **OS-Familie-Unterstützung**: Automatische Erkennung und Anpassung für Debian/Ubuntu vs RedHat/Fedora
- **Variablen-Auslagerung**: OS-spezifische Variablen in separate `vars/` Dateien
- **Target-User-Awareness**: Rollen arbeiten mit dem konfigurierten Ziel-Benutzer

### Sicherheit
- **SSH-Key-basierte Authentifizierung**: Passwort-Login wird deaktiviert
- **Sudo ohne Passwort**: Für Automatisierung, aber nur für Ansible-Benutzer
- **Sichere Berechtigungen**: SSH-Verzeichnisse und -Dateien mit korrekten Permissions

## Rollen-Entwicklung

### Neue Rolle erstellen
```
roles/meine_rolle/
├── tasks/main.yml          # Haupt-Tasks
├── vars/
│   ├── Debian.yml         # Debian/Ubuntu-spezifische Variablen
│   └── RedHat.yml         # RedHat/Fedora-spezifische Variablen
├── README.md              # Dokumentation
└── defaults/main.yml      # Standard-Variablen (optional)
```

### Template für target_user-aware Rolle
```yaml
---
- name: Get target user information
  include_tasks: "{{ playbook_dir }}/roles/common/tasks/get_target_user_info.yml"

# Verfügbare Variablen nach dem Include:
# - target_user_home: Home-Verzeichnis des Benutzers
# - target_user_group: Gruppen-ID der Hauptgruppe
# - target_user_group_name: Name der Hauptgruppe

- name: Create directory with correct permissions
  ansible.builtin.file:
    path: "{{ target_user_home }}/example"
    state: directory
    owner: "{{ target_user }}"
    group: "{{ target_user_group_name }}"  # Verwende IMMER target_user_group_name!
    mode: '0755'

- name: Include OS-specific variables
  ansible.builtin.include_vars: "{{ ansible_os_family }}.yml"
```

### ⚠️ Wichtig: Korrekte Gruppenverwaltung

**Problem:** Das direkte Verwenden von `group: "{{ target_user }}"` führt zu Fehlern, da der Benutzername nicht immer dem Gruppennamen entspricht.

**Lösung:** Verwende immer `target_user_group_name` für Gruppenzuweisungen:

```yaml
# ❌ FALSCH - kann zu Fehlern führen
- name: Create file
  ansible.builtin.file:
    path: "{{ target_user_home }}/example"
    owner: "{{ target_user }}"
    group: "{{ target_user }}"  # Problematisch!

# ✅ RICHTIG - verwendet die korrekte Hauptgruppe
- name: Create file
  ansible.builtin.file:
    path: "{{ target_user_home }}/example"
    owner: "{{ target_user }}"
    group: "{{ target_user_group_name }}"  # Korrekt!

# Weitere Tasks hier...
```

### Testing
- Tests werden mit dem bereitgestellten docker-compose-Stack durchgeführt
- Container für Debian 11, Debian 12, Ubuntu 24.04, Fedora 42
- Inventory unter `inventories/docker/hosts_thomsible`
- Playbook mit `ansible-playbook -i inventories/docker/hosts_thomsible test_rolle.yml` ausführen

## Bootstrap-System

Das Bootstrap-System ermöglicht die einfache Installation auf neuen Systemen mit intelligenter Ansible-Verwaltung.

### uvx-Integration

Das Bootstrap-Script nutzt moderne Tool-Management-Ansätze:

1. **Ansible-Verfügbarkeit prüfen**: Zuerst wird geprüft, ob `ansible-playbook` bereits verfügbar ist
2. **uvx-Unterstützung**: Falls uvx verfügbar ist, wird `uvx --from ansible ansible-playbook` verwendet
3. **Fallback-Installation**: Nur wenn weder Ansible noch uvx verfügbar ist, wird Ansible mit `uv tool install` installiert

```bash
# uvx-Ausführung (bevorzugt)
uvx --from ansible ansible-playbook playbook.yml

# Fallback auf direkte Installation
ansible-playbook playbook.yml
```

### Vorteile der uvx-Integration

- **Keine permanente Installation**: uvx lädt Ansible temporär herunter
- **Immer aktuelle Version**: Jeder Aufruf nutzt die neueste Ansible-Version
- **Saubere Umgebung**: Keine Konflikte mit anderen Python-Paketen
- **Automatischer Fallback**: Funktioniert auch mit bereits installiertem Ansible

### pipx für Python-Tools

Für Python-Tools wird pipx verwendet, um das "externally-managed-environment" Problem von Ubuntu 24.04+ zu lösen:

```yaml
- name: "Install pipx for Python tools"
  ansible.builtin.package:
    name: pipx
    state: present

- name: "Install Python tools via pipx"
  ansible.builtin.shell: |
    pipx install magic-wormhole
    pipx install unp
```

## Hinweise
- Die Struktur ist bewusst einfach gehalten, um Erweiterungen und Wartung zu erleichtern.
- Die Nutzung von Ansible-Standards sorgt für Kompatibilität und Wiederverwendbarkeit.
