#!/bin/bash
SERVICE_NAME="traefik"
SERVICE_VERSION="v4.0"

set -e

SERVICE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "[$SERVICE_NAME] $SERVICE_VERSION ($(git rev-parse --short HEAD))"
cd $SERVICE_DIR

# CORE
source ./core/core.sh

# ATTACHMENTS
att_setup() {
  docker network create traefik &>/dev/null || true

  if [[ ! -d "$SERVICES_DIR/$CONFIG_PATH" ]]; then
    read -p "Enter 'DASHBOARD_DOMAIN': " DASHBOARD_DOMAIN

    mkdir -p $SERVICES_DIR/$CONFIG_PATH
    # cp $SERVICE_DIR/dashboard.example.yml $SERVICES_DIR/$CONFIG_PATH/dashboard.yml
    # sed -i "s/\`\${DASHBOARD_DOMAIN}\`/$DASHBOARD_DOMAIN/g" $SERVICES_DIR/$CONFIG_PATH/dashboard.yml
    generate $SERVICE_DIR/dashboard.example.yml $SERVICES_DIR/$CONFIG_PATH/dashboard.yml
  fi
}

att_configure() {
  # assert challenge type dns-hetzner
  if [[ "$CHALLENGE_TYPE" == "dns-hetzner" ]]; then
    # HETZNER_DNS_API_TOKEN, TLS_DOMAIN_MAIN, TLS_DOMAIN_SANS must be set
    if [[ -z "$HETZNER_DNS_API_TOKEN" || -z "$TLS_DOMAIN_MAIN" || -z "$TLS_DOMAIN_SANS" ]]; then
      echo "HETZNER_DNS_API_TOKEN, TLS_DOMAIN_MAIN, TLS_DOMAIN_SANS must be set"
      exit 1
    fi
  else
    set -o allexport
    HETZNER_DNS_API_TOKEN="none" # supress warning
    set +o allexport	
  fi

  template="$SERVICE_DIR/templates/traefik-$CHALLENGE_TYPE.yml"
  if [[ ! -f "$template" ]]; then
    echo "CHALLENGE_TYPE not valid"
    exit 1
  fi

  generate $SERVICE_DIR/templates/docker-compose.yml $SERVICE_DIR/docker-compose.yml
  generate $template $SERVICE_DIR/generated/traefik.yml
}

# MAIN
main "$@"
