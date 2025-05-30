# Rollen-Dokumentation

## Übersicht der verfügbaren Rollen

### Core-Rollen

#### `thomsible_user`
**Zweck**: Erstellt den konfigurierbaren Ansible-Benutzer für Automatisierung

**Features**:
- Erstellt Ansible-Benutzer mit konfigurierbarem Namen (Standard: `thomsible`)
- Konfiguriert passwortloses sudo
- OS-Familie-spezifische Gruppenzuweisung (sudo/wheel)
- Installiert sudo-Paket bei Bedarf (Debian/Ubuntu)
- Deaktiviert Passwort-Login für Ansible-Benutzer

**Variablen**:
- `ansible_user_name`: Name des Ansible-Benutzers (Standard: "thomsible")
- `ansible_user_ssh_pubkey`: SSH-Public-Key für Ansible-Benutzer
- `thomsible_ssh_pubkey`: Legacy-Variable (Rückwärtskompatibilität)

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
**Zweck**: Meta-Rolle für moderne CLI-Tools von GitHub und System-Tools

**Features**:
- Installiert 17 moderne CLI-Tools automatisch
- GitHub-Tools: Lädt neueste Releases von GitHub API
- System-Tools: Installiert via Package Manager und pip
- Automatische PATH-Konfiguration für alle Tools
- Shell-Aliases für moderne Ersetzungen klassischer Unix-Tools
- Starship-Prompt-Konfiguration

**GitHub-Tools (12 Tools)**:
- **lazygit**: Interaktives Git-Interface
- **starship**: Moderner Shell-Prompt
- **procs**: Moderner `ps` Ersatz
- **duf**: Moderner `df` Ersatz
- **gping**: Ping mit grafischer Darstellung
- **bat**: Moderner `cat` Ersatz (alias: `cat`)
- **eza**: Moderner `ls` Ersatz (alias: `ls`)
- **fd**: Moderner `find` Ersatz
- **ripgrep**: Extrem schneller `grep` Ersatz
- **dust**: Moderner `du` Ersatz
- **zoxide**: Intelligenter `cd` Ersatz (alias: `cd`)
- **mcfly**: Intelligente Shell-History
- **tealdeer**: Schneller `tldr` Client
- **dog**: Moderner `dig` Ersatz
- **termshark**: Terminal-Wireshark
- **topgrade**: System-Updater (alias: `tg`)

**System-Tools (7 Tools)**:
- **ncdu**: Interaktive Festplattenspeicher-Analyse
- **lshw**: Hardware-Informationen
- **mtr**: Kombiniert ping und traceroute
- **glances**: System-Monitoring Dashboard
- **dstat**: Live System-Statistiken
- **magic-wormhole**: Sichere Dateiübertragung (via pip)
- **unp**: Universeller Archiv-Extraktor (via pip)

**Variablen**:
- `target_user`: Ziel-Benutzer (pro Host konfiguriert)
- `github_tools_to_install`: Liste der zu installierenden GitHub-Tools
- `github_tools_available`: Konfiguration aller verfügbaren Tools
- `github_token`: Optional für höhere API-Rate-Limits

**Installation**:
- GitHub-Tools: `$HOME/local/bin/` (automatisch im PATH)
- System-Tools: Standard-Paketpfade
- Aliases: Fish und Bash Shell-Konfiguration

**Abhängigkeiten**:
- `user_config` Rolle für PATH-Konfiguration
- GitHub API-Zugang (optional mit Token für höhere Limits)

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
ansible_user_name: "thomsible"  # Oder anderer Name
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... ansible-user"
tbaer_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... tbaer"
```

## Deployment-Workflow

### 1. Erstmaliges Setup
```bash
# Als root - erstellt Ansible-Benutzer
ansible-playbook -i inventories/docker/hosts site.yml

# Komplettes Setup (thomsible_user + ssh_keys)
ansible-playbook -i inventories/docker/hosts_thomsible setup_complete.yml
```

### 2. Weitere Rollen
```bash
# Als Ansible-Benutzer mit target_user
ansible-playbook -i inventories/docker/hosts_thomsible weitere_rollen.yml
```
