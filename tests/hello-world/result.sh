#!/usr/bin/env bash
# generated with nix-provisioner-script
set -o errexit
set -o nounset
set -o pipefail

echo "---"
echo "Starting provisioning process..."
echo "---"

(
  echo "Preparing provisioning state directory..."
  sudo mkdir -p /var/lib/nix-provisioner-script
)

echo "---"
echo "Provisioning script complete!"
echo "---"
