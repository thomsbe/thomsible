#!/bin/bash
set -euo pipefail

# Bootstrap Script für thomsible
# Installiert uv (Python Package Manager) und führt dann Ansible Bootstrap aus
#
# Verwendung:
#   ./bootstrap.sh                    # Vollständiges Bootstrap
#   ./bootstrap.sh --tools-only       # Nur CLI-Tools installieren
#   ./bootstrap.sh --user thomas      # Für spezifischen Benutzer
#   ./bootstrap.sh --help             # Hilfe anzeigen

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Standard-Werte
PLAYBOOK="bootstrap_local.yml"
TARGET_USER=""
SKIP_ANSIBLE_USER=""
EXTRA_VARS=""
VERBOSE=""

# Funktionen
print_header() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🚀 THOMSIBLE BOOTSTRAP 🚀                ║"
    echo "║                                                              ║"
    echo "║  Automatische Installation von modernen CLI-Tools           ║"
    echo "║  mit uv + Ansible für eine bessere Entwicklungsumgebung     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_usage() {
    echo -e "${CYAN}Verwendung:${NC}"
    echo "  $0 [OPTIONEN]"
    echo ""
    echo -e "${CYAN}Optionen:${NC}"
    echo "  --tools-only              Nur CLI-Tools installieren (ohne Ansible-Benutzer)"
    echo "  --user USERNAME           Ziel-Benutzer (Standard: aktueller Benutzer)"
    echo "  --skip-ansible-user       Ansible-Benutzer nicht erstellen"
    echo "  --verbose, -v             Verbose Ansible-Ausgabe"
    echo "  --help, -h                Diese Hilfe anzeigen"
    echo ""
    echo -e "${CYAN}Beispiele:${NC}"
    echo "  $0                        # Vollständiges Bootstrap für aktuellen Benutzer"
    echo "  $0 --tools-only           # Nur Tools installieren"
    echo "  $0 --user thomas          # Bootstrap für Benutzer 'thomas'"
    echo "  $0 --tools-only --user thomas  # Nur Tools für 'thomas'"
    echo ""
    echo -e "${CYAN}Was wird installiert:${NC}"
    echo "  • uv (Python Package Manager)"
    echo "  • Ansible (via uv)"
    echo "  • 18 moderne CLI-Tools (lazygit, starship, btop, fzf, etc.)"
    echo "  • Fish shell mit moderner Konfiguration"
    echo "  • Git-Konfiguration"
    echo "  • Shell-Aliases und Starship-Prompt"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_requirements() {
    log_info "Überprüfe Systemvoraussetzungen..."

    # Prüfe ob wir auf einem unterstützten System sind
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_success "Linux-System erkannt"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        log_success "macOS-System erkannt"
    else
        log_error "Nicht unterstütztes Betriebssystem: $OSTYPE"
        exit 1
    fi

    # Prüfe ob curl verfügbar ist
    if ! command -v curl &> /dev/null; then
        log_error "curl ist nicht installiert. Bitte installieren Sie curl zuerst."
        exit 1
    fi

    # Prüfe ob git verfügbar ist
    if ! command -v git &> /dev/null; then
        log_warning "git ist nicht installiert. Wird von Ansible installiert."
    fi

    log_success "Systemvoraussetzungen erfüllt"
}

install_uv() {
    log_info "Installiere uv (Python Package Manager)..."

    if command -v uv &> /dev/null; then
        log_success "uv ist bereits installiert: $(uv --version)"
        return 0
    fi

    # uv installieren
    log_info "Lade uv von https://astral.sh/uv/install.sh herunter..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        log_success "uv erfolgreich installiert"

        # PATH aktualisieren für aktuelle Session
        export PATH="$HOME/.cargo/bin:$PATH"

        # Prüfe Installation
        if command -v uv &> /dev/null; then
            log_success "uv Version: $(uv --version)"
        else
            log_error "uv Installation fehlgeschlagen - nicht im PATH gefunden"
            log_info "Versuche manuell: export PATH=\"\$HOME/.cargo/bin:\$PATH\""
            exit 1
        fi
    else
        log_error "uv Installation fehlgeschlagen"
        exit 1
    fi
}

install_ansible() {
    log_info "Installiere Ansible mit uv..."

    # Prüfe ob Ansible bereits verfügbar ist
    if command -v ansible-playbook &> /dev/null; then
        log_success "Ansible ist bereits verfügbar: $(ansible-playbook --version | head -1)"
        return 0
    fi

    # Ansible mit uv installieren
    log_info "Installiere Ansible..."
    if uv tool install ansible; then
        log_success "Ansible erfolgreich installiert"

        # PATH für uv tools aktualisieren
        export PATH="$HOME/.local/bin:$PATH"

        # Prüfe Installation
        if command -v ansible-playbook &> /dev/null; then
            log_success "Ansible Version: $(ansible-playbook --version | head -1)"
        else
            log_error "Ansible Installation fehlgeschlagen - nicht im PATH gefunden"
            log_info "Versuche manuell: export PATH=\"\$HOME/.local/bin:\$PATH\""
            exit 1
        fi
    else
        log_error "Ansible Installation mit uv fehlgeschlagen"
        exit 1
    fi
}

setup_github_token() {
    log_info "Überprüfe GitHub API Token..."

    # Prüfe verschiedene Token-Quellen in Prioritätsreihenfolge
    local token=""

    # 1. Umgebungsvariable (höchste Priorität)
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        token="$GITHUB_TOKEN"
        log_success "GitHub Token aus Umgebungsvariable GITHUB_TOKEN gefunden"

    # 2. .env-Datei
    elif [[ -f ".env" ]] && grep -q "GITHUB_TOKEN=" ".env"; then
        token=$(grep "GITHUB_TOKEN=" ".env" | cut -d'=' -f2 | tr -d '"' | tr -d "'")
        if [[ -n "$token" ]]; then
            log_success "GitHub Token aus .env-Datei gefunden"
            export GITHUB_TOKEN="$token"  # Für Ansible verfügbar machen
        fi

    # 3. GitHub CLI (Fallback)
    elif command -v gh &> /dev/null && gh auth status &> /dev/null; then
        log_info "GitHub CLI ist authentifiziert, hole Token..."
        token=$(gh auth token 2>/dev/null || echo "")
        if [[ -n "$token" ]]; then
            log_success "GitHub Token von GitHub CLI erhalten"
            export GITHUB_TOKEN="$token"  # Als Umgebungsvariable setzen
        fi
    fi

    # Token-Status anzeigen
    if [[ -n "$token" ]]; then
        log_success "GitHub Token verfügbar - höhere API-Limits aktiv"
        log_info "Token-Quelle: ${GITHUB_TOKEN:+Umgebungsvariable}${GITHUB_TOKEN:-GitHub CLI/Datei}"
    else
        log_warning "Kein GitHub Token verfügbar - API-Limits könnten erreicht werden"
        log_info "Token setzen mit:"
        log_info "  export GITHUB_TOKEN=\$(gh auth token)  # Umgebungsvariable"
        log_info "  echo 'GITHUB_TOKEN=your_token' > .env  # .env-Datei"
        log_info "  gh auth login                         # GitHub CLI"
    fi
}

cleanup_github_token() {
    # Cleanup ist nicht mehr nötig, da wir Umgebungsvariablen verwenden
    log_info "GitHub Token Cleanup (Umgebungsvariablen benötigen kein Cleanup)"
}

run_ansible() {
    log_info "Führe Ansible Bootstrap aus..."

    # Baue Ansible-Befehl zusammen
    local ansible_cmd="ansible-playbook $PLAYBOOK"

    # Automatisch den echten Benutzer erkennen (nicht root bei sudo)
    local real_user="${SUDO_USER:-$USER}"
    if [[ -z "$TARGET_USER" ]]; then
        EXTRA_VARS="${EXTRA_VARS}target_user=$real_user "
        log_info "Automatisch erkannter Ziel-Benutzer: $real_user"
    fi

    # Füge Extra-Variablen hinzu
    if [[ -n "$EXTRA_VARS" ]]; then
        ansible_cmd="$ansible_cmd -e \"$EXTRA_VARS\""
    fi

    # Füge Verbose-Flag hinzu
    if [[ -n "$VERBOSE" ]]; then
        ansible_cmd="$ansible_cmd -v"
    fi

    # Füge --ask-become-pass für lokale sudo-Berechtigung hinzu
    ansible_cmd="$ansible_cmd --ask-become-pass"

    log_info "Führe aus: $ansible_cmd"
    log_warning "Sie werden nach Ihrem sudo-Passwort gefragt..."

    # Ansible ausführen
    if eval "$ansible_cmd"; then
        log_success "Ansible Bootstrap erfolgreich abgeschlossen!"
        return 0
    else
        log_error "Ansible Bootstrap fehlgeschlagen"
        return 1
    fi
}

show_completion_message() {
    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 BOOTSTRAP ABGESCHLOSSEN! 🎉            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    log_success "Moderne CLI-Tools wurden erfolgreich installiert!"
    echo ""
    log_info "Nächste Schritte:"
    echo "  1. Shell neustarten: exec \$SHELL"
    echo "  2. Tools testen: lazygit --version, btop --version"
    echo "  3. Neue Features ausprobieren:"
    echo "     • lazygit (Terminal Git UI)"
    echo "     • btop (System Monitor)"
    echo "     • fzf (Fuzzy Finder - Ctrl+R für History)"
    echo "     • bat README.md (Syntax Highlighting)"
    echo "     • eza (Modernes ls)"
    echo ""
    log_info "Dokumentation: README.md und docs/ Ordner"
    log_info "Bei Problemen: GitHub Issues oder docs/bootstrap.md"
}

# Hauptfunktion
main() {
    # Argument-Parsing
    while [[ $# -gt 0 ]]; do
        case $1 in
            --tools-only)
                PLAYBOOK="bootstrap_tools_only.yml"
                shift
                ;;
            --user)
                TARGET_USER="$2"
                shift 2
                ;;
            --skip-ansible-user)
                SKIP_ANSIBLE_USER="true"
                shift
                ;;
            --verbose|-v)
                VERBOSE="-v"
                shift
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            *)
                log_error "Unbekannte Option: $1"
                print_usage
                exit 1
                ;;
        esac
    done

    # Extra-Variablen zusammenbauen
    if [[ -n "$TARGET_USER" ]]; then
        EXTRA_VARS="${EXTRA_VARS}target_user=$TARGET_USER "
    fi

    if [[ -n "$SKIP_ANSIBLE_USER" ]]; then
        EXTRA_VARS="${EXTRA_VARS}skip_ansible_user=true "
    fi

    # Entferne trailing space
    EXTRA_VARS=$(echo "$EXTRA_VARS" | sed 's/[[:space:]]*$//')

    # Header anzeigen
    print_header

    # Prüfe ob wir im richtigen Verzeichnis sind
    if [[ ! -f "$PLAYBOOK" ]]; then
        log_error "Playbook $PLAYBOOK nicht gefunden!"
        log_info "Bitte führen Sie das Script im thomsible-Verzeichnis aus."
        exit 1
    fi

    # Führe Bootstrap-Schritte aus
    check_requirements
    install_uv
    install_ansible
    setup_github_token

    # Trap für Cleanup
    trap cleanup_github_token EXIT

    # Ansible ausführen
    if run_ansible; then
        show_completion_message
    else
        log_error "Bootstrap fehlgeschlagen!"
        exit 1
    fi
}

# Script ausführen
main "$@"
