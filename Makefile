# tayzhang-app Makefile
# Shortcuts for development, testing, and deployment

.PHONY: help dev dev-frontend dev-backend build lint test test-frontend test-backend \
        docker-up docker-down docker-logs logs docker-build docker-clean \
        db-migrate db-upgrade db-downgrade \
        install install-frontend install-backend \
        push push-all pull pull-all status deploy clean

# Default target
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Development:"
	@echo "  dev             Start all services in dev mode (docker)"
	@echo "  dev-frontend    Start frontend dev server locally"
	@echo "  dev-backend     Start backend dev server locally"
	@echo "  install         Install all dependencies"
	@echo "  install-frontend Install frontend dependencies"
	@echo "  install-backend  Install backend dependencies"
	@echo ""
	@echo "Build & Lint:"
	@echo "  build           Build all services"
	@echo "  lint            Run linters on all sub-repos"
	@echo "  lint-frontend   Run ESLint on frontend"
	@echo "  lint-backend    Run linters on backend"
	@echo ""
	@echo "Testing:"
	@echo "  test            Run all tests"
	@echo "  test-frontend   Run frontend tests"
	@echo "  test-backend    Run backend tests"
	@echo ""
	@echo "Docker:"
	@echo "  docker-up       Start all services with docker"
	@echo "  docker-down     Stop all services"
	@echo "  docker-logs     Tail docker logs"
	@echo "  logs            Alias for docker-logs"
	@echo "  docker-build    Build docker images"
	@echo "  docker-clean    Remove containers and volumes"
	@echo ""
	@echo "Database:"
	@echo "  db-migrate      Create a new migration (use MSG=description)"
	@echo "  db-upgrade      Run all pending migrations"
	@echo "  db-downgrade    Rollback last migration"
	@echo ""
	@echo "Git:"
	@echo "  status          Show git status of all repos"
	@echo "  push            Push root repo only"
	@echo "  push-all        Push all repos (root + submodules)"
	@echo "  pull            Pull root repo only"
	@echo "  pull-all        Pull all repos (root + submodules)"
	@echo ""
	@echo "Other:"
	@echo "  deploy          Deploy to production"
	@echo "  clean           Clean build artifacts"

# ============================================================================
# Development
# ============================================================================

dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up

dev-frontend:
	cd tayzhang-webapp && npm run dev

dev-backend:
	cd tayzhang-py-backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

install: install-frontend install-backend

install-frontend:
	cd tayzhang-webapp && npm install

install-backend:
	cd tayzhang-py-backend && pip install -e ".[dev]"

# ============================================================================
# Build & Lint
# ============================================================================

build:
	cd tayzhang-webapp && npm run build

lint: lint-frontend lint-backend

lint-frontend:
	cd tayzhang-webapp && npm run lint

lint-backend:
	@cd tayzhang-py-backend && \
	if command -v ruff >/dev/null 2>&1; then \
		ruff check app/; \
	else \
		echo "Warning: ruff not installed, running basic syntax check only"; \
		python -m py_compile app/main.py && echo "Backend syntax check passed"; \
	fi

# ============================================================================
# Testing
# ============================================================================

test: test-frontend test-backend

test-frontend:
	@cd tayzhang-webapp && if [ -f "package.json" ] && grep -q '"test"' package.json; then npm test; else echo "No tests configured for frontend yet"; fi

test-backend:
	cd tayzhang-py-backend && pytest

# ============================================================================
# Docker
# ============================================================================

docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f

logs: docker-logs

docker-build:
	docker compose build

docker-clean:
	docker compose down -v --rmi local

# ============================================================================
# Database
# ============================================================================

db-migrate:
ifndef MSG
	$(error MSG is required. Usage: make db-migrate MSG="migration description")
endif
	docker compose exec backend alembic revision --autogenerate -m "$(MSG)"

db-upgrade:
	docker compose exec backend alembic upgrade head

db-downgrade:
	docker compose exec backend alembic downgrade -1

# ============================================================================
# Git
# ============================================================================

# Push only root repo
push:
	git push

# Push all repos (root + submodules)
push-all:
	@echo "Pushing tayzhang-webapp..."
	cd tayzhang-webapp && git push || true
	@echo "Pushing tayzhang-py-backend..."
	cd tayzhang-py-backend && git push || true
	@echo "Pushing tayzhang-posts..."
	cd tayzhang-posts && git push || true
	@echo "Pushing root repo..."
	git push

# Pull only root repo
pull:
	git pull

# Pull all repos (root + submodules)
pull-all:
	@echo "Pulling tayzhang-webapp..."
	cd tayzhang-webapp && git pull || true
	@echo "Pulling tayzhang-py-backend..."
	cd tayzhang-py-backend && git pull || true
	@echo "Pulling tayzhang-posts..."
	cd tayzhang-posts && git pull || true
	@echo "Pulling root repo..."
	git pull

# Show status of all repos
status:
	@echo "=== Root repo ==="
	@git status -s
	@echo ""
	@echo "=== tayzhang-webapp ==="
	@cd tayzhang-webapp && git status -s
	@echo ""
	@echo "=== tayzhang-py-backend ==="
	@cd tayzhang-py-backend && git status -s
	@echo ""
	@echo "=== tayzhang-posts ==="
	@cd tayzhang-posts && git status -s

# ============================================================================
# Deployment & Cleanup
# ============================================================================

deploy:
	./scripts/deploy.sh

clean:
	rm -rf tayzhang-webapp/.next
	rm -rf tayzhang-webapp/node_modules/.cache
	rm -rf tayzhang-py-backend/__pycache__
	rm -rf tayzhang-py-backend/.pytest_cache
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
