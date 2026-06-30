VERSION ?= $(shell awk '/^version:/ {print $$2}' charts/fleet/Chart.yaml)
CLUSTER ?= flamingo
RELEASE ?= fleet

.PHONY: cluster install install_oci uninstall destroy

# create local Kind cluster
cluster:
	kind create cluster --name $(CLUSTER) --config kind-config.yaml

# install Helm chart from GHCR
install_oci:
	helm upgrade --install $(RELEASE) oci://ghcr.io/redbearddog/fleet --version $(VERSION) --wait

# install Helm chart from local folder
install:
	helm upgrade --install $(RELEASE) charts/fleet --wait

# remove all deployed resources
uninstall:
	helm uninstall $(RELEASE)

# delete local Kind cluster
destroy:
	kind delete cluster --name $(CLUSTER)
