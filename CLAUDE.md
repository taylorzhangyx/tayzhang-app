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

## Project Structure

Monorepo with git submodules:
- `tayzhang-webapp/` - Next.js frontend (port 3000)
- `tayzhang-py-backend/` - FastAPI backend (port 8000)
- `tayzhang-posts/` - Blog content

## Key Commands

```bash
# Development
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# Migrations
docker compose exec backend alembic upgrade head
docker compose exec backend alembic revision --autogenerate -m "description"
```

## Key Files

| Purpose | Location |
|---------|----------|
| Backend entry | `tayzhang-py-backend/app/main.py` |
| API routes | `tayzhang-py-backend/app/routers/` |
| Frontend pages | `tayzhang-webapp/src/app/` |
| Docker config | `docker-compose.yml` |
