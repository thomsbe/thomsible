# Bootstrap für lokale Installation

Thomsible bietet verschiedene Wege, um auf neuen Rechnern schnell eine moderne Entwicklungsumgebung einzurichten.

## 🚀 Ein-Klick Bootstrap mit Shell-Script

Das **einfachste und empfohlene** Setup für neue Rechner:

```bash
# Repository klonen
git clone https://github.com/thomsbe/thomsible.git
cd thomsible

# Bootstrap ausführen
./bootstrap.sh
```

### Was das Script macht

1. **Systemprüfung**: Überprüft OS und Voraussetzungen
2. **uv Installation**: Installiert den modernen Python Package Manager
3. **Ansible Installation**: Installiert Ansible via uv
4. **GitHub Token Setup**: Automatisches Token-Setup (falls gh CLI verfügbar)
5. **Bootstrap-Playbook**: Führt Ansible-Playbook mit sudo-Passwort-Abfrage aus
6. **Cleanup**: Entfernt temporäre Tokens

### Script-Optionen

```bash
./bootstrap.sh                    # Vollständiges Bootstrap
./bootstrap.sh --tools-only       # Nur CLI-Tools (ohne Ansible-Benutzer)
./bootstrap.sh --user thomas      # Für spezifischen Benutzer
./bootstrap.sh --skip-ansible-user # Ohne Ansible-Benutzer
./bootstrap.sh --verbose          # Verbose Ansible-Ausgabe
./bootstrap.sh --help             # Hilfe anzeigen
```

### Vorteile des Shell-Scripts

- ✅ **Ein Befehl**: Alles automatisch installiert
- ✅ **Keine Vorkenntnisse**: Ansible wird automatisch installiert
- ✅ **Moderne Tools**: Nutzt uv statt pip
- ✅ **Sicher**: Automatisches Token-Cleanup
- ✅ **Flexibel**: Viele Konfigurationsoptionen
- ✅ **Robust**: Fehlerbehandlung und Validierung

## 📋 Manuelle Bootstrap-Playbooks

Für Benutzer, die bereits Ansible installiert haben:

## Übersicht

| Playbook | Zweck | Ansible-User | Zielgruppe |
|----------|-------|--------------|------------|
| `bootstrap_local.yml` | Vollständige Installation | ✅ Ja | Vollständige Einrichtung |
| `bootstrap_tools_only.yml` | Nur CLI-Tools | ❌ Nein | Schnelle Tool-Installation |

## bootstrap_local.yml

### Zweck
Vollständige Einrichtung einer neuen Maschine mit allen thomsible-Features.

### Was wird installiert
- **Ansible-Benutzer** (konfigurierbar, Standard: `thomsible`)
- **SSH-Konfiguration** für Ziel-Benutzer
- **Fish shell** mit moderner PATH-Konfiguration
- **Git** mit Benutzer-Konfiguration
- **18 moderne CLI-Tools** von GitHub
- **Shell-Aliases** für bessere UX
- **Starship-Prompt** mit Custom-Theme

### Verwendung

```bash
# Standard-Installation (aktueller Benutzer als Ziel)
sudo ansible-playbook bootstrap_local.yml

# Ohne Ansible-Benutzer (nur Tools für aktuellen Benutzer)
sudo ansible-playbook bootstrap_local.yml -e "skip_ansible_user=true"

# Für spezifischen Benutzer
sudo ansible-playbook bootstrap_local.yml -e "target_user=thomas"

# Mit anderem Ansible-Benutzernamen
sudo ansible-playbook bootstrap_local.yml -e "ansible_user_name=automation"
```

### Konfiguration

```yaml
# Variablen können überschrieben werden
target_user: "thomas"           # Ziel-Benutzer
skip_ansible_user: false       # Ansible-Benutzer überspringen?
github_tools_create_aliases: true  # Shell-Aliases aktivieren
github_tools_check_conflicts: true # Konflikt-Erkennung
```

## bootstrap_tools_only.yml

### Zweck
Schnelle Installation nur der modernen CLI-Tools ohne zusätzliche Benutzer.

### Was wird installiert
- **8 essenzielle CLI-Tools** (lazygit, starship, btop, fzf, bat, eza, ripgrep, fd)
- **Fish shell** mit PATH-Konfiguration
- **Git** mit Benutzer-Konfiguration
- **Shell-Aliases** für bessere UX
- **Starship-Prompt** mit Custom-Theme

### Verwendung

```bash
# Standard-Installation
sudo ansible-playbook bootstrap_tools_only.yml

# Für spezifischen Benutzer
sudo ansible-playbook bootstrap_tools_only.yml -e "target_user=thomas"
```

### Tool-Liste anpassen

```bash
# Nur bestimmte Tools installieren
sudo ansible-playbook bootstrap_tools_only.yml -e "github_tools_to_install=['lazygit','starship','btop']"

# Ohne Aliases
sudo ansible-playbook bootstrap_tools_only.yml -e "github_tools_create_aliases=false"
```

## Workflow für neue Rechner

### 1. Repository klonen
```bash
git clone https://github.com/thomsbe/thomsible.git
cd thomsible
```

### 2. Ansible installieren
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y ansible

# Fedora
sudo dnf install -y ansible

# macOS
brew install ansible
```

### 3. Bootstrap ausführen
```bash
# Vollständige Installation
sudo ansible-playbook bootstrap_local.yml

# Oder nur Tools
sudo ansible-playbook bootstrap_tools_only.yml
```

### 4. Shell neustarten
```bash
# Logout/Login oder
exec $SHELL
```

## Installierte Tools

### GitHub CLI Tools
- **lazygit**: Terminal UI für Git
- **starship**: Moderner Shell-Prompt
- **btop**: System-Monitor
- **fzf**: Fuzzy Finder (Ctrl+R für History)
- **bat**: Besseres `cat` mit Syntax-Highlighting
- **eza**: Modernes `ls` mit Icons
- **ripgrep**: Schnelles `grep`
- **fd**: Besseres `find`
- **dust**: Disk-Usage-Analyzer
- **procs**: Modernes `ps`
- **zoxide**: Intelligentes `cd`
- **mcfly**: AI-powered Shell-History
- **tealdeer**: Schnelle `man`-Pages
- **duf**: Modernes `df`
- **gping**: `ping` mit Graphen
- **dog**: DNS-Lookup-Tool
- **termshark**: Terminal Wireshark
- **topgrade**: System-Update-Manager

### Shell-Aliases (optional)
```bash
# Wenn github_tools_create_aliases=true
bat → cat    # Syntax-Highlighting
eza → ls     # Moderne Dateiliste
tg → topgrade # System-Updates
```

## Troubleshooting

### Häufige Probleme

**1. Permission denied**
```bash
# Lösung: Mit sudo ausführen
sudo ansible-playbook bootstrap_local.yml
```

**2. GitHub API Rate Limit**
```bash
# Lösung: GitHub Token setzen
gh auth token
# Token in group_vars/all.yml eintragen
```

**3. Tool-Konflikte**
```bash
# Lösung: Bestehende Tools entfernen
sudo apt remove btop  # Beispiel
# Dann Bootstrap erneut ausführen
```

**4. PATH nicht aktualisiert**
```bash
# Lösung: Shell neustarten
exec $SHELL
# Oder logout/login
```

### Logs und Debugging

```bash
# Verbose-Modus für Debugging
sudo ansible-playbook bootstrap_local.yml -v

# Nur bestimmte Tasks ausführen
sudo ansible-playbook bootstrap_local.yml --tags "github_tools"

# Dry-run (nur anzeigen, was passieren würde)
sudo ansible-playbook bootstrap_local.yml --check
```

## Anpassungen

### Eigene Tool-Liste
```yaml
# In bootstrap_local.yml anpassen
github_tools_to_install:
  - lazygit
  - starship
  - btop
  # Weitere Tools hinzufügen/entfernen
```

### Andere Installationspfade
```yaml
# In group_vars/all.yml oder als Variable
github_tools_install_path: "bin"        # ~/bin
github_tools_install_path: ".local/bin" # ~/.local/bin (Standard)
```

### SSH-Keys anpassen
```yaml
# In group_vars/all.yml
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... your-key"
tbaer_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... target-user-key"
```

## Sicherheitshinweise

- Bootstrap-Playbooks benötigen sudo-Rechte
- SSH-Keys werden aus group_vars/all.yml gelesen
- GitHub-Token sollten nicht in Git gespeichert werden
- Konflikt-Erkennung verhindert versehentliche Überschreibungen
