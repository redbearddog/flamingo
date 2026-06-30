CLUSTER     ?= fleet
NAMESPACE   ?= fleet
RELEASE     ?= fleet
CHART       ?= .
KIND_CONFIG ?= kind-config.yaml
REGISTRY    ?= ghcr.io/redbearddog/charts

.PHONY: cluster install uninstall dep template cluster-delete package publish

cluster:
	kind create cluster --name $(CLUSTER) --config $(KIND_CONFIG)

dep:
	helm dependency update $(CHART)

install: dep
	helm upgrade --install $(RELEASE) $(CHART) --namespace $(NAMESPACE) --create-namespace
	@echo "Fleet UI: http://localhost:8080"

uninstall:
	-helm uninstall $(RELEASE) --namespace $(NAMESPACE)
	-kubectl delete namespace $(NAMESPACE) --ignore-not-found

template: dep
	helm template $(RELEASE) $(CHART) --namespace $(NAMESPACE) --debug

cluster-delete:
	kind delete cluster --name $(CLUSTER)

package: dep
	helm package $(CHART) -d dist

publish: package
	helm push dist/fleet-*.tgz oci://$(REGISTRY)
