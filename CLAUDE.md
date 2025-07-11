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

### Infrastructure Management
The project uses Terraform Cloud for state management. Terraform commands should be run from the `instances/` directory:
```bash
cd instances/
terraform plan
terraform apply
terraform destroy
```

## Dependencies

- Packer >=1.7.10
- Terraform >=1.1.7  
- aws-cli >=2.4.7
- jq >=1.6

## Configuration Details

### Packer Configuration
- **Base Image**: Ubuntu 20.04 LTS (eu-west-3 region)
- **Instance Type**: t2.micro for building
- **SSH Key**: Copies public key from `keys/rde.pub` to instance

### Terraform Configuration
- **Backend**: Terraform Cloud (organization: "jgb", workspace: "rde")
- **Provider**: AWS ~> 3.26.0
- **Instance Type**: t3.micro
- **Required Variables**: `region`, `ami`

## File Structure

- `bin/`: Executable scripts for common operations
- `images/`: Packer configuration and setup scripts
- `instances/`: Terraform infrastructure definitions
- `keys/`: SSH keys directory (contents ignored by git)

## Development Workflow

1. Generate SSH keys if not present: `./bin/generate-key`
2. Build AMI: `./bin/build-image`
3. Deploy instance using Terraform from `instances/` directory
4. AMI rebuilds will automatically replace existing "rde-ami" image

## Important Notes

- The AMI name "rde-ami" is hardcoded and automatically replaced on rebuild
- SSH access is configured during AMI build process
- Terraform state is managed remotely via Terraform Cloud
- The setup script (`images/setup.sh`) is minimal and can be extended for additional environment configuration