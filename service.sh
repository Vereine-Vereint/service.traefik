#!/bin/bash
SERVICE_NAME="traefik"
SERVICE_VERSION="v2.0"

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
  
  # if CONFIG_PATH does not exists, copy default
  if [[ ! -d "$SERVICES_DIR/$CONFIG_PATH" ]]; then
    echo "Copying default configuration to $CONFIG_PATH"
    mkdir -p $SERVICES_DIR/$CONFIG_PATH
    cp $SERVICE_DIR/dashboard.example.yml $SERVICES_DIR/$CONFIG_PATH/dashboard.yml
    echo "Manually add DASHBOARD_DOMAIN and DASHBOARD_BASICAUTH_USER to $CONFIG_PATH/dashboard.yml"
    exit 1
  fi
}

# MAIN
main "$@"
