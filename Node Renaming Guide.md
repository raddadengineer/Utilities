# Proxmox VE Standalone Node Renaming Guide & Script

A field-tested automated script and manual checklist to rename a standalone Proxmox VE (PVE) node, migrate VM/LXC configurations across `pmxcfs`, update IP mappings, and regenerate SSL certificates without orphaned cluster nodes.

---

## Prerequisites & Warnings

* **Standalone Nodes Only:** Do not use this script on an active multi-node cluster without first detaching the node. Cluster members require manual Corosync quorum and ring adjustments.
* **Stop All Guests:** Shut down all running VMs (`qm stop <vmid>`) and LXC containers (`pct stop <vmid>`) before proceeding.
* **Static IP Verification:** Ensure you know the primary IP assigned to your management interface (`vmbr0`).

---

## Automated Script: `rename-pve-node.sh`

Save the script below onto the target Proxmox host.

```bash
#!/usr/bin/env bash
# ==============================================================================
# Script: rename-pve-node.sh
# Description: Safely renames a standalone Proxmox VE host, migrates pmxcfs
#              guest configurations, updates hosts/mail configs, and fixes certs.
# ==============================================================================

set -uo pipefail

# 1. Require Root Privileges
if [[ $EUID -ne 0 ]]; then
    echo "[-] Error: This script must be run as root." >&2
    exit 1
fi

echo "=========================================="
echo "    Proxmox VE Node Rename Utility        "
echo "=========================================="

# 2. Check for Active Cluster
if [[ -f /etc/pve/corosync.conf ]]; then
    echo "[-] WARNING: /etc/pve/corosync.conf detected."
    echo "    This node belongs to a cluster. Renaming clustered nodes directly"
    echo "    breaks quorum and is not supported by this script."
    read -rp "Do you still wish to proceed at your own risk? (yes/no): " CLUSTER_FORCE
    if [[ "${CLUSTER_FORCE}" != "yes" ]]; then
        echo "[*] Aborted."
        exit 0
    fi
fi

# 3. Workload Verification (Ensure no running VMs or LXCs)
if command -v qm &>/dev/null; then
    RUNNING_VMS=$(qm list 2>/dev/null | awk '$3=="running" {print $1}' || true)
    if [[ -n "${RUNNING_VMS}" ]]; then
        echo "[-] Error: Running VMs detected (${RUNNING_VMS}). Shut down all VMs first." >&2
        exit 1
    fi
fi

if command -v pct &>/dev/null; then
    RUNNING_LXCS=$(pct list 2>/dev/null | awk '$2=="running" {print $1}' || true)
    if [[ -n "${RUNNING_LXCS}" ]]; then
        echo "[-] Error: Running containers detected (${RUNNING_LXCS}). Stop all LXC containers first." >&2
        exit 1
    fi
fi

# 4. Gather Hostnames and Management IP
OLD_NAME="$(hostname -s 2>/dev/null || hostname)"
echo "[*] Current Hostname : ${OLD_NAME}"

read -rp "Enter new short hostname (e.g., pve02): " NEW_NAME
if [[ -z "${NEW_NAME}" ]]; then
    echo "[-] Error: Hostname cannot be empty." >&2
    exit 1
fi

if [[ "${OLD_NAME}" == "${NEW_NAME}" ]]; then
    echo "[-] Error: New hostname matches current hostname." >&2
    exit 1
fi

# Validate hostname format (RFC 1123)
if ! [[ "${NEW_NAME}" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?$ ]]; then
    echo "[-] Error: Invalid hostname. Use alphanumeric characters and hyphens only." >&2
    exit 1
fi

# Identify current node IP (excluding loopback)
DETECTED_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' || true)
read -rp "Enter node primary IP [Default: ${DETECTED_IP}]: " TARGET_IP
TARGET_IP="${TARGET_IP:-${DETECTED_IP}}"

if [[ -z "${TARGET_IP}" ]]; then
    echo "[-] Error: Could not determine valid host IP." >&2
    exit 1
fi

# Detect domain search suffix if available
DOMAIN_SUFFIX=$(grep "^search " /etc/resolv.conf 2>/dev/null | awk '{print $2}' || true)
if [[ -n "${DOMAIN_SUFFIX}" ]]; then
    DEFAULT_FQDN="${NEW_NAME}.${DOMAIN_SUFFIX}"
else
    DEFAULT_FQDN="${NEW_NAME}.local"
fi
read -rp "Enter FQDN for host [Default: ${DEFAULT_FQDN}]: " TARGET_FQDN
TARGET_FQDN="${TARGET_FQDN:-${DEFAULT_FQDN}}"

TIMESTAMP=$(date +%Y%m%d%H%M%S)

# 5. Backup Critical Configs
echo "[+] Creating configuration backups in /root/pve-rename-backup-${TIMESTAMP}..."
BACKUP_DIR="/root/pve-rename-backup-${TIMESTAMP}"
mkdir -p "${BACKUP_DIR}"
cp -a /etc/hosts "${BACKUP_DIR}/hosts.bak"
cp -a /etc/hostname "${BACKUP_DIR}/hostname.bak"
[[ -f /etc/mailname ]] && cp -a /etc/mailname "${BACKUP_DIR}/mailname.bak"
[[ -f /etc/postfix/main.cf ]] && cp -a /etc/postfix/main.cf "${BACKUP_DIR}/postfix-main.cf.bak"

# 6. Update Core Host Configuration
echo "[+] Updating /etc/hostname..."
echo "${NEW_NAME}" > /etc/hostname

echo "[+] Updating /etc/hosts..."
# Remove any previous entries referencing the old name or conflicting target IP
sed -i "/\b${OLD_NAME}\b/d" /etc/hosts
sed -i "/^${TARGET_IP}\b/d" /etc/hosts
# Append clean mapping for the new node
echo "${TARGET_IP} ${TARGET_FQDN} ${NEW_NAME}" >> /etc/hosts

if [[ -f /etc/mailname ]]; then
    echo "[+] Updating /etc/mailname..."
    sed -i "s/\b${OLD_NAME}\b/${NEW_NAME}/g" /etc/mailname
fi

if [[ -f /etc/postfix/main.cf ]]; then
    echo "[+] Updating /etc/postfix/main.cf..."
    sed -i "s/\b${OLD_NAME}\b/${NEW_NAME}/g" /etc/postfix/main.cf
fi

# 7. Migrate pmxcfs Configuration Structure
# (pmxcfs disallows directory renames directly; subfolders must be created and moved)
echo "[+] Migrating Proxmox cluster file system (/etc/pve/nodes)..."
mkdir -p "/etc/pve/nodes/${NEW_NAME}"

if [[ -d "/etc/pve/nodes/${OLD_NAME}/qemu-server" ]]; then
    echo "    - Migrating QEMU VM configurations..."
    mkdir -p "/etc/pve/nodes/${NEW_NAME}/qemu-server"
    mv /etc/pve/nodes/"${OLD_NAME}"/qemu-server/* "/etc/pve/nodes/${NEW_NAME}/qemu-server/" 2>/dev/null || true
fi

if [[ -d "/etc/pve/nodes/${OLD_NAME}/lxc" ]]; then
    echo "    - Migrating LXC container configurations..."
    mkdir -p "/etc/pve/nodes/${NEW_NAME}/lxc"
    mv /etc/pve/nodes/"${OLD_NAME}"/lxc/* "/etc/pve/nodes/${NEW_NAME}/lxc/" 2>/dev/null || true
fi

# Copy any extra node configurations or certificates
if [[ -d "/etc/pve/nodes/${OLD_NAME}" ]]; then
    cp -a /etc/pve/nodes/"${OLD_NAME}"/* "/etc/pve/nodes/${NEW_NAME}/" 2>/dev/null || true
    # Remove old ghost node folder if empty
    rm -rf "/etc/pve/nodes/${OLD_NAME}" 2>/dev/null || true
fi

# 8. Migrate RRD Metrics Databases
echo "[+] Migrating RRD metric stores..."
for metric_dir in /var/lib/rrdcached/db/pve2-node /var/lib/rrdcached/db/pve2-storage; do
    if [[ -d "${metric_dir}/${OLD_NAME}" ]]; then
        mkdir -p "${metric_dir}/${NEW_NAME}"
        cp -a "${metric_dir}/${OLD_NAME}/." "${metric_dir}/${NEW_NAME}/" 2>/dev/null || true
        rm -rf "${metric_dir}/${OLD_NAME}"
    fi
done

# 9. Regenerate Certificates
echo "[+] Regenerating SSL certificates with updated SANs..."
pvecm updatecerts -f

echo ""
echo "[✓] Configuration completed successfully."
read -rp "A system reboot is required to reload all pve services. Reboot now? (y/N): " REBOOT_NOW
if [[ "${REBOOT_NOW}" =~ ^[Yy]$ ]]; then
    echo "[*] Rebooting node..."
    reboot
else
    echo "[!] Remember to execute 'reboot' before accessing the Web UI."
fi

```

---

## Step-by-Step Manual Process

If running operations manually without the script, perform the following:

### 1. Update Core Identification Files

Edit `/etc/hostname`:

```bash
nano /etc/hostname

```

Replace the content with the new node name (e.g., `node-pve01`).

Edit `/etc/hosts`:

```bash
nano /etc/hosts

```

Ensure your management IP maps to the new hostname and FQDN:

```text
127.0.0.1 localhost
<ip address> <fqdn> <hostname>

```

### 2. Migrate pmxcfs VM and Container Files

The cluster filesystem does not allow renaming existing non-empty folders. Move the configuration directories directly:

```bash
mkdir -p /etc/pve/nodes/<new-name>/qemu-server
mkdir -p /etc/pve/nodes/<new-name>/lxc

# Move VM configurations (if any)
mv /etc/pve/nodes/<old-name>/qemu-server/* /etc/pve/nodes/<new-name>/qemu-server/ 2>/dev/null || true

# Move Container configurations (if any)
mv /etc/pve/nodes/<old-name>/lxc/* /etc/pve/nodes/<new-name>/lxc/ 2>/dev/null || true

# Remove leftover old node directory to prevent ghost entries in the GUI
rm -rf /etc/pve/nodes/<old-name>

```

### 3. Migrate RRDcached Performance Metrics

Preserve graphs and historical statistics:

```bash
for dir in /var/lib/rrdcached/db/pve2-node /var/lib/rrdcached/db/pve2-storage; do
    if [ -d "$dir/<old-name>" ]; then
        mkdir -p "$dir/<new-name>"
        cp -a "$dir/<old-name>/." "$dir/<new-name>/"
        rm -rf "$dir/<old-name>"
    fi
done

```

### 4. Regenerate SSL / TLS Certificates

Regenerate `pve-ssl.pem` to include the new name and updated IP in the SAN list:

```bash
pvecm updatecerts -f

```

### 5. Reboot and Verify

Reboot the server:

```bash
reboot

```

Post-reboot verification command:

```bash
pveversion && hostname && cat /etc/hosts && ls -l /etc/pve/nodes/

```
