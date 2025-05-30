# Rolle: thomsible_user

Diese Rolle legt einen konfigurierbaren Ansible-Benutzer an, richtet SSH-Key-Login ein und erlaubt passwortloses sudo.

## Features
- Erstellt den Ansible-Benutzer (Name konfigurierbar, Standard: `thomsible`)
- Automatische OS-Familie-Erkennung (Debian/Ubuntu vs RedHat/Fedora)
- Installiert sudo-Paket bei Bedarf (Debian/Ubuntu)
- Fügt User zur korrekten sudo-Gruppe hinzu (`sudo` oder `wheel`)
- Legt SSH-Verzeichnis und `authorized_keys` an
- Setzt den SSH-Public-Key aus der konfigurierten Variable
- Konfiguriert passwortloses sudo
- Sperrt Passwort-Login für diesen Nutzer

## Variablen
- `ansible_user_name`: Name des Ansible-Benutzers (Standard: "thomsible")
- `ansible_user_ssh_pubkey`: Der SSH-Public-Key für den Login
- `thomsible_ssh_pubkey`: Legacy-Variable (für Rückwärtskompatibilität)

## OS-spezifische Variablen
Die Rolle lädt automatisch OS-spezifische Variablen:
- **Debian/Ubuntu** (`vars/Debian.yml`): `sudo_group: sudo`, `install_sudo_package: true`
- **RedHat/Fedora** (`vars/RedHat.yml`): `sudo_group: wheel`, `install_sudo_package: false`

## Beispiel für group_vars/all.yml
```yaml
# Standard-Konfiguration
ansible_user_name: "thomsible"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... user@host"

# Oder mit anderem Benutzernamen
ansible_user_name: "automation"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... automation@company.com"
```

## Nutzung im Playbook
```yaml
- hosts: all
  roles:
    - thomsible_user
    - weitere_rolle
```

> **Hinweis:** Diese Rolle sollte immer zuerst ausgeführt werden.
