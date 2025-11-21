# Private Nextcloud

Infrastructure as Code (IaC) for deploying Nextcloud on a private Fedora server using Docker Compose to orchestrate Podman containers.

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

- **Docker Compose** for orchestrating the complete container stack
- **Podman** as the container runtime (rootless and daemonless)
- **GitHub Codespaces** for development environment

The setup is designed to be production-ready, secure, and easy to maintain.

## ✨ Features

- 🐳 Rootless Podman containers for enhanced security
- 🎼 Docker Compose orchestration for complete stack management
- 🛠️ Complete development environment via GitHub Codespaces
- 📦 Modular and maintainable IaC structure
- 🔒 Security-first approach with minimal privileges
- 📊 Easy monitoring and logging via compose

## 📦 Prerequisites

### For Development

- GitHub account with Codespaces access (or)
- Local development with VS Code and Dev Containers extension

### For Deployment

- Fedora Server (tested on Fedora 38+)
- Podman installed (`dnf install podman`)
- podman-compose installed (`dnf install podman-compose` or `pip3 install podman-compose`)
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
  - Docker and docker-compose (via Docker-in-Docker feature)
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
├── .devcontainer/              # Development container configuration
│   ├── devcontainer.json      # VS Code devcontainer config
│   └── post-create.sh         # Post-creation setup script
├── compose/                    # Docker Compose stack definitions
│   ├── docker-compose.yml     # Main compose file
│   ├── docker-compose.prod.yml # Production overrides
│   └── .env.example           # Environment variables template
├── config/                     # Service-specific configurations
│   ├── nextcloud/             # Nextcloud configuration files
│   ├── database/              # Database init scripts
│   └── redis/                 # Redis configuration
├── scripts/                    # Helper scripts
│   ├── deploy.sh              # Deployment script
│   ├── backup.sh              # Backup script
│   └── restore.sh             # Restore script
├── LICENSE                     # GPL v2 License
└── README.md                  # This file
```

## 🚀 Deployment

### Quick Start

> **Note:** Deployment scripts and configurations are under development.

1. **Clone the repository on your Fedora server:**
   ```bash
   git clone https://github.com/CWiesbaum/private-nextcloud.git
   cd private-nextcloud
   ```

2. **Configure environment variables:**
   ```bash
   cd compose
   cp .env.example .env
   # Edit .env with your configuration
   nano .env
   ```

3. **Deploy the stack:**
   ```bash
   podman-compose up -d
   ```

4. **Verify deployment:**
   ```bash
   podman-compose ps
   podman-compose logs -f
   ```

### Using the Deployment Script

Alternatively, use the automated deployment script:

```bash
./scripts/deploy.sh
```

## ⚙️ Configuration

### Environment Variables

Configuration is managed through the `.env` file in the `compose/` directory. Copy `.env.example` to `.env` and customize:

- `NEXTCLOUD_PORT` - HTTP port for Nextcloud (default: 8080)
- `DB_TYPE` - Database type (mariadb/postgresql)
- `DB_ROOT_PASSWORD` - Database root password
- `DB_PASSWORD` - Nextcloud database password
- `DB_NAME` - Database name (default: nextcloud)
- `REDIS_PASSWORD` - Redis password (optional)
- `UID` - User ID for rootless operation (default: 1000)
- `GID` - Group ID for rootless operation (default: 1000)

### Docker Compose Configuration

The main stack is defined in `compose/docker-compose.yml`. For production deployments, override settings using `compose/docker-compose.prod.yml`:

```bash
podman-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Volumes

The stack uses named Docker volumes for data persistence:

- `nextcloud_data` - Nextcloud application data
- `nextcloud_config` - Nextcloud configuration files
- `db_data` - Database files
- `redis_data` - Redis persistence (optional)

To backup volumes, see the [Maintenance](#-maintenance) section.

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
# Navigate to compose directory
cd compose

# Pull latest images
podman-compose pull

# Recreate containers with new images
podman-compose up -d
```

### View Logs

```bash
# All services
podman-compose logs -f

# Specific service
podman-compose logs -f nextcloud

# View last 100 lines
podman-compose logs --tail=100 nextcloud
```

### Stop/Start Stack

```bash
# Stop all services
podman-compose down

# Start all services
podman-compose up -d

# Restart specific service
podman-compose restart nextcloud
```

## 🐛 Troubleshooting

### Stack won't start

1. Check compose file syntax:
   ```bash
   podman-compose config
   ```

2. Check service status:
   ```bash
   podman-compose ps
   ```

3. View service logs:
   ```bash
   podman-compose logs
   ```

4. Verify port availability:
   ```bash
   ss -tulpn | grep :8080
   ```

### Service-specific issues

Check individual service logs:
```bash
# Nextcloud
podman-compose logs nextcloud

# Database
podman-compose logs db

# Redis
podman-compose logs redis
```

### Permission issues

Ensure proper user/group IDs are set in `.env` (defaults to 1000:1000 if not set):
```bash
# Edit the .env file and add/update your user's UID and GID
cd compose
cp .env.example .env
# Then add these lines to .env:
# UID=1000  # Replace with your $(id -u)
# GID=1000  # Replace with your $(id -g)

# Or set them automatically (be careful not to run multiple times):
grep -q "^UID=" .env || echo "UID=$(id -u)" >> .env
grep -q "^GID=" .env || echo "GID=$(id -g)" >> .env
```

For SELinux contexts (Fedora):
```bash
# Check if SELinux is enforcing
getenforce

# Add :z label to bind mounts in docker-compose.yml if needed
```

### Database connection issues

1. Verify database service is running:
   ```bash
   podman-compose ps db
   ```

2. Check database logs:
   ```bash
   podman-compose logs db
   ```

3. Verify connection from Nextcloud container:
   ```bash
   podman-compose exec nextcloud ping db
   ```

### Network issues

1. List compose networks:
   ```bash
   podman network ls
   ```

2. Inspect compose network:
   ```bash
   podman network inspect private-nextcloud_default
   ```

### Reset and clean start

```bash
# Stop and remove everything
podman-compose down -v

# Remove images (optional)
podman-compose down --rmi all

# Start fresh
podman-compose up -d
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
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [podman-compose Documentation](https://github.com/containers/podman-compose)
- [Fedora Server Documentation](https://docs.fedoraproject.org/en-US/fedora-server/)

---

**Status:** 🚧 Under Development

This project is actively being developed. Check back for updates or watch the repository for notifications.
