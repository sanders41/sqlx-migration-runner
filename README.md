# sqlx-cli docker image to run migrations

Currently only supports PostgreSQL. Make sure to mount the local `migrations` directory to the
`migrations` directory in the contnainer.

## Example docker-compose.yml

```yaml
services:
  db:
    image: postgres:18-alpine
    restart: unless-stopped
    container_name: db
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"]
      interval: 10s
      retries: 5
      start_period: 30s
      timeout: 10s
    expose:
      - 5432
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD?Variable not set}
      - POSTGRES_USER=${POSTGRES_USER?Variable not set}
      - POSTGRES_DB=${POSTGRES_DB?Variable not set}
    volumes:
      - db-data:/var/lib/postgresql/data

  migrations:
    image: ghcr.io/sanders41/sqlx-migration-runner:latest
    container_name: migrations
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD?Variable not set}
      - POSTGRES_USER=${POSTGRES_USER?Variable not set}
      - POSTGRES_DB=${POSTGRES_DB?Variable not set}
      - POSTGRES_HOST=db
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
    depends_on:
      db:
        condition: service_healthy
        restart: true
    volumes:
      - ./migrations:/migrations

volumes:
  db-data:
```

## How To Pull The container

```sh
docker pull ghcr.io/sanders41/sqlx-migration-runner:latest
```
