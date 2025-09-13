# Tool-Konfiguration

## 🎯 Zentrale Tool-Verwaltung

Alle Tools werden zentral in `roles/modern_tools/defaults/main.yml` verwaltet. Jedes Tool kann einzeln aktiviert/deaktiviert werden.

### ✨ **NEU: Automatische Deinstallation**

Bei `enabled: false` werden Tools nicht nur übersprungen, sondern auch **automatisch deinstalliert**, falls bereits installiert:

- **GitHub-Tools**: Entfernung der Binärdateien aus `~/.local/bin`
- **System-Tools**: Deinstallation via `apt remove`/`dnf remove`
- **pipx-Tools**: Deinstallation via `pipx uninstall`

## 🔧 Ein- und Ausschalten von Tools

### Einzelne Tools deaktivieren

```yaml
# In bootstrap.yml oder als Variable
tools_config:
  btop:
    enabled: false    # Deinstalliert btop (falls installiert)
  termshark:
    enabled: false    # Deinstalliert termshark (falls installiert)
```

**Hinweis**: Bei der nächsten Ausführung werden deaktivierte Tools automatisch entfernt!

### Über Kommandozeile

```bash
# Einzelne Tools ausschalten
ansible-playbook bootstrap.yml -e "target_user=thomas" \
  -e "tools_config={'btop': {'enabled': false}}"

# Nur bestimmte Kategorien installieren
ansible-playbook bootstrap.yml -e "target_user=thomas" \
  --tags "category_file_tools,category_development"
```

## 📋 Tool-Übersicht

### 🛠️ GitHub-Tools (17 Tools)

| Tool | Status | Kategorie | Beschreibung | Alias |
|------|--------|-----------|--------------|--------|
| **lazygit** | ✅ | development | Terminal UI für Git | - |
| **starship** | ✅ | shell | Cross-shell prompt | - |
| **btop** | ✅ | monitoring | Resource monitor (htop replacement) | - |
| **fzf** | ✅ | file_tools | Fuzzy finder | - |
| **bat** | ✅ | file_tools | Cat with syntax highlighting | `cat` |
| **eza** | ✅ | file_tools | Modern ls replacement | `ls` |
| **fd** | ✅ | file_tools | Modern find replacement | - |
| **ripgrep** | ✅ | file_tools | Fast grep replacement | - |
| **dust** | ✅ | file_tools | Modern du replacement | `du` |
| **procs** | ✅ | system | Modern ps replacement | `ps` |
| **zoxide** | ✅ | navigation | Smart cd replacement | - |
| **atuin** | ✅ | shell | Shell history replacement | - |
| **tealdeer** | ✅ | documentation | Fast tldr client | `tldr` |
| **duf** | ✅ | system | Modern df replacement | `df` |
| **gping** | ✅ | network | Ping with graph | - |
| **gk** | ✅ | development | GitKraken CLI | - |
| **topgrade** | ✅ | system | Universal system updater | `tg` |
| **dog** | ❌ | network | Modern dig replacement | `dig` |
| **termshark** | ❌ | network | Terminal Wireshark | - |

### 🖥️ System-Tools (7 Tools)

| Tool | Status | Kategorie | Beschreibung | Installation |
|------|--------|-----------|--------------|--------------|
| **ncdu** | ✅ | system | Interactive disk usage analyzer | Package Manager |
| **lshw** | ✅ | system | Hardware information | Package Manager |
| **mtr** | ✅ | network | Network diagnostic tool | Package Manager |
| **glances** | ✅ | monitoring | System monitoring dashboard | Package Manager |
| **dstat** | ✅ | monitoring | System statistics | Package Manager |
| **gh** | ✅ | development | GitHub CLI | Package Manager |
| **unp** | ✅ | file_tools | Universal archive extractor | pipx |
| **magic-wormhole** | ❌ | network | Secure file transfer | pipx |

## 🏷️ Tag-basierte Installation

### Nach Kategorien

```bash
# Nur File-Tools
ansible-playbook bootstrap.yml -e "target_user=thomas" --tags "category_file_tools"

# Nur Monitoring-Tools  
ansible-playbook bootstrap.yml -e "target_user=thomas" --tags "category_monitoring"

# Nur Network-Tools
ansible-playbook bootstrap.yml -e "target_user=thomas" --tags "category_network"
```

### Einzelne Tools

```bash
# Nur lazygit und starship
ansible-playbook bootstrap.yml -e "target_user=thomas" --tags "lazygit,starship"

# Nur System-Tools
ansible-playbook bootstrap.yml -e "target_user=thomas" --tags "system_tools"
```

## 🎛️ Konfigurationsmöglichkeiten

### Tool-spezifische Deaktivierung

```yaml
# In bootstrap.yml vars: oder group_vars/
tools_config:
  # Monitoring deaktivieren (Server ohne GUI)
  btop:
    enabled: false
  glances:
    enabled: false
    
  # Network-Tools für Desktop nicht nötig
  termshark:
    enabled: false
  dog:
    enabled: false
    
  # History-Tools für einfache Server
  atuin:
    enabled: false
```

### Feature-Toggles

```yaml
# Komplette Features deaktivieren
install_system_tools: false      # Keine System-Tools
create_shell_aliases: false      # Keine Aliases
setup_shell_integration: false   # Keine Shell-Integration
configure_git: false             # Keine Git-Konfiguration
```

## 📝 Beispiel-Konfigurationen

### Minimal-Setup (nur essenzielle Tools)

```yaml
tools_config:
  # Nur essenzielle File-Tools
  bat: { enabled: true }
  eza: { enabled: true }
  fd: { enabled: true }
  ripgrep: { enabled: true }
  
  # Git-Tools
  lazygit: { enabled: true }
  
  # Shell
  starship: { enabled: true }
  
  # Alle anderen deaktiviert
  btop: { enabled: false }
  fzf: { enabled: false }
  dust: { enabled: false }
  procs: { enabled: false }
  # ... etc
```

### Server-Setup (ohne GUI-Tools)

```yaml
tools_config:
  # Server braucht kein btop, aber htop ist OK
  btop: { enabled: false }
  
  # Network-Tools für Server wichtig
  dog: { enabled: true }
  gping: { enabled: true }
  termshark: { enabled: true }
  
  # System-Monitoring
  duf: { enabled: true }
  procs: { enabled: true }
  
  # File-Tools bleiben
  bat: { enabled: true }
  eza: { enabled: true }
  fd: { enabled: true }
  ripgrep: { enabled: true }
```

### Desktop-Setup (alle Tools)

```yaml
# Standardkonfiguration - alle Tools aktiviert
# Keine Anpassung nötig, alle sind enabled: true
```

## 🔄 Aktualisierung der Konfiguration

Die zentrale Konfiguration in `roles/modern_tools/defaults/main.yml` wird automatisch verwendet. Änderungen wirken sich sofort auf die nächste Ausführung aus.

**Automatische Listen:**
- `tools_to_install` - Generiert sich automatisch aus `tools_config` 
- `tools_with_aliases` - Automatisch aus Tools mit `alias`-Definition
- `system_tools_to_install` - Automatisch aus `system_tools`

**Nie manuell bearbeiten!** Diese Listen werden automatisch aus der zentralen Konfiguration generiert.