# 🚀 Thomsible Bootstrap

Ein-Klick-Setup für moderne CLI-Tools auf neuen Rechnern.

## Schnellstart

```bash
# 1. Repository klonen
git clone https://github.com/thomsbe/thomsible.git
cd thomsible

# 2. Bootstrap ausführen
./bootstrap.sh
```

Das war's! 🎉

## Was passiert?

1. **uv wird installiert** (moderner Python Package Manager)
2. **Ansible wird installiert** (via uv)
3. **GitHub Token wird automatisch gesetzt** (falls gh CLI verfügbar)
4. **Moderne CLI-Tools werden installiert** (18 Tools in ~/.local/bin)
5. **Shell wird konfiguriert** (Fish + Bash mit PATH und Aliases)
6. **Git wird konfiguriert**
7. **Starship-Prompt wird eingerichtet**

## Optionen

```bash
./bootstrap.sh --tools-only       # Nur Tools, kein Ansible-Benutzer
./bootstrap.sh --user thomas      # Für spezifischen Benutzer
./bootstrap.sh --verbose          # Detaillierte Ausgabe
./bootstrap.sh --help             # Alle Optionen anzeigen
```

## Installierte Tools

Nach dem Bootstrap haben Sie diese modernen CLI-Tools:

| Tool | Beschreibung | Ersetzt |
|------|-------------|---------|
| **lazygit** | Terminal Git UI | git (komplex) |
| **starship** | Moderner Shell-Prompt | PS1 |
| **btop** | System-Monitor | htop/top |
| **fzf** | Fuzzy Finder | Ctrl+R |
| **bat** | Syntax-Highlighting | cat |
| **eza** | Modernes ls | ls |
| **ripgrep** | Schnelles grep | grep |
| **fd** | Besseres find | find |
| **dust** | Disk-Usage | du |
| **procs** | Modernes ps | ps |
| **zoxide** | Intelligentes cd | cd |
| **mcfly** | AI Shell-History | history |
| **tealdeer** | Schnelle man-Pages | man |
| **duf** | Modernes df | df |
| **gping** | Ping mit Graphen | ping |
| **dog** | DNS-Lookup | dig |
| **termshark** | Terminal Wireshark | wireshark |
| **topgrade** | System-Updates | apt/dnf |

## Shell-Aliases (optional)

Wenn aktiviert, erhalten Sie diese praktischen Aliases:

```bash
bat → cat    # Syntax-Highlighting für Dateien
eza → ls     # Moderne Dateiliste mit Icons
tg → topgrade # Ein-Klick System-Updates
```

## Nach dem Bootstrap

1. **Shell neustarten**: `exec $SHELL`
2. **Tools testen**: `lazygit --version`, `btop --version`
3. **Neue Features ausprobieren**:
   - `lazygit` - Git Terminal UI
   - `btop` - System Monitor
   - `Ctrl+R` - Fuzzy History Search
   - `bat README.md` - Datei mit Syntax-Highlighting
   - `eza` - Moderne Dateiliste

## Systemvoraussetzungen

- **Linux** oder **macOS**
- **curl** (für uv-Installation)
- **sudo-Berechtigung** (für Systemkonfiguration)
- **Internet-Verbindung** (für Downloads)

## Troubleshooting

### "Permission denied"
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

### "GitHub API Rate Limit"
```bash
# GitHub CLI installieren und authentifizieren
gh auth login
./bootstrap.sh  # Automatisches Token-Setup
```

### "Tool conflicts detected"
```bash
# Bestehende Tools entfernen
sudo apt remove btop  # Beispiel
./bootstrap.sh  # Erneut ausführen
```

### "PATH not updated"
```bash
# Shell neustarten
exec $SHELL
# Oder logout/login
```

## Erweiterte Nutzung

### Nur bestimmte Tools
```bash
# bootstrap_tools_only.yml anpassen
github_tools_to_install:
  - lazygit
  - starship
  - btop
```

### Andere Installationspfade
```bash
# In group_vars/all.yml
github_tools_install_path: "bin"  # ~/bin statt ~/.local/bin
```

### Für Unternehmen
```bash
# Ansible-Benutzer anpassen
./bootstrap.sh --user company-user
# Oder in group_vars/all.yml:
ansible_user_name: "automation"
```

## Sicherheit

- ✅ **Sudo-Passwort wird abgefragt** (keine passwortlose sudo-Rechte nötig)
- ✅ **GitHub Token wird automatisch entfernt** nach Installation
- ✅ **Konflikt-Erkennung** verhindert versehentliche Überschreibungen
- ✅ **Quellcode ist einsehbar** (Open Source)

## Support

- 📖 **Dokumentation**: `docs/` Ordner
- 🐛 **Issues**: GitHub Issues
- 💡 **Features**: Pull Requests willkommen

---

**Viel Spaß mit Ihrer modernen CLI-Umgebung!** 🚀
