# GitHub Token Konfiguration

Für höhere GitHub API Rate-Limits kann ein Token auf verschiedene Weise konfiguriert werden.

## Prioritätsreihenfolge

Thomsible sucht GitHub Tokens in dieser Reihenfolge:

1. **Umgebungsvariable** `GITHUB_TOKEN` (höchste Priorität)
2. **.env-Datei** im Projektverzeichnis
3. **GitHub CLI** (`gh auth token`)

## Methode 1: Umgebungsvariable (Empfohlen)

### Temporär (nur für aktuelle Session)
```bash
# Token generieren und setzen
export GITHUB_TOKEN=$(gh auth token)

# Oder manuell setzen
export GITHUB_TOKEN="gho_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Bootstrap ausführen
./bootstrap.sh
```

### Permanent (in Shell-Profil)
```bash
# Für Bash
echo 'export GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")' >> ~/.bashrc

# Für Fish
echo 'set -gx GITHUB_TOKEN (gh auth token 2>/dev/null || echo "")' >> ~/.config/fish/config.fish

# Für Zsh
echo 'export GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")' >> ~/.zshrc
```

### Vorteile
- ✅ Automatisch verfügbar für alle Ansible-Aufrufe
- ✅ Kein Risiko, Token zu committen
- ✅ Einfach zu automatisieren
- ✅ Funktioniert mit CI/CD-Systemen

## Methode 2: .env-Datei

### Setup
```bash
# .env-Datei erstellen
cp .env.example .env

# Token hinzufügen
echo "GITHUB_TOKEN=$(gh auth token)" >> .env

# Oder manuell bearbeiten
nano .env
```

### .env-Datei Inhalt
```bash
# GitHub API Token für höhere Rate-Limits
GITHUB_TOKEN=gho_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Weitere optionale Konfiguration
ANSIBLE_USER_NAME=automation
TARGET_USER=thomas
```

### Vorteile
- ✅ Projektspezifische Konfiguration
- ✅ Automatisch von .gitignore ausgeschlossen
- ✅ Einfach zu teilen (ohne Token)
- ✅ Unterstützt mehrere Variablen

### Nachteile
- ⚠️ Datei kann versehentlich geteilt werden
- ⚠️ Nur im Projektverzeichnis verfügbar

## Methode 3: GitHub CLI (Fallback)

### Setup
```bash
# GitHub CLI installieren
# Ubuntu/Debian
sudo apt install gh

# macOS
brew install gh

# Authentifizieren
gh auth login

# Token testen
gh auth token
```

### Vorteile
- ✅ Automatische Token-Erneuerung
- ✅ Sichere Speicherung durch gh CLI
- ✅ Funktioniert ohne manuelle Konfiguration

### Nachteile
- ⚠️ Benötigt gh CLI Installation
- ⚠️ Niedrigste Priorität

## Token generieren

### Mit GitHub CLI (Empfohlen)
```bash
# Authentifizieren
gh auth login

# Token anzeigen
gh auth token
```

### Manuell über GitHub Web-Interface
1. Gehe zu https://github.com/settings/tokens
2. Klicke "Generate new token (classic)"
3. Wähle Scopes: `public_repo` (für öffentliche Repos)
4. Kopiere den generierten Token

## Verwendung in verschiedenen Szenarien

### Lokale Entwicklung
```bash
# Einmalig in Shell-Profil setzen
echo 'export GITHUB_TOKEN=$(gh auth token 2>/dev/null)' >> ~/.bashrc
source ~/.bashrc

# Dann einfach verwenden
./bootstrap.sh
```

### CI/CD (GitHub Actions)
```yaml
# .github/workflows/test.yml
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

steps:
  - name: Run bootstrap
    run: ./bootstrap.sh
```

### Docker/Container
```bash
# Token als Umgebungsvariable übergeben
docker run -e GITHUB_TOKEN="$GITHUB_TOKEN" my-container ./bootstrap.sh
```

### Shared Development
```bash
# .env.example für Team
cp .env.example .env
# Jeder Entwickler fügt seinen Token hinzu
```

## Sicherheitshinweise

### ✅ Sichere Praktiken
- Verwende Umgebungsvariablen für automatisierte Systeme
- Nutze .env-Dateien für projektspezifische Konfiguration
- Rotiere Tokens regelmäßig
- Verwende minimale Scopes (nur `public_repo` für öffentliche Repos)

### ❌ Unsichere Praktiken
- **Niemals** Tokens in Git committen
- **Niemals** Tokens in Logs ausgeben
- **Niemals** Tokens in Slack/Chat teilen
- **Niemals** Tokens in Screenshots zeigen

## Troubleshooting

### "API rate limit exceeded"
```bash
# Prüfe ob Token gesetzt ist
echo $GITHUB_TOKEN

# Prüfe Token-Gültigkeit
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit

# Token neu generieren
gh auth refresh
export GITHUB_TOKEN=$(gh auth token)
```

### "Token not found"
```bash
# Prüfe alle Token-Quellen
echo "Env var: ${GITHUB_TOKEN:-not set}"
echo ".env file: $(grep GITHUB_TOKEN .env 2>/dev/null || echo 'not found')"
echo "gh CLI: $(gh auth token 2>/dev/null || echo 'not available')"
```

### "Permission denied"
```bash
# Prüfe Token-Scopes
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Neuen Token mit korrekten Scopes generieren
gh auth refresh --scopes repo
```

## Rate Limits

### Ohne Token
- **60 Requests/Stunde** pro IP-Adresse
- Reicht für ~3-5 Tool-Installationen

### Mit Token
- **5000 Requests/Stunde** pro Token
- Reicht für hunderte Tool-Installationen

### Aktuelles Limit prüfen
```bash
# Mit Token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit

# Ohne Token
curl https://api.github.com/rate_limit
```

## Best Practices

1. **Für lokale Entwicklung**: Umgebungsvariable in Shell-Profil
2. **Für CI/CD**: Repository Secrets
3. **Für Teams**: .env.example mit Anleitung
4. **Für Container**: Umgebungsvariable beim Start
5. **Für Automation**: Service-Account mit minimalen Rechten

## Integration mit thomsible

Das Bootstrap-Script erkennt automatisch verfügbare Tokens:

```bash
# Automatische Token-Erkennung
./bootstrap.sh

# Mit explizitem Token
GITHUB_TOKEN="your_token" ./bootstrap.sh

# Mit .env-Datei
echo "GITHUB_TOKEN=your_token" > .env
./bootstrap.sh
```

Ansible verwendet den Token automatisch über die Umgebungsvariable `GITHUB_TOKEN`.
