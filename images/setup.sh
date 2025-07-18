#!/bin/bash

set -e

echo "=== RDE AMI Setup Script ==="
echo "Setting up development environment..."
echo "Started at: $(date)"

# Function to log progress
log_progress() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Update system packages
log_progress "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install essential system tools
echo "Installing essential system tools..."
sudo apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    tar \
    htop \
    tree \
    jq \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install GitHub CLI
echo "Installing GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get install -y gh

# Install Node.js (LTS) and package managers
echo "Installing Node.js and package managers..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pnpm

# Install Bun
echo "Installing Bun..."
curl -fsSL https://bun.sh/install | bash
echo 'export PATH="$HOME/.bun/bin:$PATH"' >> /home/ubuntu/.bashrc

# Install Python and pipx
echo "Installing Python and pipx..."
sudo apt-get install -y python3 python3-pip python3-venv python3-full pipx
# Use system package for pipx instead of pip install
echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/ubuntu/.bashrc

# Install Docker with retry logic
log_progress "Installing Docker..."
install_docker() {
    echo "Adding Docker GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    echo "Adding Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    echo "Updating package list..."
    sudo apt-get update
    
    echo "Installing Docker packages (this may take several minutes)..."
    # Use timeout to prevent hanging
    timeout 600 sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin || {
        echo "Docker installation timed out or failed, retrying..."
        sleep 10
        sudo apt-get clean
        sudo apt-get update
        timeout 600 sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    }
    
    echo "Adding ubuntu user to docker group..."
    sudo usermod -aG docker ubuntu
    
    echo "Docker installation completed successfully"
}

install_docker

# Install productivity tools
echo "Installing productivity tools..."
# Install z (directory jumping)
git clone https://github.com/rupa/z.git /tmp/z
sudo cp /tmp/z/z.sh /usr/local/bin/z.sh
echo 'source /usr/local/bin/z.sh' >> /home/ubuntu/.bashrc

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git /home/ubuntu/.fzf
chown -R ubuntu:ubuntu /home/ubuntu/.fzf
sudo -u ubuntu /home/ubuntu/.fzf/install --all
# Add fzf to PATH for bash
echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> /home/ubuntu/.bashrc

# Install HTTPie
sudo apt-get install -y httpie

# Install vim with enhanced configuration
echo "Installing and configuring vim..."
sudo apt-get install -y vim
# Basic vim configuration
cat > /home/ubuntu/.vimrc << 'EOF'
set number
set hlsearch
set incsearch
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
syntax on
set background=dark
EOF
chown ubuntu:ubuntu /home/ubuntu/.vimrc

# Install tmux and mosh
echo "Installing tmux and mosh..."
sudo apt-get install -y tmux mosh

# Install zsh (without oh-my-zsh)
echo "Installing zsh..."
sudo apt-get install -y zsh
sudo chsh -s $(which zsh) ubuntu

# Configure basic zsh
cat > /home/ubuntu/.zshrc << 'EOF'
# Basic zsh configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob nomatch notify
bindkey -e

# Basic prompt
autoload -U colors && colors
PS1="%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$ "

# Load z for directory jumping
source /usr/local/bin/z.sh

# Load fzf key bindings and completion
source ~/.fzf/shell/key-bindings.zsh
source ~/.fzf/shell/completion.zsh

# Path additions
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.pulumi/bin:$PATH"
export PATH="$HOME/.fzf/bin:$PATH"

# Aliases
alias bat=batcat
alias ls="eza"
alias ll="eza -la"

# Atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
EOF
chown ubuntu:ubuntu /home/ubuntu/.zshrc

# Install atuin (shell history)
echo "Installing atuin..."
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sudo -u ubuntu sh

# Install claude (Claude Code CLI)
echo "Installing claude..."
sudo npm install -g @anthropic-ai/claude-code

# Install Priority 2 development utilities
echo "Installing additional development utilities..."

# Install AWS CLI
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

# Install mkcert for local SSL certificates
echo "Installing mkcert..."
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert

# Install ripgrep (rg) for fast text search
echo "Installing ripgrep..."
sudo apt-get install -y ripgrep

# Install bat (enhanced cat)
echo "Installing bat..."
sudo apt-get install -y bat
# Create batcat alias as bat (Ubuntu uses batcat to avoid conflict)
echo 'alias bat=batcat' >> /home/ubuntu/.bashrc

# Install eza (modern ls replacement, successor to exa)
echo "Installing eza..."
sudo apt-get install -y eza
echo 'alias ls="eza"' >> /home/ubuntu/.bashrc
echo 'alias ll="eza -la"' >> /home/ubuntu/.bashrc

# Install Pulumi
echo "Installing Pulumi..."
curl -fsSL https://get.pulumi.com | sh
echo 'export PATH="$HOME/.pulumi/bin:$PATH"' >> /home/ubuntu/.bashrc

# Setup SSH keys
echo "Setting up SSH keys..."
sudo cp /tmp/rde.pub /home/ubuntu/.ssh/authorized_keys
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys

# Run GitHub preparation
log_progress "Preparing GitHub authentication..."
chmod +x /tmp/github-prep.sh
/tmp/github-prep.sh

log_progress "Final ownership setup..."
# Set proper ownership for home directory
sudo chown -R ubuntu:ubuntu /home/ubuntu

echo "=== RDE AMI Setup Complete ==="
echo "Completed at: $(date)"
echo "Priority 1 tools: git, gh, node/pnpm, bun, python/pipx, docker, z, fzf, httpie, vim, tmux, mosh, zsh, atuin, claude"
echo "Priority 2 tools: aws-cli, mkcert, ripgrep, bat, eza, pulumi"
echo "Shell: zsh with custom configuration as default"
echo "GitHub: SSH configuration and setup script ready"
echo "Ready for development work!"
