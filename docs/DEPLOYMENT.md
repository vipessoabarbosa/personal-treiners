# Guia de Deployment - FitCoach Pro

> Documentação completa para deploy em diferentes ambientes

## 🌍 Ambientes

### Visão Geral dos Ambientes

| Ambiente | Propósito | Branch | URL | Hosting |
|----------|-----------|--------|-----|----------|
| **Development** | Desenvolvimento local | `feature/*` | localhost | Docker |
| **Staging** | Homologação e testes | `develop` | staging.fitcoachpro.com | Railway + Vercel |
| **Production** | Produção | `main` | fitcoachpro.com | Railway + Vercel |

## 🚀 Deploy Automático (CI/CD)

### GitHub Actions Workflows

O projeto utiliza GitHub Actions para deploy automático:

```yaml
# Triggers de deploy
- Push para develop → Deploy para Staging
- Push para main → Deploy para Production
- Pull Request → Testes e validações
```

### Pipeline de Deploy

1. **Testes e Qualidade**
   - Lint e type checking
   - Testes unitários e integração
   - Cobertura de código
   - Análise de segurança

2. **Build e Validação**
   - Build dos componentes
   - Testes E2E
   - Validação de performance

3. **Deploy**
   - Deploy para ambiente alvo
   - Migrações de banco
   - Smoke tests
   - Notificações

## 🛠️ Deploy Manual

### Script de Deploy

```bash
# Deploy completo para staging
./scripts/deploy.sh -e staging

# Deploy completo para produção
./scripts/deploy.sh -e production

# Deploy apenas backend
./scripts/deploy.sh -e staging -c backend

# Deploy apenas frontend
./scripts/deploy.sh -e staging -c frontend

# Deploy apenas mobile
./scripts/deploy.sh -e staging -c mobile

# Deploy com opções avançadas
./scripts/deploy.sh -e production -c all --skip-tests --force
```

### Opções do Script

| Opção | Descrição |
|-------|----------|
| `-e, --environment` | Ambiente alvo (development, staging, production) |
| `-c, --component` | Componente específico (backend, frontend, mobile, all) |
| `--skip-tests` | Pular execução de testes |
| `--skip-build` | Pular processo de build |
| `--force` | Forçar deploy mesmo com falhas |
| `--verbose` | Saída detalhada |
| `--help` | Exibir ajuda |

## 🏗️ Configuração por Ambiente

### Development (Local)

```bash
# Configuração
cp environments/development.env .env

# Iniciar serviços
docker-compose up -d

# Deploy local
./scripts/deploy.sh -e development
```

**Características:**
- Docker Compose para infraestrutura
- Hot reload habilitado
- Logs detalhados
- Dados de teste
- MailHog para emails

### Staging

```bash
# Deploy automático via GitHub Actions
git push origin develop

# Deploy manual
./scripts/deploy.sh -e staging
```

**Configuração:**
- **Backend**: Railway
- **Frontend**: Vercel
- **Mobile**: Expo Development Build
- **Database**: Railway PostgreSQL
- **Cache**: Railway Redis

**Características:**
- Dados de teste realistas
- Integração com APIs de teste
- Monitoramento básico
- SSL/TLS habilitado

### Production

```bash
# Deploy automático via GitHub Actions
git push origin main

# Deploy manual (requer aprovação)
./scripts/deploy.sh -e production
```

**Configuração:**
- **Backend**: Railway (produção)
- **Frontend**: Vercel (produção)
- **Mobile**: App Store + Google Play
- **Database**: Railway PostgreSQL (produção)
- **Cache**: Railway Redis (produção)
- **CDN**: Cloudflare
- **Monitoring**: Sentry + Analytics

## 🔧 Configuração de Hosting

### Railway (Backend)

#### Setup Inicial

```bash
# Instalar Railway CLI
npm install -g @railway/cli

# Login
railway login

# Conectar projeto
railway link
```

#### Configuração de Variáveis

```bash
# Staging
railway variables set NODE_ENV=staging
railway variables set DATABASE_URL=${{Postgres.DATABASE_URL}}
railway variables set REDIS_URL=${{Redis.REDIS_URL}}

# Production
railway variables set NODE_ENV=production
railway variables set DATABASE_URL=${{Postgres.DATABASE_URL}}
railway variables set REDIS_URL=${{Redis.REDIS_URL}}
```

#### Deploy

```bash
# Deploy manual
railway up

# Deploy com logs
railway up --detach
railway logs
```

### Vercel (Frontend)

#### Setup Inicial

```bash
# Instalar Vercel CLI
npm install -g vercel

# Login
vercel login

# Conectar projeto
vercel link
```

#### Configuração

```json
// vercel.json
{
  "builds": [
    {
      "src": "frontend/package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "dist"
      }
    }
  ],
  "routes": [
    {
      "handle": "filesystem"
    },
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

#### Deploy

```bash
# Deploy para preview
vercel

# Deploy para produção
vercel --prod
```

### Expo (Mobile)

#### Setup Inicial

```bash
# Login no Expo
npx expo login

# Configurar projeto
npx expo install
```

#### Build e Deploy

```bash
# Development build
npx expo build:android --type apk
npx expo build:ios --type simulator

# Production build
npx expo build:android --type app-bundle
npx expo build:ios --type archive

# Publish OTA update
npx expo publish
```

## 🗄️ Migrações de Banco

### Estratégia de Migrações

```bash
# Criar nova migração
cd backend
npm run migration:create -- --name add_user_preferences

# Executar migrações
npm run migrate

# Rollback (se necessário)
npm run migrate:rollback

# Status das migrações
npm run migrate:status
```

### Deploy com Migrações

```bash
# O script de deploy executa automaticamente:
1. Backup do banco (produção)
2. Execução das migrações
3. Verificação de integridade
4. Rollback automático em caso de erro
```

## 🔍 Monitoramento e Health Checks

### Health Checks

```bash
# Backend
curl https://api.fitcoachpro.com/health

# Frontend
curl https://fitcoachpro.com/health

# Database
curl https://api.fitcoachpro.com/health/db

# Redis
curl https://api.fitcoachpro.com/health/redis
```

### Smoke Tests Pós-Deploy

```bash
# Executados automaticamente após deploy
- Teste de login
- Teste de criação de treino
- Teste de upload de arquivo
- Teste de notificação push
- Teste de integração com APIs externas
```

### Monitoramento

- **Uptime**: UptimeRobot
- **Performance**: Vercel Analytics
- **Errors**: Sentry
- **Logs**: Railway Logs
- **Metrics**: Railway Metrics

## 🔒 Segurança no Deploy

### Secrets Management

```bash
# GitHub Secrets (CI/CD)
RAILWAY_TOKEN=xxx
VERCEL_TOKEN=xxx
EXPO_TOKEN=xxx
SENTRY_AUTH_TOKEN=xxx

# Railway Variables
JWT_SECRET=xxx
DATABASE_URL=xxx
STRIPE_SECRET_KEY=xxx

# Vercel Environment Variables
VITE_API_URL=xxx
VITE_STRIPE_PUBLIC_KEY=xxx
```

### Checklist de Segurança

- [ ] Todas as secrets estão configuradas
- [ ] CORS configurado corretamente
- [ ] Rate limiting habilitado
- [ ] SSL/TLS configurado
- [ ] Headers de segurança definidos
- [ ] Logs não expõem informações sensíveis
- [ ] Backup automático configurado

## 🚨 Rollback e Recovery

### Rollback Automático

```bash
# O sistema executa rollback automático se:
- Health checks falharem
- Smoke tests falharem
- Erro crítico nas migrações
- Timeout no deploy
```

### Rollback Manual

```bash
# Railway
railway rollback

# Vercel
vercel rollback

# Banco de dados
cd backend
npm run migrate:rollback

# Script completo de rollback
./scripts/rollback.sh -e production --to-version v1.2.3
```

### Backup e Recovery

```bash
# Backup automático (diário)
- Banco de dados
- Arquivos de upload
- Configurações

# Recovery
./scripts/restore.sh --backup-date 2024-01-15 --environment production
```

## 📊 Métricas de Deploy

### KPIs Monitorados

- **Deploy Frequency**: Frequência de deploys
- **Lead Time**: Tempo do commit ao deploy
- **MTTR**: Tempo médio de recuperação
- **Change Failure Rate**: Taxa de falha em mudanças

### Relatórios

```bash
# Relatório de deploy
./scripts/deploy-report.sh --period last-month

# Métricas de performance
./scripts/performance-report.sh --environment production
```

## 🔧 Troubleshooting de Deploy

### Problemas Comuns

#### 1. Falha no Build

```bash
# Verificar logs
railway logs --tail 100

# Build local para debug
npm run build

# Verificar dependências
npm audit
```

#### 2. Erro nas Migrações

```bash
# Verificar status
npm run migrate:status

# Rollback manual
npm run migrate:rollback

# Aplicar migração específica
npm run migrate:up -- --to 20240115_add_user_preferences
```

#### 3. Health Check Falhando

```bash
# Verificar conectividade
curl -v https://api.fitcoachpro.com/health

# Verificar logs de erro
railway logs --filter error

# Verificar variáveis de ambiente
railway variables
```

#### 4. Performance Issues

```bash
# Verificar métricas
railway metrics

# Análise de performance
npm run analyze

# Otimizar bundle
npm run build:analyze
```

## 📋 Checklist de Deploy

### Pré-Deploy

- [ ] Testes passando localmente
- [ ] Code review aprovado
- [ ] Migrações testadas
- [ ] Variáveis de ambiente configuradas
- [ ] Backup realizado (produção)
- [ ] Equipe notificada

### Durante o Deploy

- [ ] Monitorar logs em tempo real
- [ ] Verificar health checks
- [ ] Executar smoke tests
- [ ] Validar métricas de performance

### Pós-Deploy

- [ ] Smoke tests passando
- [ ] Métricas normais
- [ ] Funcionalidades críticas testadas
- [ ] Equipe notificada do sucesso
- [ ] Documentação atualizada

---

**Última atualização**: Janeiro 2024
**Versão do guia**: 1.0.0