# Rolle: common

Diese Rolle enthält gemeinsame Tasks und Funktionen, die von anderen Rollen verwendet werden.

## Features

### Target User Information
- `get_target_user_info.yml`: Ermittelt Benutzerinformationen inklusive der korrekten Hauptgruppe

## Verwendung

### Target User Pattern
Alle Rollen, die mit `target_user` arbeiten, sollten diese gemeinsame Task verwenden:

```yaml
---
- name: Get target user information
  include_tasks: "{{ playbook_dir }}/roles/common/tasks/get_target_user_info.yml"

# Danach sind folgende Variablen verfügbar:
# - target_user_home: Home-Verzeichnis des Benutzers
# - target_user_group: Gruppen-ID der Hauptgruppe
# - target_user_group_name: Name der Hauptgruppe
```

## Verfügbare Variablen nach get_target_user_info.yml

- `target_user_home`: Home-Verzeichnis des Zielbenutzers
- `target_user_group`: Numerische ID der Hauptgruppe
- `target_user_group_name`: Name der Hauptgruppe

## Warum diese Lösung?

Das direkte Verwenden von `group: "{{ target_user }}"` führt zu Problemen, da:
1. Der Benutzername nicht immer dem Gruppennamen entspricht
2. Verschiedene Systeme unterschiedliche Namenskonventionen haben
3. Die Hauptgruppe eines Benutzers anders heißen kann als der Benutzer selbst

Diese gemeinsame Task löst das Problem durch:
1. Ermittlung der korrekten Hauptgruppen-ID aus `/etc/passwd`
2. Auflösung der Gruppen-ID zum Gruppennamen über `/etc/group`
3. Bereitstellung der korrekten Variablen für alle nachfolgenden Tasks

## Migration bestehender Rollen

Bestehende Rollen können wie folgt migriert werden:

**Vorher:**
```yaml
- name: Get target user information
  ansible.builtin.getent:
    database: passwd
    key: "{{ target_user }}"
  register: target_user_info

- name: Set target user home directory
  ansible.builtin.set_fact:
    target_user_home: "{{ target_user_info.ansible_facts.getent_passwd[target_user][4] }}"

- name: Create directory
  ansible.builtin.file:
    path: "{{ target_user_home }}/example"
    owner: "{{ target_user }}"
    group: "{{ target_user }}"  # PROBLEMATISCH!
```

**Nachher:**
```yaml
- name: Get target user information
  include_tasks: "{{ playbook_dir }}/roles/common/tasks/get_target_user_info.yml"

- name: Create directory
  ansible.builtin.file:
    path: "{{ target_user_home }}/example"
    owner: "{{ target_user }}"
    group: "{{ target_user_group_name }}"  # KORREKT!
```
