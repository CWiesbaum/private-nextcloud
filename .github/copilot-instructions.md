# Copilot Instructions for Private Nextcloud IaC

## Project Overview

This is an Infrastructure as Code (IaC) project to deploy Nextcloud on Fedora using **rootless Podman containers** managed by **systemd user services**. The project prioritizes security, maintainability, and production readiness.

## Architecture Philosophy

- **Rootless Containers**: All containers run as the user, not root, for enhanced security
- **systemd Integration**: Container lifecycle managed by systemd user services (not system services)
- **Fedora-First**: Designed specifically for Fedora Server, leveraging Podman's native integration
- **GitHub Codespaces**: Primary development environment with devcontainer for consistency

## Key Components & Structure

```
containers/          # Podman container definitions (Containerfiles, configs)
├── nextcloud/       # Main Nextcloud container
├── database/        # MariaDB/PostgreSQL container
└── redis/          # Redis cache container

systemd/            # systemd user unit files (.service files)
scripts/            # Deployment, backup, and maintenance scripts
.devcontainer/      # GitHub Codespaces development environment
```

## Development Environment Patterns

### Container Runtime
- Use `podman` commands, not `docker` (even though Docker is available for compatibility)
- Test with rootless containers: `podman run --user $(id -u):$(id -g)`
- Always use `systemctl --user` for service management (never root systemctl)

### Port Configuration
Standard ports are pre-configured in devcontainer:
- 8080: Nextcloud HTTP
- 443: Nextcloud HTTPS  
- 3306: MariaDB
- 5432: PostgreSQL
- 6379: Redis

### Volume Patterns
Follow the established volume mount structure:
- `/var/lib/nextcloud/data` - Nextcloud data
- `/var/lib/nextcloud/config` - Nextcloud configuration
- `/var/lib/nextcloud/db` - Database data

## systemd Service Conventions

When creating systemd unit files:
- Place in `systemd/` directory with `.service` extension
- Use `Type=notify` or `Type=forking` for Podman containers
- Include `Wants=` dependencies between services
- Add `Restart=always` and `RestartSec=5s` for resilience
- Use `ExecStartPre=-/usr/bin/podman stop %n` pattern for cleanup

Example service naming:
- `nextcloud.service` - Main application
- `nextcloud-db.service` - Database
- `nextcloud-redis.service` - Cache

## Container Configuration Patterns

### Podman Commands
Always use full paths and explicit options:
```bash
/usr/bin/podman run -d \
  --name nextcloud \
  --user $(id -u):$(id -g) \
  --publish 8080:80 \
  --volume /var/lib/nextcloud/data:/var/www/html/data:Z \
  docker.io/library/nextcloud:latest
```

### Security Context
- Use SELinux labels (`:Z` suffix on volume mounts)
- Always specify `--user` flag for rootless operation
- Avoid privileged containers or capabilities unless absolutely necessary

## Environment Variables

Standard environment variables (document in README):
- `NEXTCLOUD_DATA_DIR` - Data directory path
- `NEXTCLOUD_PORT` - HTTP port (default: 8080)
- `DB_TYPE` - Database type (mariadb/postgresql)
- `DB_PASSWORD` - Database password

## Script Conventions

### Deployment Scripts
- Use bash with `set -euo pipefail` for safety
- Check for required commands: `command -v podman >/dev/null`
- Validate environment before making changes
- Use `systemctl --user` consistently

### Logging & Troubleshooting
Standard diagnostic commands:
- `systemctl --user status service-name`
- `journalctl --user -u service-name -f`
- `podman logs container-name`
- `ss -tulpn | grep :port` for port checks

## File Organization

- **Configuration files**: Use YAML where possible, avoid complex templating
- **Scripts**: Single-purpose, well-documented shell scripts
- **Documentation**: Update README.md sections when adding new components
- **Secrets**: Never commit secrets; document environment variable requirements

## Testing Patterns

When implementing new components:
1. Test in devcontainer first with `podman run`
2. Verify systemd service with `systemctl --user daemon-reload && systemctl --user start`
3. Check logs immediately: `journalctl --user -u service-name --no-pager`
4. Test container restart scenarios

## Fedora-Specific Considerations

- Use `dnf` for package installation examples
- Consider SELinux contexts in documentation
- Leverage Podman's native integration (no Docker daemon needed)
- Use `firewall-cmd` examples for port configuration

## When Adding New Components

1. Create container definition in `containers/component-name/`
2. Add corresponding systemd service in `systemd/`
3. Update deployment script in `scripts/`
4. Document in README.md with troubleshooting section
5. Add any new ports to `.devcontainer/devcontainer.json`

This project is currently in development - most directories and files referenced above don't exist yet but follow this structure when implementing them.