#!/bin/sh

set -e

# Verify root privileges before running
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root." >&2
  exit 1
fi

echo "Stopping Kea DHCP service..."
pluginctl -s kea stop

echo "Purging active dynamic leases and temporary cache..."
rm -f /var/db/kea/kea-leases4.csv*
rm -f /var/db/kea/kea-leases6.csv*

echo "Starting Kea DHCP service..."
pluginctl -s kea start

echo "Kea dynamic lease database successfully purged."
