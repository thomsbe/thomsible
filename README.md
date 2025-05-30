# thomsible

Dieses Projekt sammelt Ansible-Rollen, um Desktop- und Server-Systeme mit den gleichen Tools und Programmen auszustatten. Die Testumgebung basiert auf einem eigenen Docker-Compose-Stack, der verschiedene Distributionen bereitstellt. Das Testen und Ausrollen der Rollen erfolgt mit Ansible direkt gegen diese Container.

## Kernkonzepte

### Zwei-Benutzer-System
- **Ausführender Benutzer**: Konfigurierbar via `ansible_user_name` (Standard: `thomsible`)
- **Ziel-Benutzer**: `target_user` (dessen Konfiguration angepasst wird, z.B. `root`, `thomas`)

### Zwei-Phasen-Deployment
1. **Phase 1**: `thomsible_user` Rolle als root ausführen (Ansible-Benutzer anlegen)
2. **Phase 2**: Weitere Rollen als Ansible-Benutzer mit sudo ausführen (Ziel-Benutzer konfigurieren)

### Konfiguration des Ansible-Benutzers
Der Name des Ansible-Benutzers kann über die Variable `ansible_user_name` angepasst werden:
```yaml
# group_vars/all.yml
ansible_user_name: "automation"  # Statt "thomsible"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... automation@company.com"
```

## 🚀 Lokale Bootstrap-Installation

### Ein-Klick Bootstrap mit Shell-Script

Das einfachste Setup für neue Rechner:

```bash
# Repository klonen
git clone https://github.com/thomsbe/thomsible.git
cd thomsible

# Bootstrap ausführen (installiert uv + Ansible + Tools)
./bootstrap.sh

# Oder nur Tools ohne Ansible-Benutzer
./bootstrap.sh --tools-only

# Für spezifischen Benutzer
./bootstrap.sh --user thomas
```

**Was das Script macht:**
1. **uv installieren** (moderner Python Package Manager)
2. **Ansible installieren** (via uv)
3. **GitHub Token setup** (Umgebungsvariable → .env → gh CLI)
4. **Bootstrap-Playbook ausführen** (mit sudo-Passwort-Abfrage)
5. **Sauberes Token-Management** (keine Commits nötig)

### GitHub Token (für höhere API-Limits)
```bash
# Methode 1: Umgebungsvariable (empfohlen)
export GITHUB_TOKEN=$(gh auth token)
./bootstrap.sh

# Methode 2: .env-Datei
echo "GITHUB_TOKEN=$(gh auth token)" > .env
./bootstrap.sh

# Methode 3: GitHub CLI (automatisch)
gh auth login
./bootstrap.sh
```

### Manuelle Bootstrap-Playbooks

Für neue Rechner gibt es auch direkte Ansible-Playbooks:

#### Vollständiges Bootstrap
```bash
# Komplette Installation mit Ansible-Benutzer
sudo ansible-playbook bootstrap_local.yml --ask-become-pass

# Nur für aktuellen Benutzer (ohne Ansible-Benutzer)
sudo ansible-playbook bootstrap_local.yml -e "skip_ansible_user=true" --ask-become-pass

# Für spezifischen Benutzer
sudo ansible-playbook bootstrap_local.yml -e "target_user=thomas" --ask-become-pass
```

#### Nur Tools installieren
```bash
# Schnelle Installation nur der CLI-Tools
sudo ansible-playbook bootstrap_tools_only.yml --ask-become-pass

# Für spezifischen Benutzer
sudo ansible-playbook bootstrap_tools_only.yml -e "target_user=thomas" --ask-become-pass
```

**Was wird installiert:**
- Moderne CLI-Tools (lazygit, starship, btop, fzf, bat, eza, etc.)
- Fish shell mit PATH-Konfiguration
- Git-Konfiguration
- Shell-Aliases für bessere UX
- Starship-Prompt mit Custom-Theme

## Struktur
- `inventories/`: Enthält getrennte Inventories für Desktop, Server und Docker-Tests
- `group_vars/`: Variablen für alle, Desktop oder Server (SSH-Keys, etc.)
- `roles/`: Hier werden die Rollen für einzelne Tools abgelegt
- `site.yml`: Haupt-Playbook
- `setup_complete.yml`: Komplettes Setup (thomsible_user + ssh_keys)

## Testumgebung mit Docker Compose

Mitgeliefert wird eine `docker-compose.yml`, die Container für folgende Distributionen bereitstellt:
- Debian 11
- Debian 12
- Ubuntu 24.04
- Fedora 42

Container starten:
```sh
docker compose up -d
```

Zugriff auf einen Container:
```sh
docker exec -it debian11 bash
```

## Verfügbare Rollen

### Core-Rollen
- **`thomsible_user`**: Erstellt Ansible-Benutzer mit SSH-Zugang und sudo-Berechtigung
- **`ssh_keys`**: Konfiguriert SSH-Keys für Ziel-Benutzer und deaktiviert Passwort-Login
- **`user_config`**: Installiert fish shell, konfiguriert PATH für GitHub-Tools
- **`git`**: Installiert und konfiguriert Git für Ziel-Benutzer

### GitHub-Tool-Rollen
- **`github_tools`**: Meta-Rolle für moderne CLI-Tools von GitHub und System-Tools

## Installierte Tools

### GitHub-basierte CLI-Tools
Die `github_tools` Rolle installiert automatisch die neuesten Versionen folgender Tools:

#### Git & Development
- **`lazygit`**: Interaktives Git-Interface im Terminal
- **`starship`**: Moderner, anpassbarer Shell-Prompt

#### System Monitoring & Process Management
- **`procs`**: Moderner `ps` Ersatz mit besserer Darstellung
- **`duf`**: Moderner `df` Ersatz für Festplattenspeicher-Anzeige
- **`gping`**: Ping mit grafischer Darstellung

#### File & Text Tools
- **`bat`**: Moderner `cat` Ersatz mit Syntax-Highlighting (alias: `cat`)
- **`eza`**: Moderner `ls` Ersatz mit Icons und Git-Status (alias: `ls`)
- **`fd`**: Moderner `find` Ersatz - schneller und benutzerfreundlicher
- **`ripgrep`**: Extrem schneller `grep` Ersatz für Code-Suche
- **`dust`**: Moderner `du` Ersatz für Verzeichnisgrößen-Analyse

#### Navigation & History
- **`zoxide`**: Intelligenter `cd` Ersatz mit Lernfähigkeit (alias: `cd`)
- **`mcfly`**: Intelligente Shell-History mit Kontext-Suche

#### Documentation & Help
- **`tealdeer`**: Schneller `tldr` Client für praktische Befehlsbeispiele

#### Network & System Tools
- **`dog`**: Moderner `dig` Ersatz für DNS-Abfragen
- **`termshark`**: Terminal-basierter Wireshark für Netzwerk-Analyse

#### System Management
- **`topgrade`**: Universeller System-Updater für alle Package Manager (alias: `tg`)

### System-Tools (via Package Manager)
- **`ncdu`**: Interaktive Festplattenspeicher-Analyse
- **`lshw`**: Hardware-Informationen anzeigen
- **`mtr`**: Kombiniert ping und traceroute
- **`glances`**: System-Monitoring Dashboard
- **`dstat`**: Live System-Statistiken
- **`magic-wormhole`**: Sichere Dateiübertragung zwischen Geräten
- **`unp`**: Universeller Archiv-Extraktor

### Shell-Konfiguration
- **Fish Shell**: Als Standard-Shell für target_user
- **PATH-Konfiguration**: Automatische Integration aller Tools
- **Aliases**: Moderne Ersetzungen für klassische Unix-Tools
- **Starship Prompt**: Mit benutzerdefinierter Konfiguration

### Inventories
- **`inventories/docker/hosts`**: Für initiales Setup (als root)
- **`inventories/docker/hosts_thomsible`**: Für weitere Rollen (als Ansible-Benutzer mit target_user)
- **`inventories/desktop/hosts`**: Für Desktop-Systeme
- **`inventories/server/hosts`**: Für Server-Systeme

## Nutzung

### Erstmaliges Setup
1. Repository klonen
2. SSH-Keys in `group_vars/all.yml` konfigurieren
3. Docker-Container starten:
   ```sh
   docker compose up -d
   ```
4. Komplettes Setup mit allen Tools ausführen:
   ```sh
   ansible-playbook -i inventories/docker/hosts_thomsible setup_complete_with_tools.yml
   ```

### Einzelne Tools installieren
Installiere nur bestimmte GitHub-Tools:
```sh
# Nur bestimmte Tools installieren:
ansible-playbook -i inventories/docker/hosts_thomsible -e "github_tools_to_install=[lazygit,starship,topgrade]" site.yml --tags github_tools

# Alle Tools installieren:
ansible-playbook -i inventories/docker/hosts_thomsible site.yml --tags github_tools
```

### Tool-Nutzung nach Installation
Nach der Installation sind alle Tools über den PATH verfügbar:
```sh
# Neue Shell starten für PATH-Aktivierung:
bash -l
# oder
fish

# Beispiel-Nutzung:
lazygit          # Git-Interface
starship         # Prompt anzeigen
tg               # System-Updates (topgrade alias)
bat README.md    # Datei mit Syntax-Highlighting
eza -la          # Verzeichnis-Listing mit Icons
fd "*.yml"       # Dateien finden
rg "ansible"     # Text in Dateien suchen
```
