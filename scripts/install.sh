#!/bin/bash

###############################################################################
#                                                                             #
#  PIXELLA - Installation & Setup Script                                     #
#  Automated installation, configuration, and PATH export                    #
#  Repository: https://github.com/DominionDev-coder/Pixella-chatbot          #
#                                                                             #
###############################################################################

set -e  # Exit on any error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Repository details
REPO_URL="https://github.com/DominionDev-coder/Pixella-chatbot"
REPO_NAME="Pixella-chatbot"
INSTALL_DIR="${HOME}/.pixella"

# Global variables for OS and Python
OS_TYPE=""
PYTHON_CMD=""
VENV_DIR=".venv"
VENV_ACTIVATE_CMD=""
VENV_PYTHON_BIN=""

# Functions
print_header() {
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}      🤖 PIXELLA - Installation & Setup Script${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

detect_os() {
    print_step "Detecting operating system..."
    case "$(uname -s)" in
        Linux*)
            OS_TYPE="Linux"
            VENV_ACTIVATE_CMD="source \"$VENV_DIR/bin/activate\""
            VENV_PYTHON_BIN="\"$VENV_DIR/bin/python\""
            print_success "Detected Linux"
            ;;
        Darwin*)
            OS_TYPE="macOS"
            VENV_ACTIVATE_CMD="source \"$VENV_DIR/bin/activate\""
            VENV_PYTHON_BIN="\"$VENV_DIR/bin/python\""
            print_success "Detected macOS"
            ;;
        CYGWIN*|MINGW32*|MSYS*|windows*)
            OS_TYPE="Windows"
            # WSL/Git Bash compatible activation
            VENV_ACTIVATE_CMD="source \"$VENV_DIR/Scripts/activate\""
            VENV_PYTHON_BIN="\"$VENV_DIR/Scripts/python.exe\"" # Use python.exe for clarity
            print_warning "Detected Windows. Using WSL/Git Bash compatible commands."
            print_warning "For native PowerShell/CMD, manual steps may be needed for PATH."
            ;;
        *)
            print_error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

# Detect if we're running from inside the cloned repo or standalone
detect_installation_mode() {
    print_step "Detecting installation mode..."
    
    # Check if install.sh is in scripts/ subdirectory of a repo
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    SCRIPT_PARENT="$(dirname "$SCRIPT_DIR")"
    
    if [ -f "$SCRIPT_PARENT/requirements.txt" ] && [ -f "$SCRIPT_PARENT/main.py" ]; then
        # We're inside the cloned repo
        PROJECT_ROOT="$SCRIPT_PARENT"
        INSTALLATION_MODE="local"
        print_success "Local installation detected (already in cloned repo)"
    else
        # We're standalone - need to clone
        INSTALLATION_MODE="remote"
        PROJECT_ROOT="$INSTALL_DIR"
        print_success "Standalone installation mode (will clone repo)"
    fi
}

clone_repository() {
    print_step "Cloning Pixella repository..."
    
    if [ -d "$PROJECT_ROOT" ]; then
        print_warning "Pixella directory already exists at $PROJECT_ROOT"
        read -p "Do you want to update it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$PROJECT_ROOT"
            git pull origin main 2>/dev/null || print_warning "Git pull failed, will use existing files"
        else
            print_success "Using existing installation at $PROJECT_ROOT"
            return 0
        fi
    else
        mkdir -p "$INSTALL_DIR"
        git clone "$REPO_URL" "$PROJECT_ROOT" || {
            print_error "Failed to clone repository"
            print_error "Make sure git is installed and the URL is correct"
            exit 1
        }
    fi
    
    print_success "Repository ready at $PROJECT_ROOT"
}

check_python_version() {
    print_step "Checking Python 3.11+ is available..."
    
    local found_python_version=""
    
    # Prioritize python3.11, then python3.12, then generic python3
    for cmd in python3.11 python3.12 python3; do
        if command -v "$cmd" &> /dev/null; then
            VERSION=$("$cmd" -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
            MAJOR_VERSION=$(echo "$VERSION" | cut -d'.' -f1)
            MINOR_VERSION=$(echo "$VERSION" | cut -d'.' -f2)
            
            if [[ "$MAJOR_VERSION" -eq 3 ]] && [[ "$MINOR_VERSION" -ge 11 ]]; then
                PYTHON_CMD="$cmd"
                found_python_version="$VERSION"
                print_success "Found compatible Python version: $found_python_version ($PYTHON_CMD)"
                break
            fi
        fi
    done
    
    if [ -z "$PYTHON_CMD" ]; then
        print_error "Python 3.11 or higher is required."
        print_error "Please install a compatible Python version."
        exit 1
    fi
}

create_and_activate_venv() {
    print_step "Creating and activating Python virtual environment ($VENV_DIR)..."
    
    if [ -d "$VENV_DIR" ]; then
        print_warning "Virtual environment already exists. Reusing it."
    else
        "$PYTHON_CMD" -m venv "$VENV_DIR" || {
            print_error "Failed to create virtual environment"
            exit 1
        }
        print_success "Virtual environment created."
    fi
    
    # Activate the virtual environment
    # Using 'eval' to ensure activation script modifies the current shell's environment
    eval "$VENV_ACTIVATE_CMD" || {
        print_error "Failed to activate virtual environment using '$VENV_ACTIVATE_CMD'"
        exit 1
    }
    print_success "Virtual environment activated."
    
    # Set PYTHON_CMD to the venv's python
    PYTHON_CMD="$VENV_PYTHON_BIN"
}

check_dependencies() {
    print_step "Checking system dependencies..."
    
    # Check for git if doing remote installation
    if [ "$INSTALLATION_MODE" = "remote" ]; then
        if ! command -v git &> /dev/null; then
            print_error "git is required for remote installation"
            exit 1
        fi
        print_success "git found"
    fi
}

install_requirements() {
    print_step "Installing Python requirements..."
    
    if [ ! -f "$PROJECT_ROOT/requirements.txt" ]; then
        print_error "requirements.txt not found at $PROJECT_ROOT"
        exit 1
    fi
    
    $PYTHON_CMD -m pip install --upgrade pip setuptools wheel
    $PYTHON_CMD -m pip install -r "$PROJECT_ROOT/requirements.txt"
    
    print_success "Python packages installed"
}

setup_directories() {
    print_step "Setting up directories..."
    
    mkdir -p "$PROJECT_ROOT/bin"
    mkdir -p "$PROJECT_ROOT/db"
    mkdir -p "$PROJECT_ROOT/data"
    
    print_success "Directories created"
}

create_env_template() {
    print_step "Checking environment configuration..."
    
    if [ ! -f "$PROJECT_ROOT/.env.template" ]; then
        print_warning ".env.template not found, creating from config..."
        cd "$PROJECT_ROOT"
        $PYTHON_CMD -c "from config import generate_env_template; generate_env_template()" 2>/dev/null || print_warning "Could not auto-generate template"
    fi
}

setup_env_file() {
    print_step "Setting up environment file..."
    
    ENV_FILE="$PROJECT_ROOT/.env"
    
    if [ -f "$ENV_FILE" ]; then
        print_success ".env file already exists"
        return 0
    fi
    
    # Check for template
    if [ -f "$PROJECT_ROOT/.env.template" ]; then
        cp "$PROJECT_ROOT/.env.template" "$ENV_FILE"
        print_success "Created .env from template"
    else
        # Create minimal .env
        cat > "$ENV_FILE" << 'EOF'
# Pixella Configuration
GOOGLE_API_KEY=your-api-key-here
GOOGLE_AI_MODEL=gemini-1.5-flash
USER_NAME=User
USER_PERSONA=helpful-assistant
EOF
        print_success "Created minimal .env file"
    fi
    
    # Prompt for API key and update using a Python script for cross-platform compatibility
    echo
    read -p "Enter your Google API Key (or press Enter to skip): " API_KEY
    if [ ! -z "$API_KEY" ]; then
        # Create a temporary Python script to update the .env file
        PYTHON_SCRIPT_PATH="$PROJECT_ROOT/scripts/update_env.py"
        mkdir -p "$(dirname "$PYTHON_SCRIPT_PATH")" # Ensure scripts directory exists
        cat > "$PYTHON_SCRIPT_PATH" << EOM
import os
import sys

def update_env_file(env_file, key_to_update, new_value):
    try:
        if not os.path.exists(env_file):
            with open(env_file, 'w') as f:
                f.write(f"{key_to_update}={new_value}\\n")
            return

        with open(env_file, 'r') as f:
            lines = f.readlines()

        updated = False
        with open(env_file, 'w') as f:
            for line in lines:
                if line.strip().startswith(f"{key_to_update}="):
                    f.write(f"{key_to_update}={new_value}\\n")
                    updated = True
                else:
                    f.write(line)
            if not updated:
                f.write(f"{key_to_update}={new_value}\\n")
    except Exception as e:
        print(f"Error updating .env file: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python update_env.py <env_file_path> <key> <value>", file=sys.stderr)
        sys.exit(1)
    
    env_file = sys.argv[1]
    key_to_update = sys.argv[2]
    new_value = sys.argv[3]
    update_env_file(env_file, key_to_update, new_value)

EOM
        # Execute the Python script using the venv's python
        "$PYTHON_CMD" "$PYTHON_SCRIPT_PATH" "$ENV_FILE" "GOOGLE_API_KEY" "$API_KEY"
        rm "$PYTHON_SCRIPT_PATH" # Clean up the temporary script
        print_success "API key configured"
    fi
}

export_to_path() {
    print_step "Configuring PATH..."
    
    BIN_DIR="$PROJECT_ROOT/bin"
    SHELL_RC=""
    
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.profile"
    fi
    
    if [ -z "$SHELL_RC" ]; then
        print_warning "Could not determine shell configuration file"
        print_warning "Please manually add $BIN_DIR to your PATH"
        return 1
    fi
    
    # Check if already in PATH
    if grep -q "# added by pixella chatbot install script" "$SHELL_RC" 2>/dev/null; then
        print_success "Pixella PATH already configured in $SHELL_RC"
        return 0
    fi
    
    # Add to PATH
    echo "" >> "$SHELL_RC"
    echo "# added by pixella chatbot install script" >> "$SHELL_RC"
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
    
    print_success "Added to PATH ($SHELL_RC)"
    print_warning "Please restart your terminal or run 'source $SHELL_RC' to apply changes."
}

verify_installation() {
    print_step "Verifying installation..."
    
    cd "$PROJECT_ROOT"
    
    if $PYTHON_CMD main.py > /dev/null 2>&1; then
        print_success "Installation verified successfully"
        return 0
    else
        print_warning "Verification had warnings (this may be normal if dependencies are missing)"
        return 0
    fi
}

print_next_steps() {
    echo
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}      ✓ Installation Complete!${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo
    echo "Next steps:"
    echo
    if [ "$INSTALLATION_MODE" = "remote" ]; then
        echo "1. Reload your shell configuration:"
        echo "   source $HOME/.zshrc  # or source $HOME/.bashrc"
        echo
    fi
    echo "2. Start using Pixella:"
    echo "   pixella --help               # View available commands"
    echo "   pixella cli --interactive    # Start interactive mode"
    echo "   pixella ui                   # Start web interface"
    echo
    echo "3. Configure Pixella:"
    echo "   pixella config --show        # View current settings"
    echo "   $PROJECT_ROOT/.env          # Edit configuration file"
    echo
    echo "Documentation: https://github.com/DominionDev-coder/Pixella-chatbot"
    echo
}

# Main installation flow
main() {
    print_header
    
    detect_installation_mode
    
    check_python_version
    check_dependencies
    
    # Clone if remote installation
    if [ "$INSTALLATION_MODE" = "remote" ]; then
        clone_repository
    fi
    
    setup_directories
    create_env_template
    setup_env_file
    install_requirements
    export_to_path
    verify_installation
    print_next_steps
}

# Run main function
main "$@"
