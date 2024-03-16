#!/bin/bash
SERVICE_NAME="traefik"
SERVICE_VERSION="v0.1"

set -e

SERVICE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "[$SERVICE_NAME] $SERVICE_VERSION ($(git rev-parse --short HEAD))"
cd $SERVICE_DIR

# CORE
source ./core/core.sh
source ./borg/borg.sh

# COMMANDS
commands+=([init]=":Creates the traefik docker network and configurations")
cmd_init() {
  createNetwork
  echo "Network traefik created"
  updateTemplates
  echo "Traefik configured"
}

# ATTACHMENTS
att_preStart() {
  createNetwork
}

att_configure() {
  updateTemplates
}

# FUNCTIONS
createNetwork() {
  docker network create traefik >/dev/null 2>&1 || true
}

updateTemplates() {
  generate "traefik.yml"
  generate "conf/dashboard.yml"
}

main "$@"
