#!/bin/bash
SERVICE_NAME="traefik"
SERVICE_VERSION="v1.1"

set -e

SERVICE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "[$SERVICE_NAME] $SERVICE_VERSION ($(git rev-parse --short HEAD))"
cd $SERVICE_DIR

# CORE
source ./core/core.sh
source ./borg/borg.sh

# ATTACHMENTS
att_setup() {
  docker network create traefik &>/dev/null || true
}

# MAIN
main "$@"
