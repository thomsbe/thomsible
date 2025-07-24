# Technische Details und Patterns (NEU!)

## Technologiestack
- **Ansible**: Automatisierung und Konfiguration
- **YAML**: Für Playbooks, Variablen und Inventories
- **Modularer Aufbau**: Jede Rolle ist ein eigenständiges Modul
- **Tag-basierte Ausführung**: Einzelne Tools oder Phasen ausführbar

## Neue 3-Rollen-Architektur

### Benutzer-Management
- **Service-User-System**: `service_user` erstellt versteckten Automation-User
- **Explizite Ziel-Definition**: `target_user` muss explizit gesetzt werden (keine Auto-Erkennung!)
- **Drei-Phasen-Deployment**: Service-User → Target-User → Tools
- **Sichere Trennung**: Service-User versteckt vor Login-Managern

### Rollen-Design (NEU!)
- **Eine Datei pro Tool**: Jedes Tool hat eine eigene YAML-Datei (btop.yml, lazygit.yml, etc.)
- **Gemeinsame Installation**: `github_tool_install.yml` für alle GitHub-Tools
- **Shell-Integrationen**: Separate Dateien für Tool-spezifische Shell-Setups
- **OS-Familie-Unterstützung**: Automatische Erkennung und Anpassung für Debian/Ubuntu vs RedHat/Fedora
- **Fedora-Requirements**: Automatische Installation von `python3-libdnf5`
- **Tag-basierte Ausführung**: Einzelne Tools oder Kategorien ausführbar

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
