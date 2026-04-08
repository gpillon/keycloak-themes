#!/usr/bin/env sh
# Deploy one theme JAR to Kubernetes as a ConfigMap for GitOps/Helm consumption.
#
# Usage: export KUBECONFIG=/path/to/kubeconfig
#        THEME=netbird ./scripts/deploy-k8s.sh
#
# Env: KEYCLOAK_NAMESPACE (default keycloak), THEME_CONFIGMAP_NAME (default keycloak-theme-<THEME>)
#
# CloudPirates/upstream Keycloak mount path:
#   /opt/keycloak/providers/keycloak-theme-<THEME>.jar
#
# ArgoCD/Helm: encode the matching extraVolumes/extraVolumeMounts in values; see deploy/k8s/
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
THEME="${THEME:?THEME is required (e.g. THEME=netbird)}"
NS="${KEYCLOAK_NAMESPACE:-keycloak}"
JAR_NAME="keycloak-theme-${THEME}.jar"
CM="${THEME_CONFIGMAP_NAME:-keycloak-theme-${THEME}}"
JAR="${ROOT}/dist/${JAR_NAME}"

THEME="${THEME}" "${ROOT}/scripts/build-theme-jar.sh"

echo "ConfigMap ${CM} in namespace ${NS}..."
kubectl create configmap "${CM}" \
  --from-file="${JAR_NAME}=${JAR}" \
  -n "${NS}" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "ConfigMap updated. Reference it from your Helm/Argo values with:"
echo "  preserveThemes: true"
echo "  preserveProviders: true"
echo "  extraVolumes:"
echo "    - name: keycloak-theme-${THEME}-jar"
echo "      configMap:"
echo "        name: ${CM}"
echo "  extraVolumeMounts:"
echo "    - name: keycloak-theme-${THEME}-jar"
echo "      mountPath: /opt/keycloak/providers/${JAR_NAME}"
echo "      subPath: ${JAR_NAME}"
