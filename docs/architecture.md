# Architektur und Projektidee: thomsible

## Zielsetzung
Das Ziel von **thomsible** ist es, eine Sammlung von Ansible-Rollen zu pflegen, mit denen sowohl Desktop- als auch Server-Systeme automatisiert und konsistent mit den gleichen Tools und Programmen ausgestattet werden können. Jede Rolle ist für ein einzelnes Tool oder Programm zuständig. So bleibt das System modular, erweiterbar und übersichtlich.

## Hauptideen
- **Modularität:** Jede Rolle installiert ein spezifisches Tool oder Programm.
- **Wiederverwendbarkeit:** Rollen können für verschiedene Hosts (Desktop/Server) genutzt werden.
- **Konsistenz:** Alle Systeme erhalten die gleichen Werkzeuge, unabhängig vom Typ.
- **Trennung von Inventories:** Desktop- und Server-Systeme werden in getrennten Inventories verwaltet.
- **Zentrale Variablenverwaltung:** Gemeinsame und systemspezifische Variablen werden in `group_vars` gepflegt.

## Projektstruktur
```
thomsible/
├── ansible.cfg
├── inventories/
│   ├── desktop/hosts
│   └── server/hosts
├── group_vars/
│   ├── all.yml
│   ├── desktop.yml
│   └── server.yml
├── roles/
├── site.yml
└── README.md
```

## Komponenten
- **ansible.cfg:** Grundkonfiguration für Ansible.
- **inventories/**: Getrennte Hostlisten für Desktop und Server.
- **group_vars/**: Variablen für alle Hosts, nur Desktops oder nur Server.
- **roles/**: Hier werden die einzelnen Rollen für Tools/Programme abgelegt.
- **site.yml:** Zentrales Playbook, das die gewünschten Rollen auf die Hosts anwendet.

## Erweiterung
Neue Tools werden als eigene Rolle in `roles/` hinzugefügt und bei Bedarf im Playbook (`site.yml`) eingetragen.

---

## Bisherige Ausführung
- Projektstruktur und Verzeichnisse wurden nach Best-Practice angelegt.
- Platzhalter für Inventories, Variablen und das zentrale Playbook wurden erstellt.
- Die Dokumentation folgt den Prinzipien: Einfachheit, Modularität, Übersichtlichkeit.

Weitere Rollen und Anpassungen können nun schrittweise ergänzt werden.
