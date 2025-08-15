-- ==============================================
-- FITCOACH PRO - PostgreSQL Initialization
-- ==============================================
-- Este script é executado na primeira inicialização do container PostgreSQL

-- Criar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Criar banco de dados de teste (se não existir)
SELECT 'CREATE DATABASE fitcoach_test'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'fitcoach_test')\gexec

-- Configurações de performance
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;

-- Configurações de logging
ALTER SYSTEM SET log_destination = 'stderr';
ALTER SYSTEM SET logging_collector = on;
ALTER SYSTEM SET log_directory = 'pg_log';
ALTER SYSTEM SET log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log';
ALTER SYSTEM SET log_statement = 'mod';
ALTER SYSTEM SET log_min_duration_statement = 1000;

-- Configurações de timezone
ALTER SYSTEM SET timezone = 'America/Sao_Paulo';
ALTER SYSTEM SET log_timezone = 'America/Sao_Paulo';

-- Recarregar configurações
SELECT pg_reload_conf();

-- Criar usuário para aplicação (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'fitcoach_app') THEN
        CREATE ROLE fitcoach_app WITH LOGIN PASSWORD 'app_password';
    END IF;
END
$$;

-- Conceder permissões
GRANT CONNECT ON DATABASE fitcoach_dev TO fitcoach_app;
GRANT CONNECT ON DATABASE fitcoach_test TO fitcoach_app;

-- Conectar ao banco principal e configurar schema
\c fitcoach_dev;

-- Criar schema da aplicação
CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION fitcoach_user;

-- Conceder permissões no schema
GRANT USAGE ON SCHEMA app TO fitcoach_app;
GRANT CREATE ON SCHEMA app TO fitcoach_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO fitcoach_app;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO fitcoach_app;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA app TO fitcoach_app;

-- Configurar permissões padrão para objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT ALL ON TABLES TO fitcoach_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT ALL ON SEQUENCES TO fitcoach_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT ALL ON FUNCTIONS TO fitcoach_app;

-- Criar função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION app.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar função para gerar IDs únicos
CREATE OR REPLACE FUNCTION app.generate_unique_id(prefix TEXT DEFAULT '')
RETURNS TEXT AS $$
BEGIN
    RETURN prefix || EXTRACT(EPOCH FROM NOW())::BIGINT || LPAD(FLOOR(RANDOM() * 1000)::TEXT, 3, '0');
END;
$$ language 'plpgsql';

-- Criar função para busca full-text em português
CREATE OR REPLACE FUNCTION app.search_text(text_to_search TEXT, search_term TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN to_tsvector('portuguese', unaccent(LOWER(text_to_search))) @@ 
           plainto_tsquery('portuguese', unaccent(LOWER(search_term)));
END;
$$ language 'plpgsql' IMMUTABLE;

-- Configurar search_path padrão
ALTER DATABASE fitcoach_dev SET search_path TO app, public;
ALTER DATABASE fitcoach_test SET search_path TO app, public;

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'FitCoach Pro database initialized successfully!';
    RAISE NOTICE 'Database: fitcoach_dev';
    RAISE NOTICE 'Test Database: fitcoach_test';
    RAISE NOTICE 'Schema: app';
    RAISE NOTICE 'Extensions: uuid-ossp, pgcrypto, unaccent';
END
$$;