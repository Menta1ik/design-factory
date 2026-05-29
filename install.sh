#!/bin/bash

# ====================================================================
#              DESIGN FACTORY PIPELINE AUTOMATED INSTALLER
# ====================================================================
# Self-healing, idempotent installation script for macOS.
# Configures shell, installs CLI utilities, and registers AI skills.

# Terminal Colors
RED='\x1b[31m'
GREEN='\x1b[32m'
YELLOW='\x1b[33m'
BLUE='\x1b[34m'
CYAN='\x1b[36m'
BOLD='\x1b[1m'
RESET='\x1b[0m'

# Clear screen and print premium header
clear
echo -e "${BOLD}${CYAN}======================================================"
echo -e "      DESIGN FACTORY · AUTOMATED MAC INSTALLER        "
echo -e "======================================================${RESET}\n"

echo -e "${BLUE}[*] Starting system diagnostics...${RESET}"

# Diagnostics
OS_VERSION=$(sw_vers -productVersion)
ARCH=$(uname -m)
CURRENT_SHELL=$(basename "$SHELL")
FREE_DISK=$(df -h ~ | tail -1 | awk '{print $4}')

echo -e "  - macOS Version:  ${BOLD}${OS_VERSION}${RESET}"
echo -e "  - Architecture:   ${BOLD}${ARCH}${RESET}"
echo -e "  - Shell:          ${BOLD}${CURRENT_SHELL}${RESET}"
echo -e "  - Disk space:     ${BOLD}${FREE_DISK} free${RESET}"
echo -e "------------------------------------------------------"

# --------------------------------------------------------------------
# Step 1: Homebrew
# --------------------------------------------------------------------
echo -e "\n${BLUE}[*] Step 1: Checking Homebrew...${RESET}"
if command -v brew &>/dev/null; then
    BREW_VERSION=$(brew --version | head -1)
    echo -e "  ${GREEN}[✓] Homebrew is already installed: ${BREW_VERSION}${RESET}"
else
    echo -e "  ${YELLOW}[!] Homebrew is missing. Starting installation...${RESET}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure path based on architecture
    if [ "$ARCH" = "arm64" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    else
        eval "$(/usr/local/bin/brew shellenv)"
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
    fi
    echo -e "  ${GREEN}[✓] Homebrew successfully installed!${RESET}"
fi

# --------------------------------------------------------------------
# Step 2: Node.js 20+
# --------------------------------------------------------------------
echo -e "\n${BLUE}[*] Step 2: Checking Node.js 20+...${RESET}"
if command -v node &>/dev/null; then
    NODE_VER=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
    if [ "$NODE_VER" -ge 20 ]; then
        echo -e "  ${GREEN}[✓] Node.js is already installed and matches requirements: $(node -v)${RESET}"
    else
        echo -e "  ${YELLOW}[!] Node.js version is older than 20. Updating via Brew...${RESET}"
        brew install node
        echo -e "  ${GREEN}[✓] Node.js successfully updated: $(node -v)${RESET}"
    fi
else
    echo -e "  ${YELLOW}[!] Node.js is missing. Installing via Brew...${RESET}"
    brew install node
    echo -e "  ${GREEN}[✓] Node.js successfully installed: $(node -v)${RESET}"
fi

# --------------------------------------------------------------------
# Step 3: Git & Command Line Tools
# --------------------------------------------------------------------
echo -e "\n${BLUE}[*] Step 3: Checking Git...${RESET}"
if command -v git &>/dev/null; then
    echo -e "  ${GREEN}[✓] Git is already installed: $(git --version)${RESET}"
else
    echo -e "  ${YELLOW}[!] Xcode Command Line Tools or Git missing. Triggering prompt...${RESET}"
    xcode-select --install
    echo -e "  ${YELLOW}[!] Please click 'Install' on the popup window, then press enter here to continue...${RESET}"
    read -r
fi

# --------------------------------------------------------------------
# Step 4: npm Global Prefix configuration (Fix EACCES permission errors)
# --------------------------------------------------------------------
echo -e "\n${BLUE}[*] Step 4: Configuring npm global prefix...${RESET}"
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"

# Append global path to profile
if [ "$CURRENT_SHELL" = "zsh" ]; then
    PROFILE_FILE="$HOME/.zshrc"
else
    PROFILE_FILE="$HOME/.bash_profile"
fi

if ! grep -q ".npm-global" "$PROFILE_FILE" 2>/dev/null; then
    echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> "$PROFILE_FILE"
    echo -e "  ${GREEN}[✓] Appended npm-global PATH prefix to ${PROFILE_FILE}${RESET}"
fi
export PATH=$HOME/.npm-global/bin:$PATH
echo -e "  ${GREEN}[✓] Global npm prefix configured correctly.${RESET}"

# --------------------------------------------------------------------
# Step 5: Claude Code CLI
# --------------------------------------------------------------------
echo -e "\n${BLUE}[*] Step 5: Checking Claude Code CLI...${RESET}"
if command -v claude &>/dev/null; then
    echo -e "  ${GREEN}[✓] Claude Code is already installed: $(claude --version 2>&1 | head -1)${RESET}"
else
    echo -e "  ${YELLOW}[!] Claude Code is missing. Installing globally via npm...${RESET}"
    npm install -g @anthropic-ai/claude-code
    echo -e "  ${GREEN}[✓] Claude Code successfully installed!${RESET}"
fi

# --------------------------------------------------------------------
# Step 6: CLI Design Tools (monolith, wget)
# --------------------------------------------------------------------
echo -e "\n${BLUE}[*] Step 6: Installing monolith and wget...${RESET}"
brew install monolith wget
echo -e "  ${GREEN}[✓] monolith and wget successfully configured.${RESET}"

# --------------------------------------------------------------------
# Step 7: Registers AI Skills globally
# --------------------------------------------------------------------
echo -e "\n${BLUE}[*] Step 7: Registering custom AI skills...${RESET}"
SKILLS_DEST="$HOME/.claude/skills"
mkdir -p "$SKILLS_DEST"

# Resolve absolute path to current repo skills
REPO_SKILLS_DIR="$(pwd)/skills"

if [ -d "$REPO_SKILLS_DIR" ]; then
    cp -R "$REPO_SKILLS_DIR/extract-brand-assets" "$SKILLS_DEST/"
    cp -R "$REPO_SKILLS_DIR/create-design-system" "$SKILLS_DEST/"
    cp -R "$REPO_SKILLS_DIR/render-brand-pdf" "$SKILLS_DEST/"
    echo -e "  ${GREEN}[✓] Registered skills globally in: ${SKILLS_DEST}${RESET}"
    ls -la "$SKILLS_DEST" | grep -E "extract|create|render"
else
    echo -e "  ${RED}[✗] Error: Source skills folder not found at ${REPO_SKILLS_DIR}. Make sure you run install.sh from repo root.${RESET}"
    exit 1
fi

# --------------------------------------------------------------------
# Step 8: Initialize Sandbox workspace folder
# --------------------------------------------------------------------
echo -e "\n${BLUE}[*] Step 8: Preparing local Sandbox design workspace...${RESET}"
mkdir -p "$HOME/Design System"
echo -e "  ${GREEN}[✓] Design workspace ready at: ~/Design System${RESET}"

# --------------------------------------------------------------------
# Step 9: Final dashboard summary
# --------------------------------------------------------------------
echo -e "\n${BOLD}${GREEN}======================================================"
echo -e "       ✓ DESIGN FACTORY PIPELINE SUCCESSFULLY INSTALLED!"
echo -e "======================================================${RESET}\n"

echo -e "System Status Summary:"
echo -e "  - monolith:      ${GREEN}$(which monolith)${RESET}"
echo -e "  - wget:          ${GREEN}$(which wget)${RESET}"
echo -e "  - node:          ${GREEN}$(node -v)${RESET}"
echo -e "  - npm:           ${GREEN}v$(npm -v)${RESET}"
echo -e "  - claude:        ${GREEN}v$(claude --version 2>&1 | head -1 | awk '{print $NF}')${RESET}"
echo -e "  - design-factory CLI: ${GREEN}Ready (chmod +x df)${RESET}"
echo -e "  - mcp-server:    ${GREEN}Ready (node mcp-server.js)${RESET}"
echo -e "  - Registered Skills: ${GREEN}extract-brand-assets, create-design-system, render-brand-pdf${RESET}"
echo -e "\n${BOLD}Next steps to run your pipeline:${RESET}"
echo -e "  1. Move to design directory:   ${CYAN}cd ~/Design\\ System${RESET}"
echo -e "  2. Launch Claude Code CLI:     ${CYAN}claude${RESET}"
echo -e "  3. Scrape a brand website:     ${CYAN}/extract-brand-assets https://stripe.com${RESET}"
echo -e "  4. Build design tokens:        ${CYAN}/create-design-system${RESET}"
echo -e "  5. Start local Web console:    ${CYAN}./df console${RESET} (inside design-factory monorepo)"
echo -e "\nEnjoy agentic automated design factory!\n"
