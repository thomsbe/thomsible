# .gitignore Regeln für thomsible

Übersicht über die Git-Ignore-Regeln und was committed wird.

## 🔒 Was wird NICHT committed (Sicherheit)

### Secrets & Credentials
```
*.pem, *.key, id_rsa*, id_ed25519*  # SSH Keys
*vault*, *secret*, *password*       # Ansible Vault
.env, .env.local, .env.production   # Environment files
*token.txt, *token.json, .token     # Token files
```

### Temporäre Dateien
```
*.retry, .ansible/, ansible.log     # Ansible temporär
__pycache__/, *.pyc                 # Python cache
temp/, tmp/, .tmp/                  # Temporäre Verzeichnisse
test_*.yml, *_test.yml              # Test-Playbooks
```

### Editor & OS Dateien
```
.vscode/, .windsurf/                # Editor-Konfiguration
.DS_Store, Thumbs.db               # OS-spezifische Dateien
*.swp, *.swo, *~                   # Vim/Emacs temporär
```

## ✅ Was wird committed (Dokumentation & Code)

### Ansible-Code
```
roles/                             # Alle Ansible-Rollen
*.yml, *.yaml                      # Playbooks (außer test_*)
ansible.cfg                        # Ansible-Konfiguration
group_vars/, host_vars/            # Variablen (ohne Secrets)
inventories/                       # Inventories (Templates)
```

### Dokumentation
```
README.md, docs/                   # Alle Dokumentation
.env.example                       # Beispiel-Konfiguration
docs/github-token.md               # Token-Dokumentation
BOOTSTRAP.md                       # Bootstrap-Anleitung
```

### Konfiguration & Tools
```
bootstrap.sh                       # Bootstrap-Script
pyproject.toml                     # Python-Konfiguration
docker-compose.yml                 # Docker für Tests
.gitignore                         # Diese Datei
```

## 🎯 Spezielle Regeln

### Environment Files
```
❌ .env                           # Echte Umgebungsvariablen
❌ .env.local                     # Lokale Konfiguration
❌ .env.production                # Produktions-Konfiguration
✅ .env.example                   # Beispiel-Template
```

### Token Files
```
❌ my-token.txt                   # Token-Dateien
❌ github-token.json              # Token in JSON
❌ .token                         # Versteckte Token
✅ docs/github-token.md           # Token-Dokumentation
✅ token-setup.example            # Beispiel-Setup
```

### Test Files
```
❌ test_bootstrap.yml             # Temporäre Tests
❌ debug_test.yml                 # Debug-Playbooks
✅ roles/*/tests/                 # Offizielle Tests
✅ inventories/docker/            # Test-Inventories
```

## 🔧 Lokale Anpassungen

### Für lokale Entwicklung ignoriert
```
inventories/production/           # Echte Server-IPs
inventories/real/                 # Produktions-Inventories
local_config.yml                 # Lokale Overrides
personal/, private/               # Persönliche Notizen
```

### Für CI/CD behalten
```
.github/workflows/                # GitHub Actions
docker-compose.yml                # Container-Tests
requirements.txt                  # Dependencies
```

## 📝 Best Practices

### Secrets niemals committen
- Verwende Umgebungsvariablen: `export GITHUB_TOKEN=...`
- Nutze .env-Dateien lokal: `echo "TOKEN=..." > .env`
- Dokumentiere in .example-Dateien: `.env.example`

### Dokumentation immer committen
- README.md und docs/ Verzeichnis
- Beispiel-Konfigurationen (*.example)
- Setup-Anleitungen und Troubleshooting

### Tests sauber halten
- Temporäre Test-Playbooks löschen
- Offizielle Tests in roles/*/tests/ behalten
- Docker-Compose für reproduzierbare Tests

## 🚨 Sicherheits-Checks

### Vor jedem Commit prüfen
```bash
# Keine Secrets im Staging
git diff --cached | grep -i -E "(token|password|key|secret)"

# .env-Dateien prüfen
git status | grep "\.env"

# SSH-Keys prüfen
git status | grep -E "\.(pem|key|pub)$"
```

### Nach versehentlichem Commit
```bash
# Datei aus Git-History entfernen
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/secret/file' \
  --prune-empty --tag-name-filter cat -- --all

# Oder BFG Repo-Cleaner verwenden
java -jar bfg.jar --delete-files secret-file.txt
```

## 📊 Übersicht

| Kategorie | Committed | Ignoriert | Beispiele |
|-----------|-----------|-----------|-----------|
| **Code** | ✅ | ❌ | roles/, *.yml, ansible.cfg |
| **Docs** | ✅ | ❌ | README.md, docs/, *.example |
| **Secrets** | ❌ | ✅ | .env, *.key, *token* |
| **Temporär** | ❌ | ✅ | test_*, .tmp/, *.retry |
| **Config** | ✅ | ❌ | bootstrap.sh, pyproject.toml |
| **Tests** | ✅ | ❌ | docker-compose.yml, inventories/docker/ |

Die .gitignore ist so konfiguriert, dass alle wichtigen Dateien für das Projekt committed werden, aber keine Secrets oder temporären Dateien versehentlich ins Repository gelangen.
