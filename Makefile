# Multi-theme Keycloak theme repository.
# Usage: make help
# Examples:
#   make THEME=netbird jar
#   make THEME=netbird deploy
#   make THEME=netbird dev-dir

THEME        ?= netbird
export THEME

ROOT         := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SCRIPTS      := $(ROOT)/scripts
DIST         := $(ROOT)/dist

.PHONY: help jar build deploy dev-jar dev-dir dev-compose clean list-themes

help:
	@echo "Keycloak themes — targets"
	@echo ""
	@echo "  make jar          Build dist/keycloak-theme-\$$(THEME).jar (default THEME=$(THEME))"
	@echo "  make deploy       Build JAR + kubectl apply ConfigMap + patch StatefulSet + restart"
	@echo "  make dev-dir      Local Keycloak, mount themes/\$$(THEME) (fast CSS/template iteration)"
	@echo "  make dev-jar      Local Keycloak, JAR in providers/ (like production)"
	@echo "  make list-themes  List themes/ (requires keycloak-themes.json per theme)"
	@echo "  make dev-compose  docker compose up (uses THEME and docker-compose.yml)"
	@echo "  make clean        Remove dist/*.jar"
	@echo ""
	@echo "Variables: THEME, KUBECONFIG, KEYCLOAK_NAMESPACE, KEYCLOAK_STATEFULSET_NAME"
	@echo "Add a theme: create themes/<name>/ with keycloak-themes.json + login/ (see themes/netbird/)."

build: jar

jar:
	@$(SCRIPTS)/build-theme-jar.sh

deploy: jar
	@$(SCRIPTS)/deploy-k8s.sh

dev-dir:
	@$(SCRIPTS)/run-local-directory.sh

dev-jar: jar
	@$(SCRIPTS)/run-local-jar.sh

dev-compose:
	@cd "$(ROOT)" && THEME="$(THEME)" docker compose up

list-themes:
	@find "$(ROOT)/themes" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r d; do \
	  n=$$(basename "$$d"); \
	  if [ -f "$$d/keycloak-themes.json" ]; then echo "$$n"; else echo "$$n (missing keycloak-themes.json)" >&2; fi; \
	done

clean:
	rm -f "$(DIST)"/keycloak-theme-*.jar
