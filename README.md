# tayzhang-app

Personal website with content portal and app showcase.

## Overview

- **Content Portal** - Display articles, posts, videos, podcasts (Markdown-based)
- **App Showcase** - Host small applications (AI tools, note-taking apps, etc.)

## Tech Stack

| Component | Technology | Port |
|-----------|------------|------|
| Frontend | Next.js 15 (React 19) | 3000 |
| Backend | FastAPI (Python 3.12) | 8000 |
| Database | PostgreSQL 16 | 5432 |
| Proxy | nginx | 80 |

## Quick Start

```bash
# Setup environment
cp .env.example .env
# Edit .env with your values

# Start development
make dev

# Start production
docker compose up -d
```

## Project Structure

```
tayzhang-app/
├── tayzhang-webapp/       # Next.js frontend (submodule)
├── tayzhang-py-backend/   # FastAPI backend (submodule)
├── tayzhang-posts/        # Blog content (submodule)
├── nginx/                 # Reverse proxy config
├── scripts/               # Deployment & backup scripts
└── docs/                  # Documentation
```

## Endpoints

| URL | Description |
|-----|-------------|
| http://localhost:3000 | Frontend (dev) |
| http://localhost:8000/api/ | Backend API |
| http://localhost:8000/docs | Swagger UI |
| http://localhost:8000/health | Health check |

## Documentation

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture and design.

## Deploy Guide
https://help.aliyun.com/zh/ecs/user-guide/deploy-applications
