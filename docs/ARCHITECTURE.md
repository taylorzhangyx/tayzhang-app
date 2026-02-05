# Architecture Documentation

## Overview

tayzhang-app is a personal website with two main purposes:
1. **Content Portal** - Display articles, posts, videos, podcasts (Markdown-based)
2. **App Showcase** - Host small applications (AI tools, note-taking apps, etc.)

## Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Frontend | Next.js 15 (React 19) | Server-side rendering, App Router |
| Backend API | FastAPI (Python 3.12) | REST API, async support |
| Database | PostgreSQL 16 | Persistent storage for apps |
| Reverse Proxy | nginx | Routing, SSL termination |
| Container | Docker Compose | Orchestration |
| Content | Markdown + frontmatter | Decoupled content management |

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         nginx (port 80)                      │
│                      Reverse Proxy Layer                     │
└─────────────────────────────────────────────────────────────┘
                    │                         │
                    │ /                       │ /api/*, /docs, /health
                    ▼                         ▼
┌─────────────────────────┐     ┌─────────────────────────────┐
│   Frontend (Next.js)    │     │    Backend (FastAPI)        │
│      Port 3000          │     │       Port 8000             │
│                         │     │                             │
│  - Server Components    │     │  - REST API                 │
│  - App Router           │     │  - Swagger UI (/docs)       │
│  - Tailwind CSS         │     │  - Rate Limiting            │
│  - API Client           │────▶│  - API Key Auth             │
│                         │     │                             │
└─────────────────────────┘     └─────────────────────────────┘
                                              │
                    ┌─────────────────────────┼─────────────────┐
                    │                         │                 │
                    ▼                         ▼                 ▼
          ┌─────────────────┐     ┌─────────────────┐   ┌──────────────┐
          │   PostgreSQL    │     │  Content Repo   │   │   Alembic    │
          │   Port 5432     │     │  (Markdown)     │   │  Migrations  │
          │                 │     │                 │   │              │
          │  - App data     │     │  - posts/*.md   │   │  - Schema    │
          │  - User data    │     │  - images/      │   │  - Versions  │
          └─────────────────┘     └─────────────────┘   └──────────────┘
```

## Repository Structure

```
tayzhang-app/                    # Wrapper repo (this repo)
├── docker-compose.yml           # Production orchestration
├── docker-compose.dev.yml       # Development overrides
├── .env.example                 # Environment template
├── nginx/
│   └── nginx.conf               # Reverse proxy routing
├── scripts/
│   ├── backup-db.sh             # Database backup
│   └── deploy.sh                # Deployment script
├── docs/
│   └── ARCHITECTURE.md          # This file
├── CLAUDE.md                    # AI agent instructions
├── tayzhang-py-backend/         # FastAPI backend (submodule)
└── tayzhang-webapp/             # Next.js frontend (submodule)
```

### Backend Structure (`tayzhang-py-backend/`)

```
tayzhang-py-backend/
├── app/
│   ├── main.py                  # FastAPI app entry, middleware setup
│   ├── config.py                # Pydantic settings (env vars)
│   ├── database.py              # Async SQLAlchemy engine
│   ├── security/
│   │   ├── api_key.py           # X-API-Key header validation
│   │   └── rate_limit.py        # slowapi rate limiting
│   ├── models/
│   │   └── base.py              # SQLAlchemy base, timestamp mixin
│   ├── schemas/
│   │   └── post.py              # Pydantic models for API
│   ├── routers/
│   │   ├── health.py            # GET /health (public)
│   │   ├── posts.py             # GET /api/posts, /api/posts/{slug}
│   │   └── apps/                # Future: showcase app APIs
│   └── services/                # Business logic layer
├── alembic/                     # Database migrations
├── tests/
├── Dockerfile
└── requirements.txt
```

### Frontend Structure (`tayzhang-webapp/`)

```
tayzhang-webapp/
├── src/
│   ├── app/                     # Next.js App Router
│   │   ├── layout.tsx           # Root layout with Header
│   │   ├── page.tsx             # Home page
│   │   ├── posts/
│   │   │   ├── page.tsx         # Posts list
│   │   │   └── [slug]/page.tsx  # Single post (dynamic route)
│   │   └── showcase/
│   │       └── page.tsx         # App showcase
│   ├── components/
│   │   ├── Header.tsx           # Navigation component
│   │   └── PostCard.tsx         # Post preview card
│   ├── lib/
│   │   └── api.ts               # Backend API client
│   └── styles/
│       └── globals.css          # Tailwind + global styles
├── Dockerfile
├── next.config.js
└── tailwind.config.js
```

## API Design

### Authentication

All API endpoints (except `/health`) require authentication via API key:

```
Header: X-API-Key: <api-key>
```

| Endpoint | Auth | Rate Limit | Description |
|----------|------|------------|-------------|
| `GET /health` | None | None | Health check |
| `GET /api/posts` | Required | 60/min | List all posts |
| `GET /api/posts/{slug}` | Required | 60/min | Get single post |
| `GET /docs` | None | None | Swagger UI |
| `GET /redoc` | None | None | ReDoc UI |

### Rate Limiting

- Default: 100 requests/minute per IP
- Posts endpoints: 60 requests/minute per IP
- Returns `429 Too Many Requests` when exceeded

### Request Flow

```
Client Request
      │
      ▼
┌─────────────┐
│    nginx    │──── Route based on path
└─────────────┘
      │
      ▼
┌─────────────┐
│   FastAPI   │
└─────────────┘
      │
      ▼
┌─────────────┐
│ Rate Limit  │──── Check IP against limits (slowapi)
└─────────────┘
      │
      ▼
┌─────────────┐
│  API Key    │──── Validate X-API-Key header
│  Validator  │
└─────────────┘
      │
      ▼
┌─────────────┐
│   Router    │──── Business logic
└─────────────┘
      │
      ▼
┌─────────────┐
│  Response   │
└─────────────┘
```

## Content Management

Posts are stored as Markdown files with YAML frontmatter:

```markdown
---
title: "My Post Title"
slug: "my-post-title"
description: "A brief description"
author: "Taylor Zhang"
date: 2024-01-15
tags: ["tech", "programming"]
published: true
---

# Content here

The actual markdown content...
```

### Content Directory Structure

```
tayzhang-posts/                  # Content repo (https://github.com/taylorzhangyx/tayzhang-posts)
├── posts/
│   ├── my-first-post.md
│   └── another-post.md
├── images/
│   └── post-images/
└── metadata.json                # Optional: index/cache
```

The content repo is mounted as a volume in Docker at `/app/content`.

## Database Design

### Current Schema

The database is primarily for showcase apps. Base models include:

```python
class TimestampMixin:
    created_at: datetime  # Auto-set on create
    updated_at: datetime  # Auto-set on update
```

### Migrations

Alembic handles schema migrations:

```bash
# Create migration
docker compose exec backend alembic revision --autogenerate -m "description"

# Apply migrations
docker compose exec backend alembic upgrade head

# Rollback
docker compose exec backend alembic downgrade -1
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_PASSWORD` | (required) | Database password |
| `API_KEY` | (required) | API authentication key |
| `RATE_LIMIT_PER_MINUTE` | 100 | Global rate limit |
| `DATABASE_URL` | (auto) | PostgreSQL connection string |
| `CONTENT_REPO_PATH` | /app/content | Mounted content directory |
| `CORS_ORIGINS` | localhost:3000 | Allowed CORS origins |

### Docker Compose Profiles

**Production** (`docker-compose.yml`):
- Services run in production mode
- No exposed database port
- nginx handles all traffic on port 80

**Development** (`docker-compose.dev.yml`):
- Hot reload enabled for backend and frontend
- All ports exposed (3000, 8000, 5432)
- Content repo mounted from local `tayzhang-posts/`

## Deployment

### Single ECS Instance

```
┌─────────────────────────────────────────┐
│              ECS Instance               │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │       Docker Compose            │   │
│  │                                 │   │
│  │  nginx ◄── frontend            │   │
│  │    │                           │   │
│  │    └──► backend ◄── postgres   │   │
│  │              │                 │   │
│  │              ▼                 │   │
│  │         content (volume)       │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

### Deployment Script

```bash
./scripts/deploy.sh
```

This script:
1. Pulls latest code
2. Updates submodules
3. Rebuilds containers
4. Runs database migrations
5. Performs health check

### Database Backup

```bash
./scripts/backup-db.sh [output_dir]
```

Creates timestamped PostgreSQL dumps, compresses them, and optionally uploads to OSS.

## Security Considerations

1. **API Key**: Stored in environment, validated on every protected request
2. **Rate Limiting**: Prevents abuse, configured per-endpoint
3. **CORS**: Restricted to known origins
4. **Non-root containers**: Backend runs as `appuser`
5. **No exposed database**: PostgreSQL only accessible within Docker network

## Future Enhancements

- [ ] GitHub webhook for auto-pull content repo on merge
- [ ] SSL/TLS with Let's Encrypt
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Monitoring and logging (Prometheus/Grafana)
- [ ] pgvector for AI/semantic search features
- [ ] CDN for static assets

## Development Workflow

### Local Setup

```bash
# Clone and setup
git clone <repo>
cd tayzhang-app
cp .env.example .env
# Edit .env with your values

# Start services
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# Access
# Frontend: http://localhost:3000
# Backend:  http://localhost:8000
# API Docs: http://localhost:8000/docs
```

### Adding a New API Endpoint

1. Create router in `app/routers/`
2. Add Pydantic schemas in `app/schemas/`
3. Include router in `app/main.py`
4. Add tests in `tests/`

### Adding a New Page

1. Create page in `src/app/<path>/page.tsx`
2. Add components in `src/components/`
3. Update API client if needed in `src/lib/api.ts`
