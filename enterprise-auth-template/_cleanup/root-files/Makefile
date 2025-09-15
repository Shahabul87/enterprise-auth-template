# Enterprise Auth Template - Unified Makefile
# Manages both backend and Flutter frontend development

.PHONY: help setup dev test clean deploy

# Variables
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_DEV = $(DOCKER_COMPOSE) -f infrastructure/docker/docker-compose.yml -f infrastructure/docker/docker-compose.dev.yml
DOCKER_COMPOSE_TEST = $(DOCKER_COMPOSE) -f infrastructure/docker/docker-compose.test.yml
BACKEND_DIR = backend
FLUTTER_DIR = enterprise-auth-template/flutter_auth_template

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

# Default target
help:
	@echo "$(GREEN)Enterprise Auth Template - Available Commands$(NC)"
	@echo ""
	@echo "$(YELLOW)Development:$(NC)"
	@echo "  make setup          - Initial setup for new developers"
	@echo "  make dev            - Start full development environment"
	@echo "  make dev-backend    - Start only backend services"
	@echo "  make dev-flutter    - Start only Flutter app"
	@echo "  make stop           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make logs           - View all logs"
	@echo "  make logs-backend   - View backend logs"
	@echo ""
	@echo "$(YELLOW)Database:$(NC)"
	@echo "  make db-migrate     - Run database migrations"
	@echo "  make db-seed        - Seed development data"
	@echo "  make db-reset       - Reset database (WARNING: destroys data)"
	@echo "  make db-shell       - Open PostgreSQL shell"
	@echo ""
	@echo "$(YELLOW)Testing:$(NC)"
	@echo "  make test           - Run all tests"
	@echo "  make test-backend   - Run backend tests"
	@echo "  make test-flutter   - Run Flutter tests"
	@echo "  make test-e2e       - Run end-to-end tests"
	@echo "  make coverage       - Generate test coverage reports"
	@echo ""
	@echo "$(YELLOW)Mobile Testing:$(NC)"
	@echo "  make mobile-android - Setup Android testing"
	@echo "  make mobile-ios     - Setup iOS testing"
	@echo "  make mobile-ip      - Show machine IP for physical devices"
	@echo ""
	@echo "$(YELLOW)Code Quality:$(NC)"
	@echo "  make lint           - Run linters for both backend and frontend"
	@echo "  make format         - Auto-format code"
	@echo "  make security       - Run security checks"
	@echo ""
	@echo "$(YELLOW)Deployment:$(NC)"
	@echo "  make build          - Build production images"
	@echo "  make deploy-staging - Deploy to staging"
	@echo "  make deploy-prod    - Deploy to production"
	@echo ""
	@echo "$(YELLOW)Utilities:$(NC)"
	@echo "  make clean          - Clean all generated files and containers"
	@echo "  make shell-backend  - Open shell in backend container"
	@echo "  make shell-db       - Open database shell"
	@echo "  make urls           - Show all service URLs"

# Setup
setup:
	@echo "$(GREEN)Setting up development environment...$(NC)"
	@bash infrastructure/scripts/setup-dev.sh

# Development
dev:
	@echo "$(GREEN)Starting full development environment...$(NC)"
	@cd infrastructure/docker && $(DOCKER_COMPOSE) up -d
	@sleep 5
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) up -d
	@echo "$(GREEN)Services started! Waiting for health checks...$(NC)"
	@sleep 10
	@make urls
	@echo "$(YELLOW)Starting Flutter app...$(NC)"
	@cd $(FLUTTER_DIR) && flutter run -d chrome || echo "Run 'make dev-flutter' to start Flutter manually"

dev-backend:
	@echo "$(GREEN)Starting backend services...$(NC)"
	@cd infrastructure/docker && $(DOCKER_COMPOSE) up -d postgres redis mailhog
	@sleep 5
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) up -d backend
	@echo "$(GREEN)Backend started at http://localhost:8000$(NC)"

dev-flutter:
	@echo "$(GREEN)Starting Flutter app...$(NC)"
	@cd $(FLUTTER_DIR) && flutter pub get
	@cd $(FLUTTER_DIR) && flutter run

stop:
	@echo "$(YELLOW)Stopping all services...$(NC)"
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) down
	@cd infrastructure/docker && $(DOCKER_COMPOSE) down
	@echo "$(GREEN)All services stopped$(NC)"

restart:
	@make stop
	@make dev

logs:
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) logs -f

logs-backend:
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) logs -f backend

# Database
db-migrate:
	@echo "$(GREEN)Running database migrations...$(NC)"
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) exec backend alembic upgrade head

db-seed:
	@echo "$(GREEN)Seeding development data...$(NC)"
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) exec backend python scripts/seed_dev_data.py

db-reset:
	@echo "$(RED)WARNING: This will destroy all data!$(NC)"
	@read -p "Are you sure? (y/N) " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) down -v; \
		cd infrastructure/docker && $(DOCKER_COMPOSE) down -v; \
		echo "$(GREEN)Database reset complete$(NC)"; \
	fi

db-shell:
	@cd infrastructure/docker && $(DOCKER_COMPOSE) exec postgres psql -U dev_user -d enterprise_auth_dev

# Testing
test:
	@echo "$(GREEN)Running all tests...$(NC)"
	@bash infrastructure/scripts/test-all.sh

test-backend:
	@echo "$(GREEN)Running backend tests...$(NC)"
	@bash infrastructure/scripts/test-all.sh --backend

test-flutter:
	@echo "$(GREEN)Running Flutter tests...$(NC)"
	@cd $(FLUTTER_DIR) && flutter test

test-e2e:
	@echo "$(GREEN)Running end-to-end tests...$(NC)"
	@make dev
	@sleep 10
	@cd $(FLUTTER_DIR) && flutter drive --target=test_driver/app.dart

coverage:
	@echo "$(GREEN)Generating test coverage reports...$(NC)"
	@cd $(BACKEND_DIR) && pytest --cov=app --cov-report=html
	@cd $(FLUTTER_DIR) && flutter test --coverage
	@echo "$(GREEN)Coverage reports generated$(NC)"

# Mobile Testing
mobile-android:
	@echo "$(GREEN)Setting up Android testing...$(NC)"
	@echo "1. Starting Android emulator..."
	@flutter emulators --launch pixel_5 || echo "Please create an Android emulator first"
	@echo "2. Setting up port forwarding..."
	@adb reverse tcp:8000 tcp:8000
	@echo "$(GREEN)Android setup complete. Run 'flutter run -d android' to test$(NC)"

mobile-ios:
	@echo "$(GREEN)Setting up iOS testing...$(NC)"
	@echo "1. Opening iOS Simulator..."
	@open -a Simulator || echo "Please install Xcode and iOS Simulator"
	@echo "$(GREEN)iOS setup complete. Run 'flutter run -d ios' to test$(NC)"

mobile-ip:
	@echo "$(GREEN)Machine IP for physical device testing:$(NC)"
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		ipconfig getifaddr en0 || ipconfig getifaddr en1; \
	elif [[ "$$(uname)" == "Linux" ]]; then \
		hostname -I | awk '{print $$1}'; \
	else \
		echo "Please check your IP manually"; \
	fi
	@echo ""
	@echo "Update Flutter environment.dart with this IP"
	@echo "Ensure your device is on the same network"

# Code Quality
lint:
	@echo "$(GREEN)Running linters...$(NC)"
	@cd $(BACKEND_DIR) && python -m flake8 app/
	@cd $(BACKEND_DIR) && python -m mypy app/
	@cd $(FLUTTER_DIR) && flutter analyze

format:
	@echo "$(GREEN)Formatting code...$(NC)"
	@cd $(BACKEND_DIR) && python -m black app/ tests/
	@cd $(BACKEND_DIR) && python -m isort app/ tests/
	@cd $(FLUTTER_DIR) && dart format lib/ test/

security:
	@echo "$(GREEN)Running security checks...$(NC)"
	@cd $(BACKEND_DIR) && safety check || true
	@cd $(BACKEND_DIR) && bandit -r app/ || true
	@cd $(FLUTTER_DIR) && flutter pub audit || true

# Build & Deploy
build:
	@echo "$(GREEN)Building production images...$(NC)"
	@cd $(BACKEND_DIR) && docker build -t enterprise-auth-backend:latest .
	@cd $(FLUTTER_DIR) && flutter build web --release
	@echo "$(GREEN)Build complete$(NC)"

deploy-staging:
	@echo "$(YELLOW)Deploying to staging...$(NC)"
	@echo "Not implemented yet"

deploy-prod:
	@echo "$(RED)Deploying to production...$(NC)"
	@echo "Not implemented yet"

# Utilities
clean:
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) down -v || true
	@cd infrastructure/docker && $(DOCKER_COMPOSE) down -v || true
	@cd infrastructure/docker && $(DOCKER_COMPOSE_TEST) down -v || true
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	@cd $(FLUTTER_DIR) && flutter clean || true
	@echo "$(GREEN)Cleanup complete$(NC)"

shell-backend:
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) exec backend bash

shell-db:
	@cd infrastructure/docker && $(DOCKER_COMPOSE) exec postgres psql -U dev_user -d enterprise_auth_dev

urls:
	@echo ""
	@echo "$(GREEN)========================================$(NC)"
	@echo "$(GREEN)Service URLs:$(NC)"
	@echo "$(GREEN)========================================$(NC)"
	@echo "  • Backend API:    http://localhost:8000"
	@echo "  • API Docs:       http://localhost:8000/docs"
	@echo "  • Flutter Web:    http://localhost:3000"
	@echo "  • MailHog:        http://localhost:8025"
	@echo "  • pgAdmin:        http://localhost:5050"
	@echo "  • Redis Commander: http://localhost:8081"
	@echo "  • MinIO Console:  http://localhost:9001"
	@echo "$(GREEN)========================================$(NC)"
	@echo ""

# Quick commands
.PHONY: up down restart status

up: dev
down: stop
status:
	@cd infrastructure/docker && $(DOCKER_COMPOSE_DEV) ps
	@cd infrastructure/docker && $(DOCKER_COMPOSE) ps