# Private Nextcloud

Infrastructure as Code (IaC) for deploying Nextcloud on a private Fedora server using Podman containers managed by systemd units.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This repository provides a complete Infrastructure as Code solution for deploying and managing a Nextcloud instance on a private Fedora server. The deployment uses:

- **Podman** as the container runtime (rootless and daemonless)
- **systemd** units for container lifecycle management
- **GitHub Codespaces** for development environment

The setup is designed to be production-ready, secure, and easy to maintain.

## ✨ Features

- 🐳 Rootless Podman containers for enhanced security
- 🔄 systemd integration for automatic container startup and management
- 🛠️ Complete development environment via GitHub Codespaces
- 📦 Modular and maintainable IaC structure
- 🔒 Security-first approach with minimal privileges
- 📊 Easy monitoring and logging integration

## 📦 Prerequisites

### For Development

- GitHub account with Codespaces access (or)
- Local development with VS Code and Dev Containers extension

### For Deployment

- Fedora Server (tested on Fedora 38+)
- Podman installed (`dnf install podman`)
- systemd (included in Fedora by default)
- Sufficient disk space for Nextcloud data
- Domain name (optional, for HTTPS setup)

## 🚀 Development Setup

### Using GitHub Codespaces (Recommended)

1. **Fork this repository** to your GitHub account

2. **Open in Codespaces:**
   - Click the green "Code" button
   - Select "Codespaces" tab
   - Click "Create codespace on main"

3. **Wait for the devcontainer to build** (first time may take 3-5 minutes)

4. **Start developing!** All required tools are pre-installed:
   - Podman
   - Docker (for compatibility)
   - YAML and container development extensions
   - Shell scripting tools

### Using VS Code Locally

1. **Clone the repository:**
   ```bash
   git clone https://github.com/CWiesbaum/private-nextcloud.git
   cd private-nextcloud
   ```

2. **Open in VS Code:**
   ```bash
   code .
   ```

3. **Reopen in container:**
   - Press `F1` or `Ctrl+Shift+P`
   - Type "Dev Containers: Reopen in Container"
   - Select the option and wait for container to build

4. **Start developing!**

### Dev Container Features

The devcontainer includes:

- **Extensions:**
  - RedHat YAML - YAML language support
  - Docker - Docker support
  - Podman - Podman desktop integration
  - ShellCheck - Shell script linting
  - Shell Format - Shell script formatting
  - EditorConfig - Consistent coding styles
  - Code Spell Checker - Spell checking

- **Tools:**
  - Podman and podman-compose
  - Docker (via Docker-in-Docker feature)
  - Git
  - yamllint
  - Common utilities (curl, wget, jq, vim, etc.)

- **Port Forwarding:**
  - 8080 - Nextcloud HTTP
  - 443 - Nextcloud HTTPS
  - 3306 - MariaDB
  - 5432 - PostgreSQL
  - 6379 - Redis

## 📁 Project Structure

```
private-nextcloud/
├── .devcontainer/           # Development container configuration
│   ├── devcontainer.json   # VS Code devcontainer config
│   └── post-create.sh      # Post-creation setup script
├── containers/             # Container definitions (to be added)
│   ├── nextcloud/         # Nextcloud container config
│   ├── database/          # Database container config
│   └── redis/             # Redis cache container config
├── systemd/               # systemd unit files (to be added)
│   ├── nextcloud.service
│   ├── nextcloud-db.service
│   └── nextcloud-redis.service
├── scripts/               # Helper scripts (to be added)
│   ├── deploy.sh
│   ├── backup.sh
│   └── restore.sh
├── docs/                  # Additional documentation (to be added)
├── LICENSE               # GPL v2 License
└── README.md            # This file
```

## 🚀 Deployment

### Quick Start

> **Note:** Deployment scripts and configurations are under development.

1. **Clone the repository on your Fedora server:**
   ```bash
   git clone https://github.com/CWiesbaum/private-nextcloud.git
   cd private-nextcloud
   ```

2. **Review and customize configuration** (coming soon)

3. **Run the deployment script:**
   ```bash
   ./scripts/deploy.sh
   ```

4. **Enable and start systemd services:**
   ```bash
   systemctl --user enable nextcloud.service
   systemctl --user start nextcloud.service
   ```

### Manual Deployment Steps

Detailed manual deployment steps will be added as the IaC components are developed.

## ⚙️ Configuration

Configuration options will be documented here as they are implemented.

### Environment Variables

- `NEXTCLOUD_DATA_DIR` - Path to Nextcloud data directory
- `NEXTCLOUD_PORT` - HTTP port for Nextcloud (default: 8080)
- `DB_TYPE` - Database type (mariadb/postgresql)
- `DB_PASSWORD` - Database password

### Volume Mounts

- `/var/lib/nextcloud/data` - Nextcloud data
- `/var/lib/nextcloud/config` - Nextcloud configuration
- `/var/lib/nextcloud/db` - Database data

## 🔧 Maintenance

### Backup

```bash
./scripts/backup.sh
```

### Restore

```bash
./scripts/restore.sh /path/to/backup
```

### Update Nextcloud

```bash
# Pull latest image
podman pull docker.io/library/nextcloud:latest

# Restart service
systemctl --user restart nextcloud.service
```

### View Logs

```bash
# Nextcloud logs
journalctl --user -u nextcloud.service -f

# Container logs
podman logs -f nextcloud
```

## 🐛 Troubleshooting

### Container won't start

1. Check systemd service status:
   ```bash
   systemctl --user status nextcloud.service
   ```

2. Check Podman logs:
   ```bash
   podman logs nextcloud
   ```

3. Verify port availability:
   ```bash
   ss -tulpn | grep :8080
   ```

### Permission issues

Ensure proper SELinux contexts if enabled:
```bash
chcon -R -t container_file_t /var/lib/nextcloud/
```

### Database connection issues

1. Verify database container is running:
   ```bash
   podman ps | grep nextcloud-db
   ```

2. Check database logs:
   ```bash
   podman logs nextcloud-db
   ```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the GNU General Public License v2.0 - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Podman Documentation](https://docs.podman.io/)
- [systemd Documentation](https://www.freedesktop.org/software/systemd/man/)
- [Fedora Server Documentation](https://docs.fedoraproject.org/en-US/fedora-server/)

---

**Status:** 🚧 Under Development

This project is actively being developed. Check back for updates or watch the repository for notifications.
