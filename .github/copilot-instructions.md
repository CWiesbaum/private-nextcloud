# Copilot Instructions for Private Nextcloud IaC

## Project Overview

This is an Infrastructure as Code (IaC) project to deploy Nextcloud on Fedora using **Docker Compose** to orchestrate a complete container stack. The project prioritizes security, maintainability, and production readiness.

## Architecture Philosophy

- **Docker Compose Orchestration**: Complete stack defined in docker-compose.yml for easy deployment and management
- **Rootless Containers**: All containers run as the user, not root, for enhanced security
- **Fedora-First**: Designed specifically for Fedora Server, leveraging Podman's Docker Compose compatibility
- **GitHub Codespaces**: Primary development environment with devcontainer for consistency

## Key Components & Structure

```
compose/                    # Docker Compose stack definitions
├── docker-compose.yml     # Main compose file for complete stack
├── docker-compose.prod.yml # Production overrides
└── .env.example           # Environment variables template

config/                     # Service-specific configuration files
├── nextcloud/             # Nextcloud configuration
├── database/              # Database initialization scripts
└── redis/                 # Redis configuration

scripts/                    # Deployment, backup, and maintenance scripts
.devcontainer/             # GitHub Codespaces development environment
```

## Development Environment Patterns

### Container Runtime
- Use `podman-compose` or `docker-compose` commands for stack management
- Podman provides Docker Compose compatibility via podman-compose
- Test the complete stack with: `podman-compose up -d`
- Individual service operations: `podman-compose restart nextcloud`

### Port Configuration
Standard ports are pre-configured in devcontainer and docker-compose.yml:
- 8080: Nextcloud HTTP
- 443: Nextcloud HTTPS  
- 3306: MariaDB
- 5432: PostgreSQL
- 6379: Redis

### Volume Patterns
Define named volumes in docker-compose.yml:
- `nextcloud_data` - Nextcloud data
- `nextcloud_config` - Nextcloud configuration
- `db_data` - Database data
- `redis_data` - Redis persistence (optional)

## Docker Compose Conventions

When creating docker-compose.yml:
- Use compose file version 3.8 or higher
- Define all services in a single `docker-compose.yml`
- Use production overrides in `docker-compose.prod.yml`
- Leverage named volumes for persistence
- Use depends_on for service dependencies
- Define health checks for critical services
- Use environment variables from `.env` file

Example service structure:
```yaml
services:
  nextcloud:
    image: nextcloud:latest
    depends_on:
      - db
      - redis
    environment:
      - MYSQL_HOST=db
      - REDIS_HOST=redis
    volumes:
      - nextcloud_data:/var/www/html/data
      - nextcloud_config:/var/www/html/config
    ports:
      - "8080:80"
    restart: unless-stopped

  db:
    image: mariadb:latest
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - MYSQL_DATABASE=nextcloud
    volumes:
      - db_data:/var/lib/mysql
    restart: unless-stopped

  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  nextcloud_data:
  nextcloud_config:
  db_data:
  redis_data:
```

## Container Configuration Patterns

### Compose Service Definitions
Always use descriptive service names and proper dependencies:
```yaml
services:
  nextcloud:
    container_name: nextcloud
    image: nextcloud:latest
    user: "${UID:-1000}:${GID:-1000}"  # Rootless operation with defaults
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
```

### Security Context
- Use user mapping for rootless operation in docker-compose YAML: `user: "${UID:-1000}:${GID:-1000}"`
- For bind mounts (not named volumes), use SELinux labels on Fedora:
  - Named volumes (recommended, no label needed): `nextcloud_data:/var/www/html/data`
  - Private bind mounts: `/host/path:/container/path:Z` (uppercase Z for private labeling)
  - Shared bind mounts: `/host/path:/container/path:z` (lowercase z for multi-container sharing)
- Avoid privileged mode unless absolutely necessary
- Use read-only root filesystem where possible: `read_only: true`

## Environment Variables

Standard environment variables (document in README):
- `NEXTCLOUD_PORT` - HTTP port (default: 8080)
- `DB_TYPE` - Database type (mariadb/postgresql)
- `DB_ROOT_PASSWORD` - Database root password
- `DB_PASSWORD` - Nextcloud database password
- `DB_NAME` - Database name (default: nextcloud)
- `REDIS_PASSWORD` - Redis password (optional)
- `UID` - User ID for rootless operation (default: 1000)
- `GID` - Group ID for rootless operation (default: 1000)

## Script Conventions

### Deployment Scripts
- Use bash with `set -euo pipefail` for safety
- Check for required commands: `command -v podman-compose >/dev/null`
- Validate environment variables from `.env` file before deployment
- Use `podman-compose` consistently (or `docker-compose` as fallback)

### Stack Management Commands
Standard compose operations:
- `podman-compose up -d` - Start the stack
- `podman-compose down` - Stop and remove containers
- `podman-compose logs -f service-name` - View service logs
- `podman-compose restart service-name` - Restart a service
- `podman-compose ps` - List running services

## File Organization

- **Compose files**: Main `docker-compose.yml` in `compose/` directory
- **Configuration files**: Service-specific configs in `config/` directory
- **Environment files**: `.env.example` as template, `.env` for actual values (gitignored)
- **Scripts**: Single-purpose, well-documented shell scripts in `scripts/` directory
- **Documentation**: Update README.md sections when adding new components
- **Secrets**: Use `.env` file for secrets (never commit), provide `.env.example` template

## Testing Patterns

When implementing new components:
1. Test in devcontainer first with `podman-compose up`
2. Verify service health with `podman-compose ps` and `podman-compose logs`
3. Test service dependencies and startup order
4. Validate volume persistence by recreating containers
5. Test with production overrides: `podman-compose -f docker-compose.yml -f docker-compose.prod.yml up`

## Fedora-Specific Considerations

- Use `dnf` for package installation examples
- Consider SELinux contexts in documentation
- Leverage Podman's native integration (no Docker daemon needed)
- Use `firewall-cmd` examples for port configuration

## When Adding New Components

1. Add service definition to `compose/docker-compose.yml`
2. Create service-specific configuration in `config/component-name/`
3. Update `.env.example` with new environment variables
4. Update deployment script in `scripts/` if needed
5. Document in README.md with configuration and troubleshooting sections
6. Add any new ports to `.devcontainer/devcontainer.json`

This project is currently in development - most directories and files referenced above don't exist yet but follow this structure when implementing them.