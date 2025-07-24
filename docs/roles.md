# Rollen-Dokumentation

## 3-Rollen-Struktur

### Hauptrollen

#### `service_user` (NEU!)
**Zweck**: Erstellt thomsible Service-User für Ansible-Automatisierung

**Features**:
- Erstellt Service-User mit konfigurierbarem Namen (Standard: `thomsible`)
- **Versteckt vor Login-Managern** (KDE/GNOME Login-Bildschirm)
- **Shell**: `/usr/sbin/nologin` oder `/sbin/nologin` (keine interaktive Anmeldung)
- SSH-Key-basierte Authentifizierung (kein Passwort-Login)
- Konfiguriert passwortloses sudo
- OS-Familie-spezifische Gruppenzuweisung (sudo/wheel)
- **Fedora-Requirements**: Installiert `python3-libdnf5` automatisch

**Variablen**:
- `ansible_user_name`: Name des Service-Users (Standard: "thomsible")
- `ansible_user_ssh_pubkey`: SSH-Public-Key für Service-User

**OS-Unterstützung**: Debian, Ubuntu, RedHat, Fedora
**Tags**: `service_user`, `ssh_config`, `sudo_config`

---

#### `target_user_config` (NEU!)
**Zweck**: Konfiguriert den echten Benutzer mit moderner Shell-Umgebung

**Features**:
- **Explizite Benutzer-Definition** (KEINE Auto-Erkennung mehr!)
- **Fish shell** als Standard-Shell (außer für root)
- **PATH-Konfiguration** für `~/.local/bin` (fish + bash)
- **Basis-Verzeichnisse** erstellen (.config, .local/bin, tools)
- **Sichere Berechtigungen** für alle erstellten Dateien
- **Fedora-Requirements**: Installiert `python3-libdnf5` automatisch

**Variablen**:
- `target_user`: Der zu konfigurierende Benutzer (MUSS explizit gesetzt werden!)

**Validierung**: Fehler wenn `target_user` nicht definiert
**Tags**: `target_user_config`, `shell_config`, `path_config`

---

#### `modern_tools` (NEU!)
**Zweck**: Installiert moderne CLI-Tools mit einzelnen Tool-Dateien

**Features**:
- **18 moderne GitHub-Tools** (lazygit, starship, btop, fzf, bat, eza, etc.)
- **Einzelne Tool-Dateien** (btop.yml, lazygit.yml, etc.) für bessere Organisation
- **Gemeinsame GitHub-Installation** (`github_tool_install.yml`)
- **System-Tools** via Package Manager (ncdu, lshw, mtr, etc.)
- **Shell-Integration** (atuin, starship, zoxide)
- **Git-Konfiguration** für target_user
- **Shell-Aliases** für moderne Ersetzungen
- **Konflikt-Erkennung** verhindert doppelte Installationen
- **Fedora-Requirements**: Installiert `python3-libdnf5` automatisch

**Variablen**:
- `target_user`: Der zu konfigurierende Benutzer (MUSS explizit gesetzt werden!)
- `tools_to_install`: Liste der zu installierenden Tools
- `github_token`: Optional für höhere GitHub API-Limits
- `create_shell_aliases`: Shell-Aliases erstellen (Standard: true)

**Tags**: `modern_tools`, `github_tools`, `system_tools`, `shell_integration`, `git_config`
**Einzelne Tool-Tags**: `lazygit`, `starship`, `btop`, `fzf`, `bat`, `eza`, etc.

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
- **atuin**: Magische Shell-History mit Sync
- **tealdeer**: Schneller `tldr` Client
- **dog**: Moderner `dig` Ersatz
- **termshark**: Terminal-Wireshark
- **topgrade**: System-Updater (alias: `tg`)

**System-Tools (5 Tools via Package Manager)**:
- **ncdu**: Interaktive Festplattenspeicher-Analyse
- **lshw**: Hardware-Informationen
- **mtr**: Kombiniert ping und traceroute
- **glances**: System-Monitoring Dashboard
- **dstat**: Live System-Statistiken

**Python-Tools (2 Tools via pipx)**:
- **magic-wormhole**: Sichere Dateiübertragung
- **unp**: Universeller Archiv-Extraktor

**Hinweis:** pipx wird verwendet, um das "externally-managed-environment" Problem von Ubuntu 24.04+ zu lösen.

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
Alle Rollen (außer `thomsible_user`) verwenden das Target User Pattern mit korrekter Gruppenverwaltung:

```yaml
- name: Get target user information
  include_tasks: "{{ playbook_dir }}/roles/common/tasks/get_target_user_info.yml"

# Verfügbare Variablen:
# - target_user_home: Home-Verzeichnis des Benutzers
# - target_user_group: Gruppen-ID der Hauptgruppe
# - target_user_group_name: Name der Hauptgruppe (für Berechtigungen verwenden!)
```

**Wichtig:** Verwende immer `target_user_group_name` für Gruppenzuweisungen, niemals `target_user`!

### Neue common-Rolle

Die `common`-Rolle stellt gemeinsame Tasks zur Verfügung:

- **`get_target_user_info.yml`**: Ermittelt Benutzerinformationen inklusive korrekter Hauptgruppe
- Löst das Problem der falschen Gruppenverwaltung
- Sollte von allen target_user-aware Rollen verwendet werden

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
