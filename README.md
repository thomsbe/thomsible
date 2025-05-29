# thomsible

Dieses Projekt sammelt Ansible-Rollen, um Desktop- und Server-Systeme mit den gleichen Tools und Programmen auszustatten. Die Testumgebung basiert auf einem eigenen Docker-Compose-Stack, der verschiedene Distributionen bereitstellt. Das Testen und Ausrollen der Rollen erfolgt mit Ansible direkt gegen diese Container.

## Kernkonzepte

### Zwei-Benutzer-System
- **Ausführender Benutzer**: `thomsible` (für Ansible-Verbindungen und Automatisierung)
- **Ziel-Benutzer**: `target_user` (dessen Konfiguration angepasst wird, z.B. `root`, `thomas`)

### Zwei-Phasen-Deployment
1. **Phase 1**: `thomsible_user` Rolle als root ausführen (Ansible-Benutzer anlegen)
2. **Phase 2**: Weitere Rollen als `thomsible` mit sudo ausführen (Ziel-Benutzer konfigurieren)

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
- **`inventories/docker/hosts_thomsible`**: Für weitere Rollen (als thomsible mit target_user)
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
