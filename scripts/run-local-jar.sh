#!/usr/bin/env sh
# Run Keycloak locally with one theme JAR in providers/ (matches typical production deploy).
#
# Usage: THEME=netbird ./scripts/run-local-jar.sh
# Admin: http://localhost:8080 — admin / admin
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
THEME="${THEME:?THEME is required (e.g. THEME=netbird)}"
JAR_NAME="keycloak-theme-${THEME}.jar"
JAR="${ROOT}/dist/${JAR_NAME}"

THEME="${THEME}" "${ROOT}/scripts/build-theme-jar.sh"

exec docker run --rm \
  --name "keycloak-theme-${THEME}-jar-dev" \
  -p 8080:8080 \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
  -e KC_HTTP_ENABLED=true \
  -v "${JAR}:/opt/keycloak/providers/${JAR_NAME}:ro" \
  quay.io/keycloak/keycloak:26.0.7 \
  start-dev \
  --spi-theme-static-max-age=-1 \
  --spi-theme-cache-themes=false \
  --spi-theme-cache-templates=false
