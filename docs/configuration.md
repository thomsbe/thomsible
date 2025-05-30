# Konfiguration

## Ansible-Benutzer konfigurieren

Der Name des Ansible-Benutzers kann über Variablen angepasst werden. Dies ermöglicht es verschiedenen Teams oder Organisationen, ihre eigenen Namenskonventionen zu verwenden.

### Standard-Konfiguration

```yaml
# group_vars/all.yml
ansible_user_name: "thomsible"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaQP9YHqJ3Lq8yrqPHOT6HyVsYhp/QhgGkyo8pQ6qlm thomsible"
```

### Alternative Konfigurationen

#### Für Unternehmen
```yaml
# group_vars/all.yml
ansible_user_name: "ansible-svc"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaQP9YHqJ3Lq8yrqPHOT6HyVsYhp/QhgGkyo8pQ6qlm ansible-service@company.com"
```

#### Für Teams
```yaml
# group_vars/all.yml
ansible_user_name: "automation"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaQP9YHqJ3Lq8yrqPHOT6HyVsYhp/QhgGkyo8pQ6qlm automation@team.local"
```

#### Für persönliche Projekte
```yaml
# group_vars/all.yml
ansible_user_name: "deploy"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaQP9YHqJ3Lq8yrqPHOT6HyVsYhp/QhgGkyo8pQ6qlm deploy@homelab"
```

## Rückwärtskompatibilität

Die alte Variable `thomsible_ssh_pubkey` funktioniert weiterhin:

```yaml
# group_vars/all.yml - Legacy-Konfiguration
thomsible_ssh_pubkey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaQP9YHqJ3Lq8yrqPHOT6HyVsYhp/QhgGkyo8pQ6qlm thomsible"
```

Diese wird automatisch zu `ansible_user_ssh_pubkey` gemappt.

## Inventory-Anpassung

Bei Verwendung eines benutzerdefinierten Benutzernamens müssen die Inventory-Dateien entsprechend angepasst werden:

```ini
# inventories/custom/hosts
[servers]
server1 ansible_host=192.168.1.10 ansible_user={{ ansible_user_name }} target_user=root
server2 ansible_host=192.168.1.11 ansible_user={{ ansible_user_name }} target_user=root

[desktops]
desktop1 ansible_host=192.168.1.20 ansible_user={{ ansible_user_name }} target_user=thomas
```

## SSH-Key-Generierung

Für neue Ansible-Benutzer sollten eigene SSH-Keys generiert werden:

```bash
# SSH-Key für Ansible-Benutzer generieren
ssh-keygen -t ed25519 -C "automation@company.com" -f ~/.ssh/automation

# Public Key anzeigen
cat ~/.ssh/automation.pub
```

## Ansible-Konfiguration

Die `ansible.cfg` kann entsprechend angepasst werden:

```ini
[defaults]
inventory = inventories/production/hosts
roles_path = roles
host_key_checking = False
retry_files_enabled = False
private_key_file = ~/.ssh/automation  # Angepasst an den neuen Benutzer

[privilege_escalation]
become=True
become_method=sudo
```

## Beispiel-Workflow

1. **Konfiguration anpassen**:
   ```yaml
   # group_vars/all.yml
   ansible_user_name: "automation"
   ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIaQP9YHqJ3Lq8yrqPHOT6HyVsYhp/QhgGkyo8pQ6qlm automation@company.com"
   ```

2. **Inventory aktualisieren**:
   ```ini
   server1 ansible_host=192.168.1.10 ansible_user={{ ansible_user_name }} target_user=root
   ```

3. **Ansible-Benutzer erstellen**:
   ```bash
   ansible-playbook -i inventories/production/hosts site.yml
   ```

4. **Weitere Rollen ausführen**:
   ```bash
   ansible-playbook -i inventories/production/hosts_automation setup_complete_with_tools.yml
   ```

## Sicherheitshinweise

- Verwenden Sie für jeden Ansible-Benutzer einen eigenen SSH-Key
- Speichern Sie private SSH-Keys niemals in Git-Repositories
- Nutzen Sie SSH-Agent oder Ansible Vault für Key-Management
- Rotieren Sie SSH-Keys regelmäßig
