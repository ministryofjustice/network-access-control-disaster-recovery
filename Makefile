.DEFAULT_GOAL := help

.PHONY: restore-config
restore-config: ## Run script to restore nca config
	./scripts/restore-config.sh

.PHONY: restore-service-container
restore-service-container: ## Run script to restore nac service container
	./scripts/restore-service-container.sh

.PHONY: restore-admin-container
restore-admin-container: ## Run script to restore nac admin container
	./scripts/restore-admin-container.sh

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
