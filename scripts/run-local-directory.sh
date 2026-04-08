#!/usr/bin/env sh
# Run Keycloak locally mounting themes/<THEME> as a directory theme (fast iteration).
#
# Usage: THEME=netbird ./scripts/run-local-directory.sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
THEME="${THEME:?THEME is required (e.g. THEME=netbird)}"
THEME_DIR="${ROOT}/themes/${THEME}"

if [ ! -d "$THEME_DIR" ]; then
  echo "error: $THEME_DIR not found" >&2
  exit 1
fi

exec docker run --rm \
  --name "keycloak-theme-${THEME}-dev" \
  -p 8080:8080 \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
  -e KC_HTTP_ENABLED=true \
  -v "${THEME_DIR}:/opt/keycloak/themes/${THEME}:ro" \
  quay.io/keycloak/keycloak:26.0.7 \
  start-dev \
  --spi-theme-static-max-age=-1 \
  --spi-theme-cache-themes=false \
  --spi-theme-cache-templates=false
