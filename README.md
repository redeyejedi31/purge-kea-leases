# OPNsense Kea DHCP Dynamic Lease Purge Utility

A lightweight POSIX shell utility designed for OPNsense firewalls running the ISC Kea DHCP server.

Kea does not provide a native bulk purge or reset option inside the OPNsense web GUI. This script safely stops the Kea daemon, clears out the active CSV lease databases along with rotated backup files, and restarts the service cleanly with an empty lease table.

All static reservations remain untouched because they reside independently within the main OPNsense system configuration (`/conf/config.xml`).

---

## Key Features

* **Safe Execution:** Confirms root privileges before attempting service control.
* **Clean State Reset:** Stops the Kea daemon prior to removing lease files, preventing in memory lease tables from flushing stale entries back to disk during shutdown.
* **Dual Stack Coverage:** Automatically purges both IPv4 and IPv6 dynamic lease CSV stores along with rotated archive files.
* **Preserves Static Mappings:** Completely leaves static host reservations and fixed IP mappings intact.

---

## Quick Installation

Run the following block directly in the OPNsense shell (via SSH or console) to deploy the utility into `/usr/local/bin/purge-kea-leases.sh`:

```sh
cat << 'EOF' > /usr/local/bin/purge-kea-leases.sh
#!/bin/sh

set -e

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
EOF
chmod +x /usr/local/bin/purge-kea-leases.sh
```

---

## Usage

Once installed, execute the command at any time as root:

```sh
purge-kea-leases.sh
```

### Manual One Liner

If you prefer to run the command directly without creating a permanent script file on your filesystem:

```sh
sh -c 'pluginctl -s kea stop && rm -f /var/db/kea/kea-leases4.csv* /var/db/kea/kea-leases6.csv* && pluginctl -s kea start'
```

---

## Why This Is Needed

When restructuring dynamic IP pools or forcing roaming clients to drop cached IP addresses, Kea may continue to grant existing addresses if clients reconnect in an `INIT-REBOOT` state. Purging the lease store alongside client disassociation forces Kea to evaluate all incoming connections against updated pool boundaries and enforce immediate reallocation.

---

## Compatibility

* **OPNsense:** 24.x or later
* **DHCP Engine:** ISC Kea DHCPv4 / DHCPv6
* **Shell:** FreeBSD Almquist shell (`/bin/sh`)
