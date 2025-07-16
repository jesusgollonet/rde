# Blink.sh Configuration Templates

## Quick Setup Guide

### 1. Import SSH Key

**Method 1: QR Code (Recommended)**
```bash
# On your computer, in the RDE project directory
./bin/export-key-qr
```
- Scan the QR code with your iPad camera
- In Blink.sh: Keys → Add → Import from Clipboard → New RSA Key
- Name: `rde`

**Method 2: Manual Copy**
- Copy private key content: `cat keys/rde | pbcopy`
- Transfer to iPad (AirDrop, email, etc.)
- In Blink.sh: Keys → Add → Import from Clipboard → New RSA Key

### 2. Configure Host

Get connection info:
```bash
./bin/show-connection-info
```

**Blink.sh Host Configuration:**
1. Settings → Hosts → Add
2. Configure:
   - **Host**: `rde`
   - **Hostname**: `<your-instance-ip>`
   - **Port**: `22`
   - **User**: `ubuntu`
   - **Key**: `rde` (the key you imported)

### 3. Connect

**SSH Connection:**
```bash
ssh rde
```

**Mosh Connection (Recommended for iPad):**
```bash
mosh rde
```

## Advanced Configuration

### Multiple Environments

For different environments (dev, staging, prod):

```bash
# Host: rde-dev
# Hostname: <dev-instance-ip>
# User: ubuntu
# Key: rde

# Host: rde-staging  
# Hostname: <staging-instance-ip>
# User: ubuntu
# Key: rde
```

### Custom Connection Scripts

Create aliases in Blink.sh:
```bash
# SSH with verbose output
alias rde-debug="ssh -v rde"

# Mosh with custom port range
alias rde-mosh-alt="mosh --ssh='ssh -p 22' rde"
```

## Troubleshooting

### Connection Issues

**Check instance status:**
```bash
./bin/is-it-running
```

**Verbose SSH connection:**
```bash
ssh -v rde
```

**Test key authentication:**
```bash
ssh -i ~/.ssh/rde -o PreferredAuthentications=publickey ubuntu@<ip>
```

### Mosh Issues

**Check UDP ports:**
- Ensure UDP ports 60000-61000 are open
- Try SSH first to verify basic connectivity
- Check network restrictions (corporate firewalls)

**Mosh server not found:**
```bash
# Connect via SSH and check mosh installation
ssh rde
which mosh-server
```

### Key Import Problems

**Key format issues:**
- Ensure private key starts with `-----BEGIN RSA PRIVATE KEY-----`
- Check for extra whitespace or line breaks
- Try re-generating the key: `./bin/generate-key`

**Clipboard issues:**
- Clear clipboard before importing
- Try manual key entry in Blink.sh
- Use QR code method as alternative

## Security Best Practices

### Key Management
- Use different keys for different devices when possible
- Rotate keys regularly
- Enable Blink.sh app protection with FaceID/TouchID
- Never share private keys in plain text

### Network Security
- Use mosh over untrusted networks
- Monitor connection logs
- Regularly update Blink.sh app
- Use VPN for additional security layer

### Instance Security
- Keep RDE instances updated
- Monitor SSH login attempts
- Use strong passwords for system accounts
- Enable fail2ban for SSH protection

## Performance Tips

### Optimal Settings
- Use mosh for mobile connections
- Enable compression for slow networks
- Configure appropriate timeout values
- Use terminal multiplexer (tmux) for persistence

### Battery Optimization
- Close unused connections
- Use background app refresh wisely
- Consider connection pooling for frequent use
- Monitor data usage on cellular networks