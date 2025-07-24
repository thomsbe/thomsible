# Professionelles Testing mit Molecule

## 🧪 Installation

### Mit uv (empfohlen für thomsible)
```bash
# Alle Dependencies installieren
uv sync

# Oder nur Test-Dependencies
uv sync --extra test

# Ansible Collections installieren
ansible-galaxy install -r molecule/requirements.yml
```

### Alternativ mit pip
```bash
# Molecule mit Docker-Driver installieren
pip install molecule[docker] molecule-plugins[docker]

# Ansible Collections installieren
ansible-galaxy install -r molecule/requirements.yml
```

## 🚀 Molecule Commands

### Kompletter Test-Zyklus
```bash
# Alles testen (empfohlen)
molecule test

# Schrittweise testen
molecule create    # Container erstellen
molecule prepare   # Test-Environment vorbereiten
molecule converge  # Playbook ausführen
molecule verify    # Tests durchführen
molecule destroy   # Aufräumen
```

### Entwicklung & Debugging
```bash
# Nur Syntax prüfen
molecule syntax

# Container erstellen und Playbook ausführen
molecule converge

# Nur Verifikation laufen lassen
molecule verify

# Idempotenz testen (wichtig!)
molecule idempotence

# In Container einloggen für Debugging
molecule login --host debian11
molecule login --host fedora42
```

### Spezifische Szenarien
```bash
# Nur bestimmte Plattformen
molecule test --platform-name debian11
molecule test --platform-name fedora42

# Verbose Output
molecule test -v

# Ohne Cleanup (für Debugging)
molecule converge
# Container bleiben am Leben für manuelle Tests
```

## 🎯 Was getestet wird

### 1. **Syntax & Lint**
- Ansible-Syntax
- YAML-Validation
- Best Practices

### 2. **Prepare Phase**
- Test-User erstellen
- Python installieren
- Package-Cache aktualisieren

### 3. **Converge Phase**
- Target User Configuration
- Modern Tools Installation
- Nur essentielle Tools (lazygit, starship, bat)

### 4. **Verify Phase**
- Tools sind installiert
- Tools sind funktional (version checks)
- PATH ist konfiguriert
- Fish shell setup

### 5. **Side Effects**
- Einzelne Tool-Installation
- Kategorie-basierte Installation
- Tool-Funktionalität nach Änderungen

### 6. **Idempotence**
- Zweite Ausführung ändert nichts
- Ansible best practice

## 🔧 Konfiguration anpassen

### Andere Tools testen
```yaml
# In molecule/default/converge.yml
tools_config:
  eza:
    enabled: true
    description: "Modern ls replacement"
    category: "file_tools"
    repo: "eza-community/eza"
    asset_pattern: ".*x86_64-unknown-linux-musl.tar.gz$"
    archive_extension: "tar.gz"
```

### Nur bestimmte Distributionen
```yaml
# In molecule/default/molecule.yml
platforms:
  - name: debian12
    image: quay.io/ansible/molecule-debian:12
    # ... rest of config
```

### Podman statt Docker
```yaml
# In molecule/default/molecule.yml
driver:
  name: podman
```

## 🎯 Vorteile von Molecule

### ✅ **Gegenüber Docker-Compose:**
- **Echte systemd**: Services funktionieren korrekt
- **Ansible-optimiert**: Designed für Ansible-Testing
- **Standardisiert**: Industry standard für Ansible
- **Umfassende Tests**: Syntax, Idempotenz, Verifikation
- **Multi-Platform**: Einfach verschiedene Distros testen

### ✅ **Testing-Features:**
- **Idempotenz-Tests**: Erkennt Änderungen bei zweiter Ausführung
- **Lint-Integration**: Automatische Code-Quality-Checks
- **Parallel Testing**: Mehrere Plattformen gleichzeitig
- **CI/CD Ready**: Einfache Integration in Pipelines

## 🚨 Troubleshooting

### Docker-Probleme
```bash
# Docker-Service prüfen
sudo systemctl status docker

# Docker neu starten
sudo systemctl restart docker

# User zu docker-Gruppe hinzufügen (falls nötig)
sudo usermod -aG docker $USER
# Logout/Login erforderlich
```

### Container-Zugriff für Debugging
```bash
# Nach molecule converge
molecule login --host debian11

# Manuell in Container
sudo -u testuser bash
cd /home/testuser
ls -la .local/bin/
lazygit --version
```

### Performance-Optimierung
```bash
# Weniger Plattformen für schnelle Tests
# Nur debian12 und fedora42 in molecule.yml

# Weniger Tools in converge.yml
# Nur lazygit und starship für Basis-Tests
```

## 🎯 Empfohlener Workflow

1. **Entwicklung**: `molecule converge` (schnell, Container bleibt)
2. **Testing**: `molecule verify` (nur Tests)
3. **Full Check**: `molecule test` (kompletter Zyklus)
4. **CI/CD**: `molecule test` in GitHub Actions

Das ist der professionelle Standard für Ansible-Testing! 🚀