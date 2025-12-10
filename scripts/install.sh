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
            ;;;
        CYGWIN*|MINGW32*|MSYS*|windows*) 
            OS_TYPE="Windows"
            # WSL/Git Bash compatible activation
            VENV_ACTIVATE_CMD="source \"$VENV_DIR/Scripts/activate\""
            VENV_PYTHON_BIN="\"$VENV_DIR/Scripts/python.exe\"" # Use python.exe for clarity
            print_warning "Detected Windows. Using WSL/Git Bash compatible commands."
            print_warning "For native PowerShell/CMD, manual steps may be needed for PATH."
            ;;;
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

manual_python_installation() {
    print_step "Manual Python Installation"
    print_warning "Please download and install Python 3.11 from python.org"
    
    while true; do
        read -p "Have you installed Python 3.11? (yes/no) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if command -v python3.11 &> /dev/null; then
                print_success "Python 3.11 is now installed."
                PYTHON_CMD="python3.11"
                return 0
            else
                print_error "Python 3.11 not found in PATH."
                read -p "Continue with another Python version? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Nn]$ ]]; then
                    cleanup_and_abort
                else
                    return 1
                fi
            fi
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            read -p "Continue with another Python version? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                cleanup_and_abort
            else
                return 1
            fi
        fi
    done
}

install_python3_11() {
    print_step "Attempting to install Python 3.11..."
    
    case "$OS_TYPE" in
        macOS) 
            if ! command -v brew &> /dev/null; then
                print_error "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            brew install python@3.11
            ;; 
        Linux) 
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y python3.11
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y python3.11
            elif command -v yum &> /dev/null; then
                sudo yum install -y python3.11
            else
                print_error "Unsupported Linux distribution."
                return 1
            fi
            ;; 
        Windows) 
            print_error "Automatic installation of Python on Windows is not supported."
            return 1
            ;; 
    esac
    
    if command -v python3.11 &> /dev/null; then
        print_success "Python 3.11 installed successfully."
        PYTHON_CMD="python3.11"
        return 0
    else
        print_error "Python 3.11 installation failed."
        manual_python_installation
        return $?
    fi
}

check_python_version() {
    print_step "Checking for a compatible Python version..."
    
    if command -v python3.11 &> /dev/null; then
        PYTHON_CMD="python3.11"
        print_success "Found recommended Python version: $PYTHON_CMD"
        return
    fi

    print_warning "Python 3.11 is recommended."
    read -p "Python 3.11 not found. Install it now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_python3_11
        if [ $? -ne 0 ]; then
            # If installation fails and user wants to continue with another version
            for cmd in python3.12 python3.13; do
                if command -v "$cmd" &> /dev/null; then
                    PYTHON_CMD="$cmd"
                    print_success "Found compatible Python version: $PYTHON_CMD"
                    return
                fi
            done
        else
            return
        fi
    fi
    
    for cmd in python3.12 python3.13; do
        if command -v "$cmd" &> /dev/null; then
            PYTHON_CMD="$cmd"
            print_success "Found compatible Python version: $PYTHON_CMD"
            return
        fi
    done
    
    print_error "No compatible Python version found (tried 3.11, 3.12, 3.13)."
    cleanup_and_abort
}

cleanup_and_abort() {
    print_error "Installation aborted."
    if [ "$INSTALLATION_MODE" = "remote" ]; then
        print_step "Cleaning up cloned repository..."
        rm -rf "$PROJECT_ROOT"
        print_success "Cleanup complete."
    fi
    exit 1
}


create_and_activate_venv() {
    print_step "Checking for virtual environment..."

    if [ -d "$VENV_DIR" ]; then
        print_warning "Virtual environment already exists. Reusing it."
        eval "$VENV_ACTIVATE_CMD" || {
            print_error "Failed to activate virtual environment using '$VENV_ACTIVATE_CMD'"
            exit 1
        }
        print_success "Virtual environment activated."
        PYTHON_CMD="$VENV_PYTHON_BIN"
        return
    fi

    read -p "Create and use a virtual environment (.venv)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Creating and activating Python virtual environment ($VENV_DIR)..."
        "$PYTHON_CMD" -m venv "$VENV_DIR" || {
            print_error "Failed to create virtual environment"
            exit 1
        }
        print_success "Virtual environment created."
        
        eval "$VENV_ACTIVATE_CMD" || {
            print_error "Failed to activate virtual environment using '$VENV_ACTIVATE_CMD'"
            exit 1
        }
        print_success "Virtual environment activated."
        
        PYTHON_CMD="$VENV_PYTHON_BIN"
    else
        print_warning "Skipping virtual environment. Using system Python."
    fi
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
                f.write(f"{key_to_update}={new_value}\n")
            return

        with open(env_file, 'r') as f:
            lines = f.readlines()

        updated = False
        with open(env_file, 'w') as f:
            for line in lines:
                if line.strip().startswith(f"{key_to_update}="):
                    f.write(f"{key_to_update}={new_value}\n")
                    updated = True
                else:
                    f.write(line)
            if not updated:
                f.write(f"{key_to_update}={new_value}\n")
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

update_pixella_executable() {
    print_step "Updating pixella executable..."
    
    local pixella_executable="$PROJECT_ROOT/bin/pixella"
    
    # Escape for sed
    local escaped_python_cmd=$(printf '%s\n' "$PYTHON_CMD" | sed 's:[&/\\]:\\&:g')

    if [ -f "$pixella_executable" ]; then
        # Replace the placeholder with the correct python command
        sed -i.bak "s|PYTHON_CMD_PLACEHOLDER|$escaped_python_cmd|g" "$pixella_executable"
        rm "${pixella_executable}.bak"
        print_success "pixella executable updated to use $PYTHON_CMD"
    else
        print_warning "pixella executable not found. Skipping update."
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
    
    detect_os
    detect_installation_mode
    
    check_python_version
    check_dependencies
    
    # Clone if remote installation
    if [ "$INSTALLATION_MODE" = "remote" ]; then
        clone_repository
    fi
    
    cd "$PROJECT_ROOT"
    
    create_and_activate_venv
    
    update_pixella_executable

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
