# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a remote development environment (RDE) project that creates cloud instances matching a local development environment. The project uses HashiCorp Packer to build AWS AMI images and Terraform to manage EC2 instances.

## Architecture

The project follows a two-stage approach:
1. **Image Building**: Uses Packer to create AWS AMI with pre-configured development environment
2. **Instance Management**: Uses Terraform to provision and manage EC2 instances from the AMI

### Key Components

- **Packer Configuration** (`images/rde.pkr.hcl`): Defines AMI building process using Ubuntu 20.04 base image
- **Terraform Infrastructure** (`instances/`): Manages EC2 instance lifecycle with Terraform Cloud backend
- **Shell Scripts** (`bin/`): Command-line tools for common operations
- **Setup Script** (`images/setup.sh`): Configures the AMI during build process

## Common Commands

### Build AMI Image
```bash
./bin/build-image
```
This script:
- Deletes any existing AMI named "rde-ami"
- Initializes Packer with the configuration
- Builds the new AMI

### Generate SSH Key
```bash
./bin/generate-key
```
Creates SSH key pair in the `keys/` directory for instance access.

### Check Running Status
```bash
./bin/is-it-running
```
Checks if any RDE instances are currently running using both Pulumi stack status and AWS CLI.

### Infrastructure Management
The project uses Pulumi for infrastructure management. Pulumi commands should be run from the `instances/` directory:
```bash
cd instances/
pulumi config set region eu-west-3
pulumi config set ami ami-xxxxxxxxx
pulumi preview
pulumi up
pulumi destroy
```

## Dependencies

- Packer >=1.7.10
- Pulumi >=3.0.0
- Node.js >=18.0.0
- pnpm >=8.0.0
- aws-cli >=2.4.7
- jq >=1.6

## Configuration Details

### Packer Configuration
- **Base Image**: Ubuntu 24.04 LTS (eu-west-3 region)
- **Instance Type**: t2.micro for building
- **SSH Key**: Copies public key from `keys/rde.pub` to instance
- **Development Tools**: Comprehensive toolchain installed (see Current AMI Tools below)

### Pulumi Configuration
- **Runtime**: Node.js with TypeScript
- **Package Manager**: pnpm
- **Provider**: AWS (latest version)
- **Instance Type**: t3.micro
- **Required Config**: `region`, `ami`

## File Structure

- `bin/`: Executable scripts for common operations
- `images/`: Packer configuration and setup scripts
- `instances/`: Pulumi infrastructure definitions
- `keys/`: SSH keys directory (contents ignored by git)

## Development Workflow

1. Generate SSH keys if not present: `./bin/generate-key`
2. Build AMI: `./bin/build-image`
3. Configure Pulumi: Set region and AMI ID in `instances/` directory
4. Deploy instance using Pulumi from `instances/` directory
5. AMI rebuilds will automatically replace existing "rde-ami" image

## Important Notes

- The AMI name "rde-ami" is hardcoded and automatically replaced on rebuild
- SSH access is configured during AMI build process
- Pulumi state is managed locally by default (can be configured for remote backends)
- The setup script (`images/setup.sh`) is minimal and can be extended for additional environment configuration

## Current AMI Tools (ami-01d0865ad581c03f1)

### Priority 1 Tools (Essential & High Usage)
- **Version Control**: git, gh (GitHub CLI)
- **Development Runtimes**: Node.js v22.17.0, npm, pnpm, bun, Python 3.12.3, pipx
- **Containers**: Docker v28.3.2 + docker-compose
- **Productivity**: z (directory jumping), fzf (fuzzy finder), httpie
- **Editors**: vim (enhanced config), tmux (terminal multiplexer)
- **Shell**: zsh with oh-my-zsh, atuin (shell history), claude (Claude Code CLI)
- **System**: curl, wget, unzip, tar, htop, tree, jq

### Priority 2 Tools (Additional Utilities)
- **Cloud**: aws-cli v2.27.50, pulumi v3.181.0
- **Security**: mkcert (local SSL certificates)
- **Modern CLI**: ripgrep (rg), bat/batcat, eza (modern ls)

### Shell Configuration
- **Default Shell**: zsh with oh-my-zsh
- **Aliases**: `bat` → `batcat`, `ls` → `eza`, `ll` → `eza -la`
- **PATH**: Includes ~/.pulumi/bin, ~/.bun/bin, ~/.local/bin, ~/.fzf/bin

### Tool Usage Notes
**✅ Available in PATH**: git, gh, node, npm, pnpm, python3, docker, aws, claude, vim, tmux, curl, jq, httpie, eza, rg, batcat

**Require PATH setup in non-interactive SSH**:
- `pulumi`: use `~/.pulumi/bin/pulumi` or source shell profile
- `bun`: use `~/.bun/bin/bun` or source shell profile  
- `fzf`: use `~/.fzf/bin/fzf` or source shell profile

**Require sourcing**:
- `z`: use `source /usr/local/bin/z.sh` or interactive shell

## Monitoring Running Instances

To check for accidentally running instances:

```bash
# Check by project tag
aws ec2 describe-instances --filters "Name=tag:Project,Values=rde" "Name=instance-state-name,Values=running" --region eu-west-3

# Check all running instances in region
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --region eu-west-3 --query 'Reservations[].Instances[].{ID:InstanceId,Name:Tags[?Key==`Name`].Value|[0],State:State.Name,IP:PublicIpAddress}'

# Check current stack status
cd instances && pulumi stack output
```