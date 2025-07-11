#!/bin/bash

set -e

echo "=== RDE AMI Setup Script ==="
echo "Setting up development environment..."

# Update system packages
echo "Updating system packages..."
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

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker ubuntu

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
# Add fzf to PATH
echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> /home/ubuntu/.bashrc
echo 'export PATH="$HOME/.fzf/bin:$PATH"' >> /home/ubuntu/.zshrc

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

# Install tmux
echo "Installing tmux..."
sudo apt-get install -y tmux

# Install zsh and oh-my-zsh
echo "Installing zsh and oh-my-zsh..."
sudo apt-get install -y zsh
sudo -u ubuntu sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo chsh -s $(which zsh) ubuntu

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
echo 'alias bat=batcat' >> /home/ubuntu/.zshrc

# Install eza (modern ls replacement, successor to exa)
echo "Installing eza..."
sudo apt-get install -y eza
echo 'alias ls="eza"' >> /home/ubuntu/.bashrc
echo 'alias ls="eza"' >> /home/ubuntu/.zshrc
echo 'alias ll="eza -la"' >> /home/ubuntu/.bashrc
echo 'alias ll="eza -la"' >> /home/ubuntu/.zshrc

# Install Pulumi
echo "Installing Pulumi..."
curl -fsSL https://get.pulumi.com | sh
echo 'export PATH="$HOME/.pulumi/bin:$PATH"' >> /home/ubuntu/.bashrc
echo 'export PATH="$HOME/.pulumi/bin:$PATH"' >> /home/ubuntu/.zshrc

# Setup SSH keys
echo "Setting up SSH keys..."
sudo cp /tmp/rde.pub /home/ubuntu/.ssh/authorized_keys
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys

# Set proper ownership for home directory
sudo chown -R ubuntu:ubuntu /home/ubuntu

echo "=== RDE AMI Setup Complete ==="
echo "Priority 1 tools: git, gh, node/pnpm, bun, python/pipx, docker, z, fzf, httpie, vim, tmux, zsh, atuin, claude"
echo "Priority 2 tools: aws-cli, mkcert, ripgrep, bat, eza, pulumi"
echo "Shell: zsh with oh-my-zsh configured as default"
echo "Ready for development work!"
