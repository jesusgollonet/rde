#!/bin/bash

# GitHub Preparation Script for AMI
# This script prepares the AMI for GitHub authentication setup
# The actual authentication will be done by the user on first use

set -e

echo "=== Preparing GitHub Authentication ==="

# Ensure SSH directory exists with correct permissions
mkdir -p /home/ubuntu/.ssh
chown ubuntu:ubuntu /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh

# Create SSH config for GitHub
cat > /home/ubuntu/.ssh/config << 'EOF'
# GitHub SSH configuration
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
    UseKeychain yes
EOF

chown ubuntu:ubuntu /home/ubuntu/.ssh/config
chmod 600 /home/ubuntu/.ssh/config

# Set up Git global configuration with sensible defaults
# User will override these with their own details
sudo -u ubuntu git config --global init.defaultBranch main
sudo -u ubuntu git config --global pull.rebase false
sudo -u ubuntu git config --global push.default simple
sudo -u ubuntu git config --global core.editor vim
sudo -u ubuntu git config --global url."git@github.com:".insteadOf "https://github.com/"

# Create a helper script for first-time GitHub setup
cat > /home/ubuntu/setup-github.sh << 'EOF'
#!/bin/bash

echo "=== First-time GitHub Setup ==="
echo "This will help you set up GitHub authentication."
echo

# Check if already set up
if [ -f ~/.ssh/id_ed25519 ] && git config --global user.name >/dev/null 2>&1; then
    echo "GitHub appears to already be set up."
    echo "Git user: $(git config --global user.name) <$(git config --global user.email)>"
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "✅ SSH key is working with GitHub"
    else
        echo "⚠️  SSH key may need to be added to GitHub"
    fi
    echo
    read -p "Do you want to reconfigure? (y/N): " reconfigure
    if [ "$reconfigure" != "y" ] && [ "$reconfigure" != "Y" ]; then
        exit 0
    fi
fi

# Get user details
read -p "Enter your full name for Git: " git_name
read -p "Enter your email address for Git: " git_email

if [ -z "$git_name" ] || [ -z "$git_email" ]; then
    echo "❌ Name and email are required"
    exit 1
fi

# Configure Git
git config --global user.name "$git_name"
git config --global user.email "$git_email"

# Generate SSH key if needed
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating SSH key for GitHub..."
    ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N ""
fi

# Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

echo
echo "📋 Add this SSH key to your GitHub account:"
echo "https://github.com/settings/ssh/new"
echo
cat ~/.ssh/id_ed25519.pub
echo
echo "After adding the key to GitHub, you can:"
echo "  - Clone repos: git clone git@github.com:owner/repo.git"
echo "  - Use GitHub CLI: gh auth login"
echo "  - Test SSH: ssh -T git@github.com"
EOF

chown ubuntu:ubuntu /home/ubuntu/setup-github.sh
chmod +x /home/ubuntu/setup-github.sh

# Add GitHub setup reminder to shell profiles
echo 'echo "💡 Run ~/setup-github.sh to configure GitHub authentication"' >> /home/ubuntu/.bashrc
echo 'echo "💡 Run ~/setup-github.sh to configure GitHub authentication"' >> /home/ubuntu/.zshrc

echo "✅ GitHub preparation complete"
echo "Users can run ~/setup-github.sh on first login to set up authentication"