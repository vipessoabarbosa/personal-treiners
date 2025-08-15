# Setup e Configuração - FitCoach Pro

> Guia completo para configuração do ambiente de desenvolvimento

## 📋 Pré-requisitos

### Requisitos do Sistema

- **Node.js**: 18.0.0 ou superior
- **npm**: 8.0.0 ou superior
- **Git**: 2.30.0 ou superior
- **Docker**: 20.10.0 ou superior (opcional, mas recomendado)
- **Docker Compose**: 2.0.0 ou superior (opcional)

### Verificação dos Requisitos

```bash
# Verificar versões instaladas
node --version    # v18.0.0+
npm --version     # 8.0.0+
git --version     # 2.30.0+
docker --version  # 20.10.0+
docker-compose --version  # 2.0.0+
```

## 🚀 Setup Automático

### Opção 1: Setup Completo

```bash
# Clone o repositório
git clone <repository-url>
cd fitcoach-pro

# Execute o script de setup automático
./scripts/setup.sh
```

### Opção 2: Setup Seletivo

```bash
# Setup apenas backend
./scripts/setup.sh --backend-only

# Setup apenas frontend
./scripts/setup.sh --frontend-only

# Setup apenas mobile
./scripts/setup.sh --mobile-only

# Setup apenas Docker
./scripts/setup.sh --docker-only

# Pular instalação de dependências
./scripts/setup.sh --skip-install

# Pular configuração Docker
./scripts/setup.sh --skip-docker
```

## 🔧 Setup Manual

### 1. Clone e Configuração Inicial

```bash
# Clone o repositório
git clone <repository-url>
cd fitcoach-pro

# Copie o arquivo de exemplo de variáveis de ambiente
cp .env.example .env
```

### 2. Configuração de Variáveis de Ambiente

Edite o arquivo `.env` com suas configurações:

```bash
# Configurações essenciais
NODE_ENV=development
PORT=3001

# Banco de dados
DATABASE_URL=postgresql://fitcoach_user:sua_senha@localhost:5432/fitcoach_dev
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fitcoach_dev
DB_USER=fitcoach_user
DB_PASSWORD=sua_senha_segura

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=sua_chave_jwt_super_secreta_minimo_32_caracteres
JWT_REFRESH_SECRET=sua_chave_refresh_super_secreta_minimo_32_caracteres

# Email (desenvolvimento)
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_FROM=noreply@fitcoachpro.com
```

### 3. Setup com Docker (Recomendado)

```bash
# Inicie os serviços de infraestrutura
docker-compose up -d postgres redis

# Aguarde os serviços iniciarem (cerca de 30 segundos)
docker-compose ps

# Verifique se os serviços estão saudáveis
docker-compose exec postgres pg_isready -U postgres
docker-compose exec redis redis-cli ping
```

### 4. Instalação de Dependências

```bash
# Instalar dependências compartilhadas
cd shared
npm install
npm run build
cd ..

# Instalar dependências do backend
cd backend
npm install
cd ..

# Instalar dependências do frontend
cd frontend
npm install
cd ..

# Instalar dependências do mobile
cd mobile
npm install

# Instalar Expo CLI globalmente (se necessário)
npm install -g @expo/cli
cd ..
```

### 5. Configuração do Banco de Dados

```bash
cd backend

# Executar migrações
npm run migrate

# Popular banco com dados de exemplo (opcional)
npm run seed

# Verificar se as tabelas foram criadas
npm run db:status
```

### 6. Inicialização dos Serviços

```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Frontend
cd frontend
npm run dev

# Terminal 3 - Mobile (opcional)
cd mobile
npx expo start
```

## 🐳 Configuração Docker Detalhada

### Serviços Disponíveis

```yaml
# docker-compose.yml inclui:
- postgres:15     # Banco de dados principal
- redis:7         # Cache e sessões
- adminer         # Interface web para PostgreSQL
- mailhog         # Servidor de email para desenvolvimento
- redis-commander # Interface web para Redis
```

### Comandos Docker Úteis

```bash
# Iniciar todos os serviços
docker-compose up -d

# Iniciar serviços específicos
docker-compose up -d postgres redis

# Ver logs dos serviços
docker-compose logs -f
docker-compose logs -f postgres

# Parar todos os serviços
docker-compose down

# Parar e remover volumes (CUIDADO: apaga dados)
docker-compose down -v

# Reconstruir imagens
docker-compose build --no-cache

# Executar comandos nos containers
docker-compose exec postgres psql -U postgres -d fitcoach_dev
docker-compose exec redis redis-cli
```

### URLs dos Serviços Docker

- **PostgreSQL**: `localhost:5432`
- **Redis**: `localhost:6379`
- **Adminer**: http://localhost:8080
- **MailHog**: http://localhost:8025
- **Redis Commander**: http://localhost:8081

## 🧪 Verificação da Instalação

### Testes de Conectividade

```bash
# Testar conexão com PostgreSQL
psql -h localhost -p 5432 -U fitcoach_user -d fitcoach_dev -c "SELECT version();"

# Testar conexão com Redis
redis-cli -h localhost -p 6379 ping

# Testar API backend
curl http://localhost:3001/health

# Testar frontend
curl http://localhost:5173
```

### Executar Testes

```bash
# Testes do backend
cd backend
npm test

# Testes do frontend
cd frontend
npm test

# Testes do mobile
cd mobile
npm test

# Testes de integração
npm run test:integration
```

## 🔍 Troubleshooting

### Problemas Comuns

#### 1. Erro de Porta em Uso

```bash
# Verificar qual processo está usando a porta
lsof -i :3001

# Matar processo específico
kill -9 <PID>

# Ou usar porta alternativa no .env
PORT=3002
```

#### 2. Erro de Conexão com Banco

```bash
# Verificar se PostgreSQL está rodando
docker-compose ps postgres

# Verificar logs do PostgreSQL
docker-compose logs postgres

# Reiniciar PostgreSQL
docker-compose restart postgres

# Verificar conectividade
docker-compose exec postgres pg_isready -U postgres
```

#### 3. Erro de Permissões

```bash
# Dar permissão aos scripts
chmod +x scripts/*.sh

# Verificar permissões Docker
sudo usermod -aG docker $USER
# (necessário logout/login após este comando)
```

#### 4. Problemas com Node Modules

```bash
# Limpar cache npm
npm cache clean --force

# Remover node_modules e reinstalar
rm -rf node_modules package-lock.json
npm install

# Para todos os projetos
find . -name "node_modules" -type d -exec rm -rf {} +
find . -name "package-lock.json" -delete
./scripts/setup.sh --skip-docker
```

#### 5. Problemas com Expo

```bash
# Limpar cache Expo
npx expo install --fix

# Reinstalar Expo CLI
npm uninstall -g @expo/cli
npm install -g @expo/cli@latest

# Verificar configuração
npx expo doctor
```

### Logs e Debugging

```bash
# Logs da aplicação backend
tail -f backend/logs/app.log

# Logs Docker
docker-compose logs -f --tail=100

# Logs específicos
docker-compose logs -f postgres
docker-compose logs -f redis

# Debug mode
DEBUG=fitcoach:* npm run dev
```

## 🔒 Configurações de Segurança

### Variáveis Sensíveis

```bash
# Gerar chaves JWT seguras
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Gerar senha segura para banco
openssl rand -base64 32

# Verificar se .env não está no git
git status --ignored
```

### Configurações Recomendadas

```bash
# .env para desenvolvimento
JWT_SECRET=$(openssl rand -hex 32)
JWT_REFRESH_SECRET=$(openssl rand -hex 32)
SESSION_SECRET=$(openssl rand -hex 32)
DB_PASSWORD=$(openssl rand -base64 32)
```

## 📚 Próximos Passos

Após a configuração bem-sucedida:

1. **Leia a documentação da API**: `docs/API.md`
2. **Configure seu IDE**: `docs/IDE_SETUP.md`
3. **Entenda a arquitetura**: `docs/ARCHITECTURE.md`
4. **Contribua para o projeto**: `docs/CONTRIBUTING.md`

## 🆘 Suporte

Se você encontrar problemas durante o setup:

1. Verifique os logs de erro
2. Consulte a seção de troubleshooting
3. Abra uma issue no GitHub
4. Entre em contato com a equipe de desenvolvimento

---

**Última atualização**: Janeiro 2024
**Versão do guia**: 1.0.0