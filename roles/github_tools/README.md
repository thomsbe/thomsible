# Rolle: github_tools

Diese Meta-Rolle installiert mehrere GitHub-Tools automatisch basierend auf einer konfigurierbaren Liste.

## Features
- **Automatische Installation** mehrerer GitHub-Tools in einem Durchgang
- **Konfigurierbare Tool-Liste** über Variablen
- **Einheitliches Pattern** für alle GitHub-basierten Tools
- **Flexible Konfiguration** für verschiedene Archive-Formate und Binary-Strukturen
- **Batch-Installation** mit zusammengefasster Verifikation
- **Konflikt-Erkennung** verhindert Installationen bei bereits vorhandenen Tools
- **Sauberer Systemzustand** durch Vermeidung mehrfacher Installationsquellen

## Verfügbare Tools

### Standard-Tools (werden automatisch installiert):
- **lazygit**: Terminal UI für Git
- **btop**: Moderner System-Monitor
- **fzf**: Command-line fuzzy finder

### Alle verfügbaren Tools (23 total):

#### GitHub Tools (16):
- **lazygit**: Git Terminal UI
- **btop**: System Monitor
- **fzf**: Fuzzy Finder
- **bat**: Cat mit Syntax-Highlighting (`cat` alias)
- **fd**: Moderne find-Alternative
- **eza**: Moderne ls-Alternative (`ls` alias)
- **rg**: Schneller grep-Ersatz (`grep` alias)
- **dust**: Moderne du-Alternative (`du` alias)
- **procs**: Moderne ps-Alternative (`ps` alias)
- **zoxide**: Intelligente cd-Alternative (`cd` alias)
- **starship**: Cross-Shell Prompt mit Gruvbox-Theme
- **mcfly**: Intelligente History-Search
- **tealdeer**: Praktische tldr-pages (`tldr` alias)
- **duf**: Moderne df-Alternative (`df` alias)
- **gping**: Ping mit grafischer Darstellung
- **dog**: Moderne dig-Alternative (`dig` alias)
- **termshark**: Terminal Wireshark

#### System Tools (7):
- **ncdu**: Interaktive Festplattenbelegung
- **lshw**: Hardware-Informationen
- **mtr**: Netzwerk-Tracing (traceroute + ping)
- **glances**: System-Monitoring deluxe
- **dstat**: System-Statistiken
- **magic-wormhole**: Sichere Datei-Übertragung
- **unp**: Universeller Entpacker

## Variablen

### `github_tools_to_install`
Liste der zu installierenden Tools (Standard: `[lazygit, btop, fzf]`)

```yaml
github_tools_to_install:
  - lazygit
  - btop
  - fzf
```

### `github_tools_install_path`
Installationspfad für GitHub-Tools relativ zum Benutzer-Home (Standard: `.local/bin`)

```yaml
github_tools_install_path: ".local/bin"  # Standard-Pfad für Benutzer-Binaries
# github_tools_install_path: "local/bin"  # Alternative (alter Pfad)
```

### `github_tools_check_conflicts`
Aktiviert/deaktiviert die Überprüfung auf bereits installierte Tools (Standard: `true`)

```yaml
github_tools_check_conflicts: true  # Empfohlen für sauberen Systemzustand
```

### `github_tools_available`
Konfiguration aller verfügbaren Tools mit ihren spezifischen Einstellungen:

```yaml
github_tools_available:
  tool_name:
    repo: "user/repository"
    asset_pattern: "regex_pattern_for_asset"
    archive_extension: "tar.gz|tbz|zip"
    binary_path: "path/to/binary/in/archive"
    description: "Tool description"
```

## Installation
- **Pfad**: `$HOME/local/bin/[tool_name]`
- **Berechtigungen**: 755 (ausführbar)
- **Besitzer**: Ziel-Benutzer

## Verwendung

### Standard-Installation (alle 3 Tools):
```yaml
- hosts: all
  become: true
  roles:
    - thomsible_user
    - ssh_keys
    - user_config
    - git
    - github_tools
```

### Benutzerdefinierte Tool-Auswahl:
```yaml
- hosts: all
  become: true
  vars:
    github_tools_to_install:
      - lazygit
      - fzf
  roles:
    - github_tools
```

### Neue Tools hinzufügen:
```yaml
- hosts: all
  become: true
  vars:
    github_tools_available:
      bat:
        repo: "sharkdp/bat"
        asset_pattern: ".*x86_64-unknown-linux-gnu.tar.gz$"
        archive_extension: "tar.gz"
        binary_path: "bat-*/bat"
        description: "Cat with syntax highlighting"
    github_tools_to_install:
      - lazygit
      - bat
  roles:
    - github_tools
```

## Abhängigkeiten
- Benötigt die Variable `target_user` im Inventory
- Ziel-Benutzer muss bereits existieren
- Internetverbindung für GitHub API und Downloads
- Empfohlen: `user_config` Rolle für PATH-Konfiguration

## Vorteile der Meta-Rolle

### ✅ **Effizienz:**
- Ein Playbook-Aufruf für mehrere Tools
- Gemeinsame Verifikation und Zusammenfassung
- Weniger Redundanz in Playbooks

### ✅ **Wartbarkeit:**
- Zentrale Konfiguration aller Tools
- Einheitliches Pattern für neue Tools
- Einfache Erweiterung ohne Code-Duplikation

### ✅ **Flexibilität:**
- Beliebige Tool-Kombinationen
- Einfache Anpassung pro Host/Gruppe
- Unterstützung verschiedener Archive-Formate

## Konflikt-Behandlung

Die Rolle überprüft automatisch mit `which -a`, ob Tools bereits über andere Quellen installiert sind:

### Vereinfachte Konflikt-Erkennung:
- **`which -a` Analyse**: Findet alle Installationen eines Tools
- **Pfad-Filterung**: Ignoriert den eigenen Installationspfad
- **Intelligente Quellen-Erkennung**: Identifiziert Installationsquelle anhand des Pfads
  - `/usr/bin/` → System package manager
  - `/usr/local/bin/` → Manual installation
  - `/snap/` → Snap package
  - `/.local/bin/` → User installation

### Bei Konflikten:
1. **Installation wird gestoppt** mit detaillierter Fehlermeldung
2. **Exakter Pfad wird angezeigt** wo das Tool bereits installiert ist
3. **Spezifische Entfernungsanweisungen** basierend auf der Quelle
4. **Alternative Optionen** werden vorgeschlagen

### Konflikt-Überprüfung deaktivieren:
```yaml
# Nicht empfohlen - kann zu Systemkonflikten führen
github_tools_check_conflicts: false
```

### Beispiel-Konfliktbehandlung:
```bash
# Tool bereits via apt installiert
sudo apt remove btop

# Tool bereits via snap installiert
sudo snap remove lazygit

# Tool bereits via pip installiert
pip3 uninstall magic-wormhole

# Dann Ansible erneut ausführen
ansible-playbook -i inventory playbook.yml
```

## Template für neue Tools

Um ein neues Tool hinzuzufügen, erweitere `github_tools_available`:

```yaml
new_tool:
  repo: "user/repository"           # GitHub Repository
  asset_pattern: ".*pattern.*$"    # Regex für Asset-Auswahl
  archive_extension: "tar.gz"      # Archive-Format
  binary_path: "path/to/binary"    # Pfad zur Binary im Archive
  description: "Tool description"  # Beschreibung
```
