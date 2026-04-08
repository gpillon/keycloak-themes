#!/usr/bin/env sh
# Build a Keycloak theme provider JAR from themes/<THEME>/ (see Keycloak theme JAR layout).
# Requires: themes/<THEME>/keycloak-themes.json (manifest) and theme files alongside it.
#
# Usage: THEME=mytheme ./scripts/build-theme-jar.sh
# Output: dist/keycloak-theme-<THEME>.jar (override with DIST_DIR=...)
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
THEME="${THEME:?THEME is required (e.g. THEME=netbird)}"
THEME_DIR="${ROOT}/themes/${THEME}"
MANIFEST="${THEME_DIR}/keycloak-themes.json"
DIST_DIR="${DIST_DIR:-${ROOT}/dist}"
OUT="${DIST_DIR}/keycloak-theme-${THEME}.jar"

if [ ! -d "$THEME_DIR" ]; then
  echo "error: theme directory not found: $THEME_DIR" >&2
  exit 1
fi
if [ ! -f "$MANIFEST" ]; then
  echo "error: missing manifest: $MANIFEST" >&2
  echo "Create keycloak-themes.json listing theme name and types (login, email, ...)." >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/META-INF" "$TMP/theme/${THEME}" "$DIST_DIR"
cp "$MANIFEST" "$TMP/META-INF/keycloak-themes.json"

# Copy theme resources; manifest lives only under META-INF in the JAR
for item in "$THEME_DIR"/*; do
  [ ! -e "$item" ] && continue
  base="$(basename "$item")"
  if [ "$base" = "keycloak-themes.json" ]; then
    continue
  fi
  cp -R "$item" "$TMP/theme/${THEME}/"
done

if command -v jar >/dev/null 2>&1; then
  ( cd "$TMP" && jar cvf "$OUT" META-INF theme )
else
  ( cd "$TMP" && zip -r "$OUT" META-INF theme )
fi
echo "Built $OUT"
