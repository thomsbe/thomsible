# GitHub-Tool Template

Dieses Template kann für die Installation von GitHub-basierten Tools verwendet werden.

## Template: roles/TOOLNAME/tasks/main.yml

```yaml
---
- name: Get target user information
  ansible.builtin.getent:
    database: passwd
    key: "{{ target_user }}"
  register: target_user_info

- name: Set target user home directory
  ansible.builtin.set_fact:
    target_user_home: "{{ target_user_info.ansible_facts.getent_passwd[target_user][4] }}"

- name: Display TOOLNAME installation info
  ansible.builtin.debug:
    msg: |
      Installing latest TOOLNAME for:
      - Target user: {{ target_user }}
      - Home directory: {{ target_user_home }}
      - Install path: {{ target_user_home }}/local/bin/

- name: Get latest TOOLNAME release information from GitHub API
  ansible.builtin.uri:
    url: https://api.github.com/repos/USER/REPO/releases/latest
    method: GET
    return_content: yes
  register: tool_release_info

- name: Extract latest version and download URL
  ansible.builtin.set_fact:
    tool_version: "{{ tool_release_info.json.tag_name }}"
    tool_download_url: "{{ tool_release_info.json.assets | selectattr('name', 'match', 'ASSET_PATTERN') | map(attribute='browser_download_url') | first }}"

- name: Display version information
  ansible.builtin.debug:
    msg: |
      Installing TOOLNAME {{ tool_version }}
      Download URL: {{ tool_download_url }}

- name: Create local bin directory for target user
  ansible.builtin.file:
    path: "{{ target_user_home }}/local/bin"
    state: directory
    owner: "{{ target_user }}"
    group: "{{ target_user }}"
    mode: '0755'

- name: Create temporary download directory
  ansible.builtin.tempfile:
    state: directory
    suffix: _TOOLNAME
  register: temp_dir

- name: Download TOOLNAME archive
  ansible.builtin.get_url:
    url: "{{ tool_download_url }}"
    dest: "{{ temp_dir.path }}/TOOLNAME.EXTENSION"
    mode: '0644'

- name: Extract TOOLNAME archive
  ansible.builtin.unarchive:
    src: "{{ temp_dir.path }}/TOOLNAME.EXTENSION"
    dest: "{{ temp_dir.path }}"
    remote_src: yes

- name: Install TOOLNAME binary
  ansible.builtin.copy:
    src: "{{ temp_dir.path }}/BINARY_PATH"
    dest: "{{ target_user_home }}/local/bin/TOOLNAME"
    owner: "{{ target_user }}"
    group: "{{ target_user }}"
    mode: '0755'
    remote_src: yes

- name: Clean up temporary directory
  ansible.builtin.file:
    path: "{{ temp_dir.path }}"
    state: absent

- name: Verify TOOLNAME installation
  ansible.builtin.shell: |
    echo "=== TOOLNAME Installation Verification ==="
    echo "Binary location: {{ target_user_home }}/local/bin/TOOLNAME"
    echo "Binary permissions:"
    ls -la {{ target_user_home }}/local/bin/TOOLNAME
    echo "Version check:"
    sudo -u {{ target_user }} {{ target_user_home }}/local/bin/TOOLNAME --version
    echo "PATH suggestion for {{ target_user }}:"
    echo "export PATH=\"\$HOME/local/bin:\$PATH\""
  register: tool_verification
  changed_when: false

- name: Display TOOLNAME verification results
  ansible.builtin.debug:
    var: tool_verification.stdout_lines
```

## Anpassungen für verschiedene Tools

### 1. Variablen ersetzen:
- `TOOLNAME` → Name des Tools (z.B. `lazygit`, `bat`, `fd`)
- `USER/REPO` → GitHub Repository (z.B. `jesseduffield/lazygit`)
- `ASSET_PATTERN` → Regex für Asset-Auswahl (z.B. `.*Linux_x86_64.tar.gz$`)
- `EXTENSION` → Dateiendung (z.B. `tar.gz`, `zip`)
- `BINARY_PATH` → Pfad zur Binary im Archiv (z.B. `lazygit`, `bin/tool`)

### 2. Häufige Asset-Pattern:
- **tar.gz Archive**: `.*Linux_x86_64.tar.gz$`
- **zip Archive**: `.*linux.*x86_64.*\.zip$`
- **deb Pakete**: `.*amd64\.deb$`
- **AppImage**: `.*\.AppImage$`

### 3. Beispiele:

#### lazygit:
- Repository: `jesseduffield/lazygit`
- Asset-Pattern: `.*Linux_x86_64.tar.gz$`
- Binary-Pfad: `lazygit`

#### bat:
- Repository: `sharkdp/bat`
- Asset-Pattern: `.*x86_64-unknown-linux-gnu.tar.gz$`
- Binary-Pfad: `bat-*/bat`

#### fd:
- Repository: `sharkdp/fd`
- Asset-Pattern: `.*x86_64-unknown-linux-gnu.tar.gz$`
- Binary-Pfad: `fd-*/fd`

## README Template

```markdown
# Rolle: TOOLNAME

Diese Rolle installiert TOOLNAME für den Ziel-Benutzer.

## Features
- Holt automatisch die neueste Version von GitHub Releases
- Installiert TOOLNAME in `$HOME/local/bin/` des Ziel-Benutzers
- Überschreibt bestehende Installation mit neuester Version
- Setzt korrekte Berechtigungen für den Ziel-Benutzer

## Variablen
- `target_user`: Der Benutzer, für den TOOLNAME installiert werden soll

## Abhängigkeiten
- Internetverbindung für GitHub API und Download
- Ziel-Benutzer muss bereits existieren
```
