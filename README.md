# Flamingo

Helm chart that deploys **FleetDM** with **MySQL** and **Redis** as bundled
dependencies (`charts/fleet`). The chart is published to GHCR as an OCI package
at `oci://ghcr.io/redbearddog/fleet`

The local environment runs on [Kind](https://kind.sigs.k8s.io/). The FleetDM
service is exposed on nodePort `30080`, mapped to `localhost:8080` by
`kind-config.yaml`

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) 3.8+

## Install

```bash
make cluster   # create the local Kind cluster
make install   # install the chart from ./charts/fleet
```

To install the chart from repo/local folder:

```bash
make install
```

To install the published chart from GHCR:

```bash
make install_oci
```

Fleet DM should be reachable at <http://localhost:8080>

## Teardown

```bash
make uninstall   # remove all resources of the Helm release
make destroy     # delete the Kind cluster
```

## Verification

Confirm every pod is `Running` and `Ready`:

```bash
kubectl get pods
```

You should see a FleetDM pod plus MySQL and Redis pods (named after the
`fleet` release)

### Fleet DM

```bash
kubectl rollout status deploy/fleet
curl -fsS http://localhost:8080/healthz && echo OK
```

`make install` waits for the release to be ready (`--wait`), so a successful
`/healthz` confirms FleetDM started and connected to its datastore

### MySQL

```bash
MYSQL=$(kubectl get pod -l app.kubernetes.io/name=mysql -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$MYSQL" -- mysqladmin ping
# -> mysqld is alive
```

### Redis

```bash
REDIS=$(kubectl get pod -l app.kubernetes.io/name=redis -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$REDIS" -- redis-cli ping
# -> PONG
```

If the label selectors return nothing, list pods with `kubectl get pods` and
use the exact pod names

## Releasing a new chart version

Chart releases are produced by the **Release chart** GitHub Action
(`.github/workflows/release.yml`). A new release always bumps the chart version
first, then packages and pushes to GHCR

1. Open the **Actions** tab → **Release chart** → **Run workflow**.
2. Pick the bump level: `bugfix`, `minor`, or `major`

The workflow bumps `version:` in `charts/fleet/Chart.yaml`, commits the change,
packages the chart with the new `--version` / `--app-version`, and pushes it to
`oci://ghcr.io/redbearddog`

> First release only: the GHCR package is created as **private**. Make it public
> under GitHub → Packages → `fleet` → Package settings so `make install_oci`
> can pull it anonymously
