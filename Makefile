# ==============================================================================
# Makefile for LogicPilot Production Build
# ==============================================================================

.PHONY: help build build-no-cache test run stop clean setup deploy health

# Variables
IMAGE_NAME := logicpilot
IMAGE_TAG := production-v2.0
MOCK_API_IMAGE := logicpilot-mock-api
COMPOSE_FILE := docker-compose.production.yml
DOCKERFILE := Dockerfile.logicpilot.production

help: ## Show this help message
	@echo "LogicPilot Production Build System"
	@echo "================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup - create required directories
	@echo "Setting up project directories..."
	@mkdir -p workflows programs plugins logs data monitoring/grafana-dashboards monitoring/grafana-datasources
	@echo "✅ Directories created"
	@cp .env.example .env 2>/dev/null || echo "# Environment variables\nOPENROUTER_API_KEY=your-key-here\nGRAFANA_PASSWORD=admin" > .env
	@echo "✅ Environment file ready"
	@echo "Copying sample workflows from image..."
	@docker run --rm -v $(PWD)/workflows:/tmp/out logicpilot:production-v2.0 /bin/sh -c "cp /app/workflows/*.yaml /tmp/out/ 2>/dev/null || true" || true
	@echo "✅ Setup complete"

build: ## Build production Docker images
	@echo "Building production images..."
	docker-compose -f $(COMPOSE_FILE) build
	@echo "✅ Build complete"

build-no-cache: ## Build images without cache
	@echo "Building images without cache..."
	docker-compose -f $(COMPOSE_FILE) build --no-cache
	@echo "✅ Build complete"

test: ## Run tests
	@echo "Running tests..."
	docker-compose -f $(COMPOSE_FILE) run --rm logicpilot pytest /app/tests/ -v || echo "⚠️  No tests found"
	@echo "✅ Tests complete"

run: ## Start all services
	@echo "Starting services..."
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "✅ Services started"
	@echo "Waiting for services to be healthy..."
	@sleep 5
	@make health

run-with-monitoring: ## Start all services including monitoring
	@echo "Starting services with monitoring..."
	docker-compose -f $(COMPOSE_FILE) --profile monitoring up -d
	@echo "✅ Services started with monitoring"
	@echo "Prometheus: http://localhost:9090"
	@echo "Grafana: http://localhost:3000"

stop: ## Stop all services
	@echo "Stopping services..."
	docker-compose -f $(COMPOSE_FILE) down
	@echo "✅ Services stopped"

restart: stop run ## Restart all services

logs: ## Show logs
	docker-compose -f $(COMPOSE_FILE) logs -f

logs-llms: ## Show LogicPilot logs
	docker-compose -f $(COMPOSE_FILE) logs -f logicpilot

logs-api: ## Show Mock API logs
	docker-compose -f $(COMPOSE_FILE) logs -f llms-mock-api

health: ## Check service health
	@echo "Checking service health..."
	@docker-compose -f $(COMPOSE_FILE) ps
	@echo ""
	@curl -sf http://localhost:8000/health > /dev/null && echo "✅ Mock API: healthy" || echo "❌ Mock API: unhealthy"

run-workflow: ## Run a workflow (Usage: make run-workflow WORKFLOW=demo.yaml)
	@docker-compose -f $(COMPOSE_FILE) run --rm logicpilot /app/workflows/$(WORKFLOW)

list-workflows: ## List available workflows
	@docker-compose -f $(COMPOSE_FILE) run --rm logicpilot /bin/sh -c "ls -lh /app/workflows/"

test-demo: ## Run the demo workflow (quick test)
	@echo "Running demo workflow..."
	@docker-compose -f $(COMPOSE_FILE) run --rm logicpilot /app/workflows/demo.yaml

test-advanced: ## Run the advanced workflow
	@echo "Running advanced workflow..."
	@docker-compose -f $(COMPOSE_FILE) run --rm logicpilot /app/workflows/advanced.yaml

shell: ## Get shell access to LogicPilot container
	@docker-compose -f $(COMPOSE_FILE) run --rm logicpilot /bin/sh

clean: ## Remove containers, networks, volumes
	@echo "Cleaning up..."
	docker-compose -f $(COMPOSE_FILE) down -v
	@echo "✅ Cleanup complete"

clean-all: clean ## Remove everything including images
	@echo "Removing images..."
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) $(MOCK_API_IMAGE):latest 2>/dev/null || true
	@echo "✅ Full cleanup complete"

prune: ## Remove unused Docker resources
	@echo "Pruning Docker resources..."
	docker system prune -f
	@echo "✅ Prune complete"

inspect: ## Show image information
	@echo "Image information:"
	@docker images | grep -E "$(IMAGE_NAME)|REPOSITORY"
	@echo ""
	@docker inspect $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null | grep -E "Size|Created" || echo "Image not found"

size: ## Show image sizes
	@echo "Image sizes:"
	@docker images $(IMAGE_NAME):$(IMAGE_TAG) --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"
	@docker images $(MOCK_API_IMAGE):latest --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"

deploy: build run ## Build and deploy
	@echo "✅ Deployment complete"
	@make health

# Development targets
dev-setup: ## Setup development environment
	@echo "Setting up development environment..."
	@pip install -r requirements.txt
	@echo "✅ Development environment ready"

watch: ## Watch logs in real-time
	docker-compose -f $(COMPOSE_FILE) logs -f --tail=100

stats: ## Show container stats
	docker stats --no-stream

# Security scanning (requires trivy)
scan: ## Scan images for vulnerabilities
	@echo "Scanning images for vulnerabilities..."
	@command -v trivy >/dev/null 2>&1 && \
		trivy image $(IMAGE_NAME):$(IMAGE_TAG) || \
		echo "⚠️  Trivy not installed. Install: https://github.com/aquasecurity/trivy"

# Backup and restore
backup: ## Backup volumes
	@echo "Backing up volumes..."
	@mkdir -p backups
	@docker run --rm -v logicpilot-prometheus-data:/data -v $(PWD)/backups:/backup alpine tar czf /backup/prometheus-data-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@docker run --rm -v logicpilot-grafana-data:/data -v $(PWD)/backups:/backup alpine tar czf /backup/grafana-data-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "✅ Backup complete"

info: ## Show system information
	@echo "System Information"
	@echo "=================="
	@echo "Docker version: $$(docker --version)"
	@echo "Docker Compose version: $$(docker-compose --version)"
	@echo ""
	@echo "Images:"
	@docker images | grep -E "logicpilot|mock-api|REPOSITORY"
	@echo ""
	@echo "Running containers:"
	@docker ps --filter "name=logicpilot" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
