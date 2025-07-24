# Status und Roadmap

## Aktueller Status (Stand: 2024-12-19)

### ✅ Neue 3-Rollen-Struktur implementiert

#### Hauptrollen
- **service_user**: Thomsible Service-User (versteckt vor Login) ✅
- **target_user_config**: Echter Benutzer (Fish shell, PATH, explizit) ✅
- **modern_tools**: 18 moderne CLI-Tools (einzelne Dateien pro Tool) ✅

#### Sicherheitsverbesserungen
- **Explizite Benutzer-Definition**: Keine gefährliche Auto-Erkennung ✅
- **Service-User versteckt**: Nicht in KDE/GNOME Login-Listen ✅
- **Fedora-Requirements**: Automatische python3-libdnf5 Installation ✅
- **Starship aus yast**: Konfiguration aus dotfile sync ✅

#### GitHub Tools (18 Tools)
- **lazygit**: Terminal UI für Git ✅
- **starship**: Cross-shell prompt (yast config) ✅
- **btop**: System monitor ✅
- **fzf**: Fuzzy finder ✅
- **bat**: Cat mit Syntax-Highlighting ✅
- **eza**: Modernes ls ✅
- **fd**: Moderner find ✅
- **ripgrep**: Schneller grep ✅
- **dust**: Moderner du ✅
- **procs**: Moderner ps ✅
- **zoxide**: Intelligenter cd (mit --cmd cd) ✅
- **atuin**: Shell-History mit Sync (ersetzt mcfly) ✅
- **tealdeer**: tldr pages ✅
- **duf**: Moderner df ✅
- **gping**: Ping mit Graph ✅
- **dog**: Moderner dig ✅
- **termshark**: Terminal Wireshark ✅
- **topgrade**: System-Update-Manager ✅

#### System Tools (7 Tools)
- **ncdu**: Interaktive Disk-Usage ✅
- **lshw**: Hardware-Info ✅
- **mtr**: Network tracing ✅
- **glances**: System monitoring ✅
- **dstat**: System statistics ✅
- **magic-wormhole**: Sichere Dateiübertragung ✅
- **unp**: Universeller Unpacker ✅

#### Tag-basierte Ausführung
- **Einzelne Tools**: lazygit, starship, btop, etc. ✅
- **Kategorien**: github_tools, system_tools, shell_integration ✅
- **Phasen**: phase1 (service_user), phase2 (target_user), phase3 (tools) ✅

#### Bootstrap-Funktionalität
- **Lokales Bootstrap**: Vollständige lokale Installation ✅
- **Tools-Only**: Nur CLI-Tools ohne Service-User ✅
- **Explizite Benutzer-Definition**: target_user muss gesetzt werden ✅
- **OS-Familie-Unterstützung**: Debian/Ubuntu + RedHat/Fedora ✅

### 🧹 Aufgeräumt und entfernt

#### Gelöschte Legacy-Rollen
- ~~thomsible_user~~ → service_user ✅
- ~~ssh_keys~~ → integriert in service_user ✅
- ~~user_config~~ → target_user_config ✅
- ~~git~~ → integriert in modern_tools ✅
- ~~github_tools~~ → modern_tools ✅

#### Gelöschte Legacy-Dateien
- ~~bootstrap_local.yml~~ → bootstrap.yml ✅
- ~~bootstrap_tools_only.yml~~ → bootstrap_tools.yml ✅
- ~~starship.toml~~ → aus yast dotfile sync ✅
- ~~starship_simple.toml~~ → starship_basic.toml (fallback) ✅

### 🎯 Aktuelle Architektur

```
thomsible/
├── roles/
│   ├── service_user/          # Thomsible Service-User
│   ├── target_user_config/    # Echter Benutzer
│   ├── modern_tools/          # CLI-Tools (einzelne Dateien)
│   └── common/                # Gemeinsame Tasks
├── bootstrap.yml              # Vollständiges Bootstrap
├── bootstrap_tools.yml        # Nur Tools
└── bootstrap.sh               # Wrapper-Skript
```

### 🚀 Nächste Schritte

#### Geplante Verbesserungen
- [ ] Weitere moderne CLI-Tools hinzufügen
- [ ] Desktop vs Server Differenzierung
- [ ] Remote-System-Integration testen
- [ ] Performance-Optimierungen

#### Mögliche Erweiterungen
- [ ] Vim/Neovim-Konfiguration
- [ ] Firefox-Profile
- [ ] Development-Environment-Setups
- [ ] Container-Tools (podman, docker-compose)

## Erledigte Meilensteine ✅

- ✅ **Projektstruktur** nach Best-Practice angelegt
- ✅ **3-Rollen-Architektur** implementiert
- ✅ **Sicherheitsprobleme** behoben (Auto-Erkennung entfernt)
- ✅ **Tag-basierte Ausführung** implementiert
- ✅ **Einzelne Tool-Dateien** für bessere Organisation
- ✅ **Starship-Integration** mit yast dotfile sync
- ✅ **Zoxide-Problem** behoben (--cmd cd)
- ✅ **Atuin statt mcfly** integriert
- ✅ **Legacy-Code** aufgeräumt und entfernt
- ✅ **Dokumentation** aktualisiert
