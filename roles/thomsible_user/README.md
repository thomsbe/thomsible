# Rolle: thomsible_user

Diese Rolle legt einen Nutzer `thomsible` an, richtet SSH-Key-Login ein und erlaubt passwortloses sudo.

## Features
- Erstellt den User `thomsible` (falls nicht vorhanden)
- Automatische OS-Familie-Erkennung (Debian/Ubuntu vs RedHat/Fedora)
- Installiert sudo-Paket bei Bedarf (Debian/Ubuntu)
- Fügt User zur korrekten sudo-Gruppe hinzu (`sudo` oder `wheel`)
- Legt SSH-Verzeichnis und `authorized_keys` an
- Setzt den SSH-Public-Key aus der Variable `thomsible_ssh_pubkey`
- Konfiguriert passwortloses sudo
- Sperrt Passwort-Login für diesen Nutzer

## Variablen
- `thomsible_ssh_pubkey`: Der SSH-Public-Key für den Login (z.B. in `group_vars/all.yml` setzen)

## OS-spezifische Variablen
Die Rolle lädt automatisch OS-spezifische Variablen:
- **Debian/Ubuntu** (`vars/Debian.yml`): `sudo_group: sudo`, `install_sudo_package: true`
- **RedHat/Fedora** (`vars/RedHat.yml`): `sudo_group: wheel`, `install_sudo_package: false`

## Beispiel für group_vars/all.yml
```yaml
thomsible_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... user@host"
```

## Nutzung im Playbook
```yaml
- hosts: all
  roles:
    - thomsible_user
    - weitere_rolle
```

> **Hinweis:** Diese Rolle sollte immer zuerst ausgeführt werden.
