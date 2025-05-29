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
- **`github_tools`**: Meta-Rolle für GitHub-basierte Tools (lazygit, btop, fzf)

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

### Weitere GitHub-Tools hinzufügen
Erweitere die Meta-Rolle `github_tools`:
```sh
# Neue Tools in roles/github_tools/defaults/main.yml hinzufügen
# Dann einfach zur Tool-Liste hinzufügen:
ansible-playbook -i inventories/docker/hosts_thomsible -e "github_tools_to_install=[lazygit,btop,fzf,bat]" test_github_tools.yml
```
