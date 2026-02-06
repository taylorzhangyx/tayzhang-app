# tayzhang-app

Personal website with content portal and app showcase. See [README.md](README.md) for project overview.

## Git Workflow

Always use branch-based workflow. Never commit directly to `main`.

**Branch naming:**
- `feature/xxx` - New features
- `fix/xxx` - Bug fixes
- `docs/xxx` - Documentation
- `chore/xxx` - Maintenance

**Workflow:** Create branch → Commit → Push → Create PR to `main`

## Submodule Workflow

After merging PRs in submodules (tayzhang-webapp, tayzhang-py-backend):
1. Pull latest main in each submodule
2. Commit updated submodule references in root repo
3. Push root repo

## Project Structure

Monorepo with git submodules:
- `tayzhang-webapp/` - Next.js frontend (port 3000)
- `tayzhang-py-backend/` - FastAPI backend (port 8000)
- `tayzhang-posts/` - Blog content

## Key Commands

```bash
# Development (preferred)
make dev

# Or manually
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# Migrations
docker compose exec backend alembic upgrade head
docker compose exec backend alembic revision --autogenerate -m "description"
```

## API Testing

```bash
# Health check (no auth)
curl http://localhost:8000/health

# API endpoints (requires auth)
curl -H "X-API-Key: changeme-in-production" http://localhost:8000/api/posts
```

## Key Files

| Purpose | Location |
|---------|----------|
| Backend entry | `tayzhang-py-backend/app/main.py` |
| API routes | `tayzhang-py-backend/app/routers/` |
| Frontend pages | `tayzhang-webapp/src/app/` |
| Docker config | `docker-compose.yml` |

## Content Structure

Posts in `tayzhang-posts/posts/` use folder format:
```
posts/
├── YYYY-MM-DD-slug-name/
│   ├── README.md    # Post content with frontmatter
│   ├── img/         # Local images
│   └── audio/       # Audio files (future)
```
