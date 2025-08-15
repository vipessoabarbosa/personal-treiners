# FitCoach Pro

> Aplicativo inteligente para personal trainers com foco em logística de equipamentos e otimização de treinos.

## 🎯 Visão Geral

O FitCoach Pro é uma solução completa que revoluciona a forma como personal trainers criam e gerenciam treinos, oferecendo inteligência logística para adaptar exercícios aos equipamentos disponíveis em cada academia.

### ✨ Principais Funcionalidades

- **Inteligência Logística**: Adaptação automática de treinos baseada nos equipamentos disponíveis
- **Gestão de Clientes**: Cadastro completo com anamnese e acompanhamento de progresso
- **Criação de Treinos**: Sistema inteligente de sugestões e personalizações
- **Multi-Academia**: Suporte para personal trainers que trabalham em múltiplas academias
- **Dashboards**: Relatórios e métricas de performance dos clientes

## 🏗️ Arquitetura do Projeto

```
fitcoach-pro/
├── backend/          # API Node.js + Express + PostgreSQL
├── frontend/         # Dashboard Web React + TypeScript
├── mobile/           # App React Native + TypeScript
├── shared/           # Tipos, utilitários e validações compartilhadas
├── docker/           # Configurações Docker para desenvolvimento
├── scripts/          # Scripts de automação e deploy
├── tests/            # Testes E2E e de integração
└── docs/             # Documentação do projeto
```

## 🚀 Stack Tecnológico

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL 15+
- **ORM**: Prisma
- **Cache**: Redis
- **Auth**: JWT + bcrypt
- **Validation**: Zod
- **Testing**: Jest + Supertest

### Frontend (Dashboard Web)
- **Framework**: React 18 + TypeScript
- **Build**: Vite
- **Styling**: Tailwind CSS
- **State**: Zustand
- **Forms**: React Hook Form + Zod
- **Charts**: Recharts
- **Testing**: Vitest + Testing Library

### Mobile
- **Framework**: React Native + TypeScript
- **Navigation**: React Navigation 6
- **State**: Zustand
- **Forms**: React Hook Form + Zod
- **Testing**: Jest + Detox

### DevOps & Infraestrutura
- **Containerização**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Deploy**: Railway (Backend) + Vercel (Frontend)
- **Monitoramento**: Sentry
- **Analytics**: PostHog

## 🛠️ Setup de Desenvolvimento

### Pré-requisitos

- Node.js 18+
- Docker & Docker Compose
- Git
- PostgreSQL 15+ (ou usar Docker)
- Redis (ou usar Docker)

### Instalação

1. **Clone o repositório**
   ```bash
   git clone <repository-url>
   cd fitcoach-pro
   ```

2. **Configure as variáveis de ambiente**
   ```bash
   cp .env.example .env
   # Edite o arquivo .env com suas configurações
   ```

3. **Inicie os serviços com Docker**
   ```bash
   docker-compose up -d
   ```

4. **Instale as dependências**
   ```bash
   # Backend
   cd backend && npm install
   
   # Frontend
   cd ../frontend && npm install
   
   # Mobile
   cd ../mobile && npm install
   ```

5. **Execute as migrações do banco**
   ```bash
   cd backend
   npx prisma migrate dev
   npx prisma db seed
   ```

6. **Inicie os serviços de desenvolvimento**
   ```bash
   # Terminal 1 - Backend
   cd backend && npm run dev
   
   # Terminal 2 - Frontend
   cd frontend && npm run dev
   
   # Terminal 3 - Mobile
   cd mobile && npm run start
   ```

## 📱 Ambientes

### Development
- **Backend**: http://localhost:3001
- **Frontend**: http://localhost:3000
- **Mobile**: Expo Dev Tools
- **Database**: PostgreSQL local (porta 5432)
- **Cache**: Redis local (porta 6379)

### Staging
- **Backend**: https://fitcoach-api-staging.railway.app
- **Frontend**: https://fitcoach-staging.vercel.app
- **Database**: PostgreSQL Railway

### Production
- **Backend**: https://api.fitcoach.pro
- **Frontend**: https://dashboard.fitcoach.pro
- **Database**: PostgreSQL Railway (produção)

## 🧪 Testes

```bash
# Testes unitários
npm run test

# Testes com coverage
npm run test:coverage

# Testes E2E
npm run test:e2e

# Testes de integração
npm run test:integration
```

## 📦 Deploy

### Backend (Railway)
```bash
npm run deploy:backend
```

### Frontend (Vercel)
```bash
npm run deploy:frontend
```

### Mobile (Expo)
```bash
cd mobile
npm run build:android
npm run build:ios
```

## 🔧 Scripts Úteis

```bash
# Gerar tipos do Prisma
npm run db:generate

# Reset do banco de dados
npm run db:reset

# Executar seeds
npm run db:seed

# Lint e formatação
npm run lint
npm run format

# Build de produção
npm run build
```

## 📚 Documentação

- [📋 PRD - Product Requirements Document](./docs/PRD.md)
- [🏗️ Arquitetura Técnica](./docs/arquitetura-tecnica.md)
- [🗺️ Roadmap de Desenvolvimento](./docs/roadmap-desenvolvimento.md)
- [⚙️ Especificações Funcionais](./docs/especificacoes-funcionais.md)
- [🗄️ Modelagem de Dados](./docs/modelagem-dados.md)
- [🧪 Plano de Testes](./docs/plano-testes.md)

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👥 Equipe

- **Product Owner**: [Nome]
- **Tech Lead**: [Nome]
- **Backend Developer**: [Nome]
- **Frontend Developer**: [Nome]
- **Mobile Developer**: [Nome]
- **QA Engineer**: [Nome]
- **DevOps Engineer**: [Nome]

## 📞 Suporte

Para suporte técnico ou dúvidas sobre o projeto:

- 📧 Email: dev@fitcoach.pro
- 💬 Slack: #fitcoach-dev
- 🐛 Issues: [GitHub Issues](https://github.com/org/fitcoach-pro/issues)

---

**FitCoach Pro** - Revolucionando o treinamento personalizado através da tecnologia 🚀