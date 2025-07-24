# thomsible

Dieses Projekt sammelt Ansible-Rollen, um Desktop- und Server-Systeme mit den gleichen Tools und Programmen auszustatten. Die Testumgebung basiert auf einem eigenen Docker-Compose-Stack, der verschiedene Distributionen bereitstellt. Das Testen und Ausrollen der Rollen erfolgt mit Ansible direkt gegen diese Container.

## Kernkonzepte

### Drei-Rollen-System (NEU!)
- **`service_user`**: Erstellt thomsible Service-User (versteckt vor Login)
- **`target_user_config`**: Konfiguriert echten Benutzer (Fish shell, PATH)
- **`modern_tools`**: Installiert 18 moderne CLI-Tools (einzelne Dateien pro Tool)

⚠️ **WICHTIG**: `target_user` muss explizit gesetzt werden - keine Auto-Erkennung mehr!

### Drei-Phasen-Deployment
1. **Phase 1**: `service_user` - Erstellt thomsible Service-User (versteckt)
2. **Phase 2**: `target_user_config` - Konfiguriert echten Benutzer
3. **Phase 3**: `modern_tools` - Installiert moderne CLI-Tools

### Konfiguration des Ansible-Benutzers
Der Name des Ansible-Benutzers kann über die Variable `ansible_user_name` angepasst werden:
```yaml
# group_vars/all.yml
ansible_user_name: "automation"  # Statt "thomsible"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... automation@company.com"
```

## ✨ Features

- **🚀 uvx-Integration**: Nutzt uvx für Ansible-Ausführung wenn verfügbar, Fallback auf direkte Installation
- **🔧 Automatische Tool-Installation**: 18 moderne CLI-Tools von GitHub Releases + System-Tools
- **🛡️ Intelligente Konflikterkennung**: Erkennt bereits installierte Tools und vermeidet Duplikate
- **👥 Korrekte Gruppenverwaltung**: Ermittelt automatisch die Hauptgruppe des Zielbenutzers
- **🌍 Multi-OS-Unterstützung**: Debian/Ubuntu und RedHat/Fedora
- **⚙️ Flexible Benutzer-Konfiguration**: Konfiguriert Tools für beliebige Benutzer
- **🔗 GitHub API-Integration**: Lädt automatisch neueste Versionen mit Token-Unterstützung
- **🐚 Shell-Integration**: Fish und Bash mit PATH-Konfiguration und Aliases
- **🐍 pipx-Integration**: Python-Tools werden sicher via pipx installiert (Ubuntu 24.04+ kompatibel)

## 🚀 Lokale Bootstrap-Installation

### Ein-Klick Bootstrap mit Shell-Script

Das einfachste Setup für neue Rechner:

```bash
# Repository klonen
git clone https://github.com/thomsbe/thomsible.git
cd thomsible

# Bootstrap ausführen (target_user MUSS gesetzt werden!)
./bootstrap.sh --user thomas

# Oder nur Tools ohne Service-Benutzer
./bootstrap.sh --tools-only --user thomas

# Ohne Service-User
./bootstrap.sh --skip-service-user --user thomas
```

**Was das Script macht:**
1. **uv installieren** (moderner Python Package Manager)
2. **Ansible-Verfügbarkeit prüfen** (bereits installiert oder uvx verfügbar)
3. **uvx-Integration** (nutzt `uvx --from ansible ansible-playbook` wenn verfügbar)
4. **GitHub Token setup** (Umgebungsvariable → .env → gh CLI)
5. **Bootstrap-Playbook ausführen** (mit sudo-Passwort-Abfrage)
6. **Korrekte Gruppenverwaltung** (ermittelt automatisch Hauptgruppe des Zielbenutzers)
7. **pipx für Python-Tools** (Ubuntu 24.04+ kompatibel)

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

#### Vollständiges Bootstrap (NEU!)
```bash
# Komplette Installation mit Service-User (target_user ERFORDERLICH!)
sudo ansible-playbook bootstrap_new.yml -e "target_user=thomas" --ask-become-pass

# Ohne Service-User
sudo ansible-playbook bootstrap_new.yml -e "target_user=thomas" -e "create_service_user=false" --ask-become-pass

# Mit Tags nur bestimmte Phasen
sudo ansible-playbook bootstrap_new.yml -e "target_user=thomas" --tags "modern_tools" --ask-become-pass
```

#### Nur Tools installieren (NEU!)
```bash
# Schnelle Installation nur der CLI-Tools
sudo ansible-playbook bootstrap_tools_new.yml -e "target_user=thomas" --ask-become-pass

# Mit einzelnen Tools
sudo ansible-playbook bootstrap_tools_new.yml -e "target_user=thomas" --tags "lazygit,starship,btop" --ask-become-pass
```

**Was wird installiert:**
- **18 moderne CLI-Tools** (lazygit, starship, btop, fzf, bat, eza, fd, ripgrep, dust, procs, zoxide, mcfly, tealdeer, duf, gping, dog, termshark, topgrade)
- **System-Tools** (ncdu, glances, mtr, dstat) via apt/dnf
- **Python-Tools** (magic-wormhole, unp) via pipx
- **Fish shell** mit PATH-Konfiguration
- **Git-Konfiguration** mit sinnvollen Defaults
- **Shell-Aliases** für bessere UX (bat→cat, eza→ls, etc.)
- **Starship-Prompt** mit Custom-Theme

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

## Verfügbare Rollen (NEU!)

### Neue 3-Rollen-Struktur
- **`service_user`**: Erstellt thomsible Service-User (versteckt vor Login, SSH-Keys, sudo)
- **`target_user_config`**: Konfiguriert echten Benutzer (Fish shell, PATH, explizite Definition)
- **`modern_tools`**: Installiert moderne CLI-Tools (einzelne Dateien pro Tool mit Tags)

### Legacy-Rollen (deprecated)
- **`thomsible_user`**: ⚠️ Ersetzt durch `service_user`
- **`ssh_keys`**: ⚠️ Integriert in `service_user`
- **`user_config`**: ⚠️ Ersetzt durch `target_user_config`
- **`git`**: ⚠️ Integriert in `modern_tools`
- **`github_tools`**: ⚠️ Ersetzt durch `modern_tools`

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
- **`zoxide`**: Intelligenter `cd` Ersatz mit Lernfähigkeit (Shell-Integration)
- **`atuin`**: Magische Shell-History mit Sync-Funktionalität

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
