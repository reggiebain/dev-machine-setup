#!/bin/bash

# ============================================
# Dev Machine Setup Script
# For: MacBook Pro @ Harvard Business Publishing
# Role: ML Scientist
# ============================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

# ============================================
# Pre-flight Checks
# ============================================
print_header "Pre-flight Checks"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

print_success "Running on macOS"

# Check for Apple Silicon
if [[ $(uname -m) == "arm64" ]]; then
    print_success "Apple Silicon detected"
    BREW_PREFIX="/opt/homebrew"
else
    print_warning "Intel Mac detected (some performance may vary)"
    BREW_PREFIX="/usr/local"
fi

# ============================================
# PHASE 1: Install Homebrew
# ============================================
print_header "Phase 1: Installing Homebrew"

if command -v brew &> /dev/null; then
    print_success "Homebrew already installed"
else
    print_info "Installing Homebrew..."
    print_warning "You may need to enter your password and approve IT prompts"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    eval "$($BREW_PREFIX/bin/brew shellenv)"
    print_success "Homebrew installed"
fi

# Ensure Homebrew is in PATH
eval "$($BREW_PREFIX/bin/brew shellenv)"

# ============================================
# PHASE 2: Install Homebrew Packages
# ============================================
print_header "Phase 2: Installing Homebrew Packages"

if [ -f "Brewfile" ]; then
    print_info "Installing packages from Brewfile..."
    print_warning "This may take 10-15 minutes and require IT approval for some apps"
    
    # Install packages, continue even if some fail
    brew bundle install --file=Brewfile || true
    
    print_success "Homebrew packages installed"
else
    print_warning "No Brewfile found, installing core packages manually..."
    
    # Core CLI tools
    brew install git neovim ripgrep fd fzf bat eza tree jq httpie curl wget
    
    # Applications
    brew install --cask cursor visual-studio-code warp dbeaver-community
    
    print_success "Core packages installed"
fi

# ============================================
# PHASE 3: Install uv (Python Package Manager)
# ============================================
print_header "Phase 3: Installing uv"

if command -v uv &> /dev/null; then
    print_success "uv already installed: $(uv --version)"
else
    print_info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add uv to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    
    print_success "uv installed"
fi

# Install Python 3.12 via uv
print_info "Installing Python 3.12 via uv..."
uv python install 3.12
print_success "Python 3.12 installed"

# ============================================
# PHASE 4: Install Ollama
# ============================================
print_header "Phase 4: Installing Ollama"

if command -v ollama &> /dev/null; then
    print_success "Ollama already installed"
else
    print_info "Installing Ollama..."
    print_warning "This may require IT approval"
    curl -fsSL https://ollama.com/install.sh | sh
    print_success "Ollama installed"
fi

# ============================================
# PHASE 5: Download Ollama Models
# ============================================
print_header "Phase 5: Downloading Ollama Models"

print_info "This will download ~10GB of models. Continue? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    print_info "Starting Ollama service..."
    ollama serve &> /dev/null &
    sleep 3
    
    print_info "Downloading DeepSeek Coder 6.7B (~4.4GB)..."
    ollama pull deepseek-coder:6.7b
    
    print_info "Downloading Qwen 2.5 Coder 7B (~4.7GB)..."
    ollama pull qwen2.5-coder:7b
    
    print_success "Models downloaded"
    ollama list
else
    print_warning "Skipping model download. Run later with:"
    echo "  ollama pull deepseek-coder:6.7b"
    echo "  ollama pull qwen2.5-coder:7b"
fi

# ============================================
# PHASE 6: Setup LazyVim (Neovim)
# ============================================
print_header "Phase 6: Setting up LazyVim"

if [ -d "$HOME/.config/nvim" ]; then
    print_warning "Neovim config already exists at ~/.config/nvim"
    print_info "Skipping LazyVim installation"
else
    print_info "Installing LazyVim..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    print_success "LazyVim installed (run 'nvim' to complete plugin installation)"
fi

# ============================================
# PHASE 7: Configure Shell (.zshrc)
# ============================================
print_header "Phase 7: Configuring Shell"

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d)"
    print_info "Backed up existing .zshrc"
fi

# Copy our .zshrc
if [ -f "configs/shell/.zshrc" ]; then
    cp configs/shell/.zshrc "$HOME/.zshrc"
    print_success "Shell configuration installed"
else
    print_warning "No .zshrc found in configs/shell/, creating basic config..."
    cat >> "$HOME/.zshrc" << 'EOF'

# ========================================
# HBP Dev Environment (Added by setup.sh)
# ========================================

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# uv / Python
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="nvim"
alias vim='nvim'

# Navigation
alias dev="cd ~/dev"
alias hbp="cd ~/dev/hbp"

# Git shortcuts
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"

# Better tools (if installed)
if command -v eza &> /dev/null; then
    alias ls="eza -la --icons"
    alias ll="eza -l --icons"
fi

if command -v bat &> /dev/null; then
    alias cat="bat"
fi
EOF
    print_success "Basic shell configuration added"
fi

# ============================================
# PHASE 8: Configure Git
# ============================================
print_header "Phase 8: Configuring Git"

print_info "Setting up Git for HBP..."
git config --global user.name "Reginald Bain"
git config --global user.email "reginald.bain@harvardbusiness.org"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor "nvim"

print_success "Git configured for HBP"
echo "  Name:  $(git config --global user.name)"
echo "  Email: $(git config --global user.email)"

# ============================================
# PHASE 9: Configure Continue.dev
# ============================================
print_header "Phase 9: Configuring Continue.dev"

CONTINUE_CONFIG_DIR="$HOME/.continue"
mkdir -p "$CONTINUE_CONFIG_DIR"

if [ -f "configs/continue/config.ts" ]; then
    print_info "Copying Continue.dev configuration..."
    cp configs/continue/config.ts "$CONTINUE_CONFIG_DIR/config.ts"
    print_success "Continue.dev configured for local Ollama models"
else
    print_warning "No Continue.dev config found, creating default..."
    cat > "$CONTINUE_CONFIG_DIR/config.ts" << 'EOF'
export function modifyConfig(config: Config): Config {
  return {
    models: [
      {
        title: "DeepSeek Coder (Local - HBP Safe)",
        provider: "ollama",
        model: "deepseek-coder:6.7b",
        apiBase: "http://localhost:11434",
      },
      {
        title: "Qwen 2.5 Coder (Local)",
        provider: "ollama",
        model: "qwen2.5-coder:7b",
        apiBase: "http://localhost:11434",
      },
    ],
    tabAutocompleteModel: {
      title: "DeepSeek Autocomplete",
      provider: "ollama",
      model: "deepseek-coder:6.7b",
    },
    allowAnonymousTelemetry: false,
  };
}
EOF
    print_success "Default Continue.dev configuration created"
fi

# ============================================
# PHASE 10: Create Development Directories
# ============================================
print_header "Phase 10: Creating Development Directories"

print_info "Creating standard development directories..."
mkdir -p ~/dev/{hbp,experiments,learning,notebooks}

print_success "Development directories created:"
echo "  ~/dev/hbp         - HBP work projects"
echo "  ~/dev/experiments - Quick experiments"
echo "  ~/dev/learning    - Learning projects"
echo "  ~/dev/notebooks   - Jupyter notebooks"

# ============================================
# PHASE 11: Verify Installation
# ============================================
print_header "Phase 11: Verifying Installation"

echo ""
echo "Checking installed tools..."
echo ""

# Function to check if command exists
check_tool() {
    if command -v "$1" &> /dev/null; then
        print_success "$1: $(command -v $1)"
    else
        print_error "$1: NOT FOUND"
    fi
}

check_tool "brew"
check_tool "git"
check_tool "uv"
check_tool "nvim"
check_tool "ollama"
check_tool "rg"
check_tool "fd"
check_tool "bat"

echo ""
print_info "Checking Python..."
if uv python list | grep -q "3.12"; then
    print_success "Python 3.12 available via uv"
else
    print_warning "Python 3.12 may need to be installed: uv python install 3.12"
fi

echo ""
print_info "Checking Ollama models..."
if command -v ollama &> /dev/null; then
    ollama list 2>/dev/null || print_warning "Ollama service not running"
fi

# ============================================
# Completion
# ============================================
print_header "Installation Complete! 🎉"

echo ""
print_success "Core tools installed successfully!"
echo ""
print_info "Next Steps:"
echo "  1. Restart your terminal (or run: source ~/.zshrc)"
echo "  2. Open Cursor and install extensions:"
echo "     - Continue (for local AI coding)"
echo "     - Python"
echo "     - Jupyter"
echo "     - Snowflake"
echo "  3. Generate SSH keys for GitHub:"
echo "     ssh-keygen -t ed25519 -C \"reginald.bain@harvardbusiness.org\""
echo "  4. Test Ollama:"
echo "     ollama run deepseek-coder:6.7b \"Write hello world in Python\""
echo "  5. See CHECKLIST.md for remaining manual steps"
echo ""
print_warning "Don't forget to run 'nvim' once to complete LazyVim plugin installation"
echo ""
print_info "For detailed setup steps, see: CHECKLIST.md"
echo ""
print_success "Happy coding! 🚀"
echo ""
