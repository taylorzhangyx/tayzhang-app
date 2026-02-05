# tayzhang-app

Personal website with content portal and app showcase.

**For detailed architecture and design, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)**

## Quick Reference

| Component | Location | Port |
|-----------|----------|------|
| Frontend | `tayzhang-webapp/` | 3000 |
| Backend | `tayzhang-py-backend/` | 8000 |
| Database | PostgreSQL | 5432 |
| Proxy | nginx | 80 |

## Common Commands

```bash
# Start development
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# Start production
docker compose up -d

# View logs
docker compose logs -f [service]

# Run migrations
docker compose exec backend alembic upgrade head

# Create migration
docker compose exec backend alembic revision --autogenerate -m "description"

# Backup database
./scripts/backup-db.sh

# Deploy updates
./scripts/deploy.sh
```

## Endpoints

- Frontend: http://localhost:3000 (dev) or http://localhost (prod)
- Backend API: http://localhost:8000/api/
- Swagger UI: http://localhost:8000/docs
- Health: http://localhost:8000/health

## API Testing

```bash
# Health check (no auth)
curl http://localhost:8000/health

# Posts API (requires auth)
curl -H "X-API-Key: <key>" http://localhost:8000/api/posts
```

## Key Files

| Purpose | File |
|---------|------|
| Backend entry | `tayzhang-py-backend/app/main.py` |
| Backend config | `tayzhang-py-backend/app/config.py` |
| API routes | `tayzhang-py-backend/app/routers/` |
| Frontend pages | `tayzhang-webapp/src/app/` |
| API client | `tayzhang-webapp/src/lib/api.ts` |
| Docker config | `docker-compose.yml` |
| nginx routing | `nginx/nginx.conf` |

## Adding Features

**New API endpoint:**
1. Add router in `tayzhang-py-backend/app/routers/`
2. Add schemas in `tayzhang-py-backend/app/schemas/`
3. Include router in `app/main.py`

**New frontend page:**
1. Create `page.tsx` in `tayzhang-webapp/src/app/<path>/`
2. Add components in `src/components/` if needed
3. Update `src/lib/api.ts` for new API calls

## Environment Variables

Required in `.env`:
- `POSTGRES_PASSWORD` - Database password
- `API_KEY` - API authentication key

See `.env.example` for all options.
