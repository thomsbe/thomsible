# Technische Details und Patterns

## Technologiestack
- **Ansible**: Automatisierung und Konfiguration
- **YAML**: Für Playbooks, Variablen und Inventories
- **Modularer Aufbau**: Jede Rolle ist ein eigenständiges Modul

## Patterns und Best Practices

### Benutzer-Management
- **Zwei-Benutzer-System**: Trennung von ausführendem Benutzer (`thomsible`) und Ziel-Benutzer (`target_user`)
- **Zwei-Phasen-Deployment**: Erst Ansible-Benutzer anlegen, dann mit diesem arbeiten
- **Pro-Host target_user**: Flexible Konfiguration je nach System (Server: `root`, Desktop: `thomas`)

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
  ansible.builtin.getent:
    database: passwd
    key: "{{ target_user }}"
  register: target_user_info

- name: Set target user home directory
  ansible.builtin.set_fact:
    target_user_home: "{{ target_user_info.ansible_facts.getent_passwd[target_user][4] }}"

- name: Include OS-specific variables
  ansible.builtin.include_vars: "{{ ansible_os_family }}.yml"

# Weitere Tasks hier...
```

### Testing
- Tests werden mit dem bereitgestellten docker-compose-Stack durchgeführt
- Container für Debian 11, Debian 12, Ubuntu 24.04, Fedora 42
- Inventory unter `inventories/docker/hosts_thomsible`
- Playbook mit `ansible-playbook -i inventories/docker/hosts_thomsible test_rolle.yml` ausführen

## Hinweise
- Die Struktur ist bewusst einfach gehalten, um Erweiterungen und Wartung zu erleichtern.
- Die Nutzung von Ansible-Standards sorgt für Kompatibilität und Wiederverwendbarkeit.
