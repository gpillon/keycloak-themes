# Keycloak themes

This repository holds **custom Keycloak themes** (login, email, and related resources) packaged as directory trees and as **provider JARs** for production-style deployments.

The project is **just getting started**: layouts, tooling, and themes will evolve. If you use Keycloak and want to contribute fixes or new themes, **pull requests are welcome**—they help shape how this repo grows.

## What you get

- **`themes/<name>/`** — One folder per theme, with a `keycloak-themes.json` manifest and standard Keycloak theme layout (`login/`, `email/`, …).
- **Build** — Scripts produce `dist/keycloak-theme-<name>.jar` for mounting under `/opt/keycloak/providers/` (same idea as many Helm/Kubernetes setups).
- **Local development** — Docker-based Keycloak with theme caching disabled so you can iterate on CSS and templates quickly.
- **Kubernetes (optional)** — A helper script builds the JAR and applies it as a ConfigMap; see `deploy/k8s/` for Helm values examples.

## Prerequisites

- **Docker** — For local Keycloak (required for `make dev-*` and `make dev-compose`).
- **`jar` or `zip`** — To build JARs (`make jar`). The build script uses `jar` if available, otherwise `zip`.
- **`kubectl`** and a cluster — Only if you use `make deploy` or the deploy script.

## Quick start

Show all Make targets:

```bash
make help
```

Default theme name is `netbird` (override with `THEME=...`).

### Build a theme JAR

```bash
make jar
# or
make THEME=magesgate jar
```

Output: `dist/keycloak-theme-<THEME>.jar`.

### Local development (fast iteration — mounted directory)

Edits under `themes/<THEME>/` show up without rebuilding a JAR:

```bash
make dev-dir
# or
make THEME=magesgate dev-dir
```

Keycloak admin UI: **http://localhost:8080** (default bootstrap user/password are set in the scripts — see `scripts/run-local-directory.sh`).

### Local development (JAR in `providers/`, closer to production)

```bash
make dev-jar
```

### Docker Compose

You can copy `.env.example` to `.env` and set `THEME`, or pass the variable inline:

```bash
make dev-compose
# or: THEME=magesgate make dev-compose
```

### List theme directories

```bash
make list-themes
```

Themes should include `keycloak-themes.json`; the target warns if it is missing.

### Deploy to Kubernetes

Builds the JAR and creates/updates a ConfigMap in your cluster (namespace defaults to `keycloak`):

```bash
export KUBECONFIG=/path/to/kubeconfig   # if needed
make deploy
# or: THEME=magesgate make deploy
```

Environment variables you may set: `KEYCLOAK_NAMESPACE`, `THEME_CONFIGMAP_NAME`. After apply, wire the ConfigMap into your Helm values using the pattern in `deploy/k8s/helm-values-theme.yaml.example`.

### Clean build artifacts

```bash
make clean
```

## Adding a new theme

1. Create `themes/<your-theme-id>/`.
2. Add **`keycloak-themes.json`** (manifest listing theme name and types — copy from `themes/netbird/` as a template).
3. Add **`login/`**, **`email/`**, or other theme types as needed (see Keycloak theme documentation for structure).
4. Run `make THEME=<your-theme-id> jar` or `make THEME=<your-theme-id> dev-dir` to verify.

## Repository layout

| Path | Purpose |
|------|---------|
| `themes/` | One subdirectory per theme |
| `scripts/` | Build, local run, and K8s deploy scripts |
| `dist/` | Generated JARs (gitignored) |
| `deploy/k8s/` | Example Helm fragments and related Kubernetes notes |

## License

See `LICENSE` in the repository root.
