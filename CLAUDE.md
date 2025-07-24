# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **thomsible**, an Ansible-based automation project for setting up desktop and server systems with modern CLI tools. The project uses a three-role architecture to provision systems with service users, configure target users, and install 18+ modern command-line tools.

## Architecture

### Three-Role System
- **`service_user`**: Creates hidden thomsible service user for automation (SSH keys, sudo access)
- **`target_user_config`**: Configures the actual user (Fish shell, PATH configuration)  
- **`modern_tools`**: Installs modern CLI tools as individual files with tags (lazygit, starship, btop, fzf, bat, eza, etc.)

### Key Files
- **Bootstrap scripts**: `bootstrap.sh` (main), `bootstrap.yml`, `bootstrap_tools.yml`
- **Main playbooks**: `site.yml`, `setup_complete.yml`, `setup_complete_with_tools.yml`
- **Inventories**: Separate for docker (`inventories/docker/`), desktop, and server environments
- **Configuration**: `group_vars/all.yml` contains SSH keys and global settings

## Common Commands

### Local Bootstrap (Primary Installation Method)
```bash
# Full installation with service user
./bootstrap.sh --user USERNAME

# Only CLI tools without service user
./bootstrap.sh --tools-only --user USERNAME

# Skip service user creation
./bootstrap.sh --skip-service-user --user USERNAME
```

### Manual Ansible Commands
```bash
# Complete bootstrap
sudo ansible-playbook bootstrap.yml -e "target_user=USERNAME" --ask-become-pass

# Tools only
sudo ansible-playbook bootstrap_tools.yml -e "target_user=USERNAME" --ask-become-pass

# Complete setup with all roles
ansible-playbook -i inventories/docker/hosts_thomsible setup_complete_with_tools.yml

# Install specific tools with tags
ansible-playbook site.yml --tags "lazygit,starship,btop" -e "target_user=USERNAME"
```

### Development and Testing
```bash
# Start Docker test environment  
docker compose up -d

# Access test containers
docker exec -it thomsible-debian11 bash
docker exec -it thomsible-ubuntu2404 bash
docker exec -it thomsible-fedora42 bash

# Test against Docker containers
ansible-playbook -i inventories/docker/hosts_test bootstrap.yml -e "target_user=testuser"
```

### Dependency Management
```bash
# Install/update Python dependencies with uv
uv sync

# Install Ansible via uv
uv tool install ansible
```

## Key Configuration Points

### Target User Requirement
The `target_user` variable **must be explicitly set** - no auto-detection. This is required for all operations.

### GitHub Token Setup
For higher API rate limits when downloading tools from GitHub:
```bash
# Environment variable (preferred)
export GITHUB_TOKEN=$(gh auth token)

# .env file
echo "GITHUB_TOKEN=your_token" > .env

# GitHub CLI authentication
gh auth login
```

### Service User Configuration
Customize the Ansible service user via `group_vars/all.yml`:
```yaml
ansible_user_name: "custom_name"  # Default: "thomsible"
ansible_user_ssh_pubkey: "ssh-ed25519 AAAAC3Nza... user@example.com"
```

## Role Structure

### Individual Tool Files
Each modern tool has its own file in `roles/modern_tools/tasks/tools/` (e.g., `lazygit.yml`, `starship.yml`) allowing for granular installation control via Ansible tags.

### Shell Integration
- Fish shell is set as default for target users
- Automatic PATH configuration for all installed tools
- Shell aliases for modern tool replacements (bat→cat, eza→ls)
- Starship prompt with custom configuration

## Development Workflow

When modifying roles or adding new tools:
1. Test changes in Docker environment first
2. Use appropriate inventory file (`inventories/docker/hosts` for initial setup, `inventories/docker/hosts_thomsible` for further runs)
3. Use tags to test specific components: `--tags "tool_name"`
4. The `target_user` parameter is always required

## File Organization

- `roles/`: Ansible roles organized by function
- `inventories/`: Environment-specific host definitions
- `group_vars/`: Global and group-specific variables
- `docs/`: Comprehensive documentation including architecture and technical details
- `bootstrap.sh`: Primary entry point for new system setup

## Development Guidelines

### General Approach
- Always respond in German when communicating with the user (Thoms)
- Maintain a friendly and professional tone
- Be cautious when deleting code or entire files; ask the user first
- Stay focused and do not propose changes unrelated to the current task
- Break down complex tasks into individual steps

### Code Quality Standards
- Keep files under 300 lines - refactor proactively when they grow larger
- Use meaningful names for variables and methods
- Avoid duplicate code - encapsulate functionality into new methods
- Follow established project patterns consistently
- Use clear, descriptive file names (avoid "temp", "refactored", etc.)

### Error Handling and Logging
- Use informative log messages that precisely identify errors
- Utilize debug logs to facilitate quick issue resolution
- Employ appropriate log levels (DEBUG, INFO, WARN, ERROR)
- Implement robust error handling and parameter validation

### When Working with Ansible
- Always test changes in Docker environment first
- Use appropriate inventory files for different phases
- Remember that `target_user` parameter is always required
- Use tags for granular testing of specific components
- Verify all integrations work correctly after changes

### Security Considerations
- Never hardcode secrets or credentials in code
- Use environment variables or .env files for sensitive data
- Keep sensitive logic server-side
- Always validate and sanitize inputs