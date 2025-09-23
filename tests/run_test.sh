docker compose down -v
docker compose up -d

if ! docker compose exec db psql -U postgres -d test_db -c "\dt" | grep -q "_sqlx_migrations"; then
    echo "ERROR: _sqlx_migrations table not found"
    docker compose down -v
    exit 1
fi

if ! docker compose exec db psql -U postgres -d test_db -c "\dt" | grep -q "test_table"; then
    echo "ERROR: new_table not found"
    docker compose down -v
    exit 1
fi

docker compose down

sqlx migrate add new

NEW_MIGRATION=$(ls migrations/*_new.up.sql | tail -1)
cat > "$NEW_MIGRATION" << 'EOF'
CREATE TABLE IF NOT EXISTS new_table (
  id TEXT PRIMARY KEY,
  value TEXT NOT NULL UNIQUE
);
EOF

docker compose up -d

if ! docker compose exec db psql -U postgres -d test_db -c "\dt" | grep -q "_sqlx_migrations"; then
    echo "ERROR: _sqlx_migrations table not found"
    docker compose down -v
    rm migrations/*_new*
    exit 1
fi

if ! docker compose exec db psql -U postgres -d test_db -c "\dt" | grep -q "test_table"; then
    echo "ERROR: test_table not found"
    docker compose down -v
    rm migrations/*_new*
    exit 1
fi

if ! docker compose exec db psql -U postgres -d test_db -c "\dt" | grep -q "new_table"; then
    echo "ERROR: new_table not found"
    docker compose down -v
    rm migrations/*_new*
    exit 1
fi

docker compose down -v
rm migrations/*_new*
