# Nextcloud Container

This directory contains the configuration for running Nextcloud using the LinuxServer.io Nextcloud image.

## Image Information

- **Image**: `linuxserver/nextcloud`
- **Version**: `32.0.2`
- **Registry**: Docker Hub
- **Documentation**: https://hub.docker.com/r/linuxserver/nextcloud

## Container Configuration

### Environment Variables

The LinuxServer.io Nextcloud container supports the following environment variables:

- `PUID=1000` - User ID for file permissions (should match your user ID)
- `PGID=1000` - Group ID for file permissions (should match your group ID)
- `TZ=Etc/UTC` - Timezone (e.g., `America/New_York`, `Europe/London`)

### Volume Mounts

The following volumes should be mounted for persistent data:

- **Config**: `/config` - Nextcloud configuration and database files
- **Data**: `/data` - User data files (optional, can be configured within Nextcloud)

### Port Mapping

- **HTTPS**: `443` - HTTPS web interface (internal container port)
- **HTTP**: `80` - HTTP web interface (internal container port)

## Running with Podman

### Basic Rootless Container

```bash
podman run -d \
  --name nextcloud \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e TZ=Etc/UTC \
  -p 8080:80 \
  -p 8443:443 \
  -v /var/lib/nextcloud/config:/config:Z \
  -v /var/lib/nextcloud/data:/data:Z \
  --restart=always \
  docker.io/linuxserver/nextcloud:32.0.2
```

### Systemd Integration

For systemd user service integration, a service file will be created in `systemd/nextcloud.service` in a future update.

Once available, you can enable and start with:

```bash
systemctl --user enable nextcloud.service
systemctl --user start nextcloud.service
```

## Volume Directory Setup

Before running the container, create the required directories:

```bash
sudo mkdir -p /var/lib/nextcloud/{config,data}
sudo chown -R $(id -u):$(id -g) /var/lib/nextcloud
```

### SELinux Context (Fedora)

If SELinux is enabled, set the appropriate context:

```bash
sudo chcon -R -t container_file_t /var/lib/nextcloud/
```

Or use the `:Z` flag in volume mounts (as shown above) to automatically relabel.

## Initial Setup

1. **Create volume directories** (see above)
2. **Start the container** using podman or systemd
3. **Access the web interface** at `http://localhost:8080`
4. **Complete the setup wizard**:
   - Create admin account
   - Configure data directory (use `/data` for the dedicated volume)
   - Configure database (SQLite for testing, MySQL/MariaDB or PostgreSQL for production)

## Database Configuration

For production use, it's recommended to use a separate database container:

- **MariaDB**: See `containers/database/` (to be added)
- **PostgreSQL**: See `containers/database/` (to be added)
- **Redis**: For caching, see `containers/redis/` (to be added)

## Troubleshooting

### Container Logs

View container logs:

```bash
podman logs nextcloud
```

Follow logs in real-time:

```bash
podman logs -f nextcloud
```

### Permission Issues

If you encounter permission issues, ensure:

1. The volume directories are owned by your user:
   ```bash
   ls -la /var/lib/nextcloud
   ```

2. PUID and PGID match your user ID:
   ```bash
   id -u  # Should match PUID
   id -g  # Should match PGID
   ```

3. SELinux contexts are correct (if enabled):
   ```bash
   ls -Z /var/lib/nextcloud
   ```

### Port Conflicts

If port 8080 is already in use, change the mapping:

```bash
# Use a different port, e.g., 9080
-p 9080:80
```

Check which ports are in use:

```bash
ss -tulpn | grep :8080
```

## Upgrading

To upgrade to a newer version:

1. **Pull the new image**:
   ```bash
   podman pull docker.io/linuxserver/nextcloud:latest
   ```

2. **Stop and remove the old container**:
   ```bash
   podman stop nextcloud
   podman rm nextcloud
   ```

3. **Start with the new image** (using the same configuration)

For systemd-managed containers, restart the service:

```bash
systemctl --user restart nextcloud.service
```

## Security Considerations

- **Rootless operation**: Always run as a non-root user
- **Network isolation**: Consider using Podman networks or pods
- **HTTPS**: Configure HTTPS for production deployments
- **Regular updates**: Keep the container image up to date
- **Strong passwords**: Use strong passwords for admin and database accounts
- **File permissions**: Ensure proper file permissions on volume mounts

## Resources

- [LinuxServer.io Documentation](https://docs.linuxserver.io/)
- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Podman Documentation](https://docs.podman.io/)
