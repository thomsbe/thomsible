# Rollen-Dokumentation

## Übersicht der verfügbaren Rollen

### Core-Rollen

#### `thomsible_user`
**Zweck**: Erstellt den Ansible-Benutzer für Automatisierung

**Features**:
- Erstellt Benutzer `thomsible` mit SSH-Zugang
- Konfiguriert passwortloses sudo
- OS-Familie-spezifische Gruppenzuweisung (sudo/wheel)
- Installiert sudo-Paket bei Bedarf (Debian/Ubuntu)
- Deaktiviert Passwort-Login für thomsible

**Variablen**:
- `thomsible_ssh_pubkey`: SSH-Public-Key für thomsible

**OS-Unterstützung**: Debian, Ubuntu, RedHat, Fedora

---

#### `ssh_keys`
**Zweck**: Konfiguriert SSH-Zugang für Ziel-Benutzer

**Features**:
- Fügt SSH-Key zu authorized_keys des Ziel-Benutzers hinzu
- Erstellt .ssh Verzeichnis mit sicheren Berechtigungen
- Deaktiviert Passwort-Login (außer für root)
- Verifiziert SSH-Konfiguration

**Variablen**:
- `target_user`: Ziel-Benutzer (pro Host konfiguriert)
- `tbaer_ssh_pubkey`: SSH-Public-Key für Ziel-Benutzer

**Abhängigkeiten**: Ziel-Benutzer muss existieren

---

#### `user_config`
**Zweck**: Konfiguriert Shell-Umgebung und PATH für Ziel-Benutzer

**Features**:
- Installiert fish shell aus System-Repositories
- Setzt fish als Standard-Shell (außer für root)
- Konfiguriert PATH für `$HOME/local/bin` in fish und bash
- Erstellt .config und tools Verzeichnisse
- Erstellt Beispiel-Konfigurationsdatei

**Variablen**:
- `target_user`: Ziel-Benutzer (pro Host konfiguriert)

**Shell-Konfiguration**:
- Fish: `set -gx PATH $HOME/local/bin $PATH`
- Bash: `export PATH="$HOME/local/bin:$PATH"`

---

#### `git`
**Zweck**: Installiert und konfiguriert Git für Ziel-Benutzer

**Features**:
- Installiert git-Paket auf dem System
- Erstellt grundlegende git-Konfiguration
- Setzt sinnvolle Defaults (main branch, nano editor)
- Konfiguriert Benutzer-spezifische Einstellungen

**Variablen**:
- `target_user`: Ziel-Benutzer (pro Host konfiguriert)

---

#### `github_tools`
**Zweck**: Meta-Rolle für GitHub-basierte Tools

**Features**:
- Installiert mehrere GitHub-Tools in einem Durchgang
- Konfigurierbare Tool-Liste über Variablen
- Einheitliches Pattern für alle GitHub-Tools
- Batch-Installation mit zusammengefasster Verifikation

**Standard-Tools**:
- **lazygit**: Terminal UI für Git
- **btop**: Moderner System-Monitor
- **fzf**: Command-line fuzzy finder

**Variablen**:
- `target_user`: Ziel-Benutzer (pro Host konfiguriert)
- `github_tools_to_install`: Liste der zu installierenden Tools
- `github_tools_available`: Konfiguration aller verfügbaren Tools

**Erweiterung**:
Neue Tools können einfach in `defaults/main.yml` hinzugefügt werden.

## Konzepte

### Target User Pattern
Alle Rollen (außer `thomsible_user`) verwenden das Target User Pattern:

```yaml
- name: Get target user information
  ansible.builtin.getent:
    database: passwd
    key: "{{ target_user }}"
  register: target_user_info

- name: Set target user home directory
  ansible.builtin.set_fact:
    target_user_home: "{{ target_user_info.ansible_facts.getent_passwd[target_user][4] }}"
```

### OS-Familie-Unterstützung
Rollen laden automatisch OS-spezifische Variablen:

```yaml
- name: Include OS-specific variables
  ansible.builtin.include_vars: "{{ ansible_os_family }}.yml"
```

**Variablen-Dateien**:
- `vars/Debian.yml`: Für Debian/Ubuntu
- `vars/RedHat.yml`: Für RedHat/Fedora

## Inventory-Konfiguration

### target_user Variable
```ini
[desktop]
desktop1 ansible_host=192.168.1.10 target_user=thomas

[server]
server1 ansible_host=192.168.1.20 target_user=root
```

### SSH-Keys in group_vars
```yaml
# group_vars/all.yml
thomsible_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... thomsible"
tbaer_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... tbaer"
```

## Deployment-Workflow

### 1. Erstmaliges Setup
```bash
# Als root - erstellt thomsible Benutzer
ansible-playbook -i inventories/docker/hosts site.yml

# Komplettes Setup (thomsible_user + ssh_keys)
ansible-playbook -i inventories/docker/hosts_thomsible setup_complete.yml
```

### 2. Weitere Rollen
```bash
# Als thomsible mit target_user
ansible-playbook -i inventories/docker/hosts_thomsible weitere_rollen.yml
```
