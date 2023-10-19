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
  sudo mkdir -p "/var/lib/nix-provisioner-script"
  sudo mkdir -p "/var/lib/nix-provisioner-script/generations"

  echo "Finding the latest generation..."
  latestGeneration="$(ls -1 "/var/lib/nix-provisioner-script/generations" | sort -n | tail -n 1)"

  currentGeneration=$((latestGeneration + 1))

  echo "Current generation: #$currentGeneration"
)

echo "---"
echo "Provisioning script complete!"
echo "---"
