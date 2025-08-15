# **Documento de Arquitetura Técnica**
# **FitCoach Pro - Aplicativo para Personal Trainers**

**Versão:** 1.0  
**Data:** Janeiro 2025  
**Autor:** Arquiteto de Software  
**Status:** Draft  

---

## **1. Visão Geral da Arquitetura**

### **1.1 Princípios Arquiteturais**

- **Escalabilidade:** Arquitetura preparada para crescimento horizontal
- **Modularidade:** Componentes desacoplados e reutilizáveis
- **Segurança:** Proteção de dados sensíveis (LGPD compliance)
- **Performance:** Otimização para dispositivos móveis
- **Manutenibilidade:** Código limpo e bem documentado
- **Disponibilidade:** Sistema resiliente com alta disponibilidade

### **1.2 Padrões Arquiteturais**

- **Clean Architecture:** Separação clara de responsabilidades
- **Microserviços:** Serviços independentes e especializados
- **API-First:** Design centrado em APIs RESTful
- **Mobile-First:** Priorização da experiência móvel
- **Event-Driven:** Comunicação assíncrona entre serviços

---

## **2. Stack Tecnológico**

### **2.1 Frontend**

#### **Mobile (Aplicativo Principal)**
- **Framework:** React Native 0.73+
- **Linguagem:** TypeScript
- **Gerenciamento de Estado:** Redux Toolkit + RTK Query
- **Navegação:** React Navigation 6
- **UI Components:** React Native Elements + Custom Design System
- **Formulários:** React Hook Form + Yup
- **Câmera/Mídia:** React Native Image Picker
- **Notificações:** React Native Push Notification
- **Offline:** Redux Persist + AsyncStorage

#### **Web (Dashboard Administrativo)**
- **Framework:** Next.js 14+ (App Router)
- **Linguagem:** TypeScript
- **Styling:** Tailwind CSS + Shadcn/ui
- **Gerenciamento de Estado:** Zustand
- **Formulários:** React Hook Form + Zod
- **Gráficos:** Recharts
- **Tabelas:** TanStack Table

### **2.2 Backend**

#### **API Gateway**
- **Tecnologia:** Kong ou AWS API Gateway
- **Funcionalidades:** Rate limiting, autenticação, roteamento

#### **Microserviços**
- **Linguagem:** Node.js com TypeScript
- **Framework:** Fastify ou Express.js
- **Validação:** Zod
- **ORM:** Prisma
- **Documentação:** Swagger/OpenAPI

#### **Serviços Principais:**
1. **Auth Service:** Autenticação e autorização
2. **User Service:** Gestão de usuários (personal trainers e clientes)
3. **Gym Service:** Cadastro de academias e equipamentos
4. **Workout Service:** Criação e gestão de treinos
5. **Progress Service:** Acompanhamento de progresso
6. **Schedule Service:** Gestão de agenda
7. **Chat Service:** Sistema de mensagens
8. **Notification Service:** Notificações push e email

### **2.3 Banco de Dados**

#### **Banco Principal**
- **SGBD:** PostgreSQL 15+
- **Hosting:** AWS RDS ou Railway
- **Backup:** Backup automático diário
- **Replicação:** Read replicas para consultas

#### **Cache**
- **Tecnologia:** Redis
- **Uso:** Cache de sessões, dados frequentes, rate limiting

#### **Armazenamento de Arquivos**
- **Tecnologia:** AWS S3 ou Cloudinary
- **Uso:** Fotos de progresso, avatars, documentos

### **2.4 Infraestrutura**

#### **Containerização**
- **Docker:** Containerização dos serviços
- **Docker Compose:** Ambiente de desenvolvimento

#### **Orquestração**
- **Kubernetes:** Produção (opcional para MVP)
- **Docker Swarm:** Alternativa mais simples

#### **Cloud Provider**
- **Primário:** AWS
- **Alternativo:** Railway (para MVP)

#### **CI/CD**
- **GitHub Actions:** Pipeline de deploy
- **Testes:** Jest + Supertest
- **Qualidade:** ESLint + Prettier + Husky

### **2.5 Monitoramento e Observabilidade**

- **Logs:** Winston + CloudWatch
- **Métricas:** Prometheus + Grafana
- **APM:** New Relic ou DataDog
- **Uptime:** Pingdom ou UptimeRobot
- **Error Tracking:** Sentry

---

## **3. Arquitetura de Alto Nível**

```
┌─────────────────┐    ┌─────────────────┐
│   Mobile App    │    │   Web Dashboard │
│  (React Native) │    │    (Next.js)    │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
            ┌────────▼────────┐
            │   API Gateway   │
            │     (Kong)      │
            └────────┬────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
   ┌────▼───┐  ┌────▼───┐  ┌────▼───┐
   │ Auth   │  │ User   │  │ Gym    │
   │Service │  │Service │  │Service │
   └────┬───┘  └────┬───┘  └────┬───┘
        │           │           │
   ┌────▼───┐  ┌────▼───┐  ┌────▼───┐
   │Workout │  │Progress│  │Schedule│
   │Service │  │Service │  │Service │
   └────┬───┘  └────┬───┘  └────┬───┘
        │           │           │
        └───────────┼───────────┘
                    │
            ┌───────▼───────┐
            │  PostgreSQL   │
            │   + Redis     │
            └───────────────┘
```

---

## **4. Modelo de Dados**

### **4.1 Entidades Principais**

#### **Users (Usuários)**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('personal_trainer', 'client') NOT NULL,
  profile_id UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### **Personal Trainers**
```sql
CREATE TABLE personal_trainers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  cref VARCHAR(20),
  specialties TEXT[],
  bio TEXT,
  avatar_url VARCHAR(500),
  phone VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### **Clients**
```sql
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  personal_trainer_id UUID REFERENCES personal_trainers(id),
  name VARCHAR(255) NOT NULL,
  birth_date DATE,
  gender ENUM('male', 'female', 'other'),
  phone VARCHAR(20),
  emergency_contact JSONB,
  medical_history JSONB,
  goals TEXT[],
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### **Gyms (Academias)**
```sql
CREATE TABLE gyms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  address JSONB,
  equipment_list TEXT[],
  created_by UUID REFERENCES personal_trainers(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### **Workouts (Treinos)**
```sql
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id),
  gym_id UUID REFERENCES gyms(id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  exercises JSONB NOT NULL,
  status ENUM('draft', 'active', 'completed') DEFAULT 'draft',
  scheduled_date DATE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **4.2 Relacionamentos**

- **1:N** - Personal Trainer : Clients
- **N:M** - Personal Trainers : Gyms
- **1:N** - Client : Workouts
- **1:N** - Gym : Workouts
- **1:N** - Client : Progress Records

---

## **5. APIs e Endpoints**

### **5.1 Autenticação**
```
POST /api/auth/login
POST /api/auth/register
POST /api/auth/refresh
POST /api/auth/logout
POST /api/auth/forgot-password
POST /api/auth/reset-password
```

### **5.2 Personal Trainers**
```
GET    /api/personal-trainers/profile
PUT    /api/personal-trainers/profile
GET    /api/personal-trainers/clients
POST   /api/personal-trainers/clients
GET    /api/personal-trainers/gyms
POST   /api/personal-trainers/gyms
```

### **5.3 Treinos**
```
GET    /api/workouts
POST   /api/workouts
GET    /api/workouts/:id
PUT    /api/workouts/:id
DELETE /api/workouts/:id
POST   /api/workouts/:id/complete
```

### **5.4 Academias**
```
GET    /api/gyms
POST   /api/gyms
GET    /api/gyms/:id
PUT    /api/gyms/:id
GET    /api/gyms/:id/equipment
PUT    /api/gyms/:id/equipment
```

---

## **6. Segurança**

### **6.1 Autenticação e Autorização**

- **JWT Tokens:** Access token (15min) + Refresh token (7 dias)
- **RBAC:** Role-Based Access Control
- **Rate Limiting:** 100 requests/minuto por usuário
- **CORS:** Configuração restritiva

### **6.2 Proteção de Dados**

- **Criptografia:** Senhas com bcrypt (12 rounds)
- **HTTPS:** Obrigatório em produção
- **Sanitização:** Validação e sanitização de inputs
- **LGPD:** Compliance com lei de proteção de dados

### **6.3 Variáveis de Ambiente**

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/fitcoach
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-super-secret-key
JWT_REFRESH_SECRET=your-refresh-secret-key

# AWS
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=fitcoach-uploads

# External Services
SENDGRID_API_KEY=your-sendgrid-key
FCM_SERVER_KEY=your-fcm-key

# Environment
NODE_ENV=production
PORT=3000
```

---

## **7. Performance e Escalabilidade**

### **7.1 Otimizações**

- **Database Indexing:** Índices em campos frequentemente consultados
- **Query Optimization:** N+1 queries prevention
- **Caching Strategy:** Redis para dados frequentes
- **Image Optimization:** Compressão e redimensionamento automático
- **CDN:** CloudFront para assets estáticos

### **7.2 Monitoramento**

- **Health Checks:** Endpoints de saúde para cada serviço
- **Metrics:** Tempo de resposta, throughput, error rate
- **Alerts:** Notificações para problemas críticos
- **Logging:** Logs estruturados com correlação ID

---

## **8. Plano de Deploy**

### **8.1 Ambientes**

1. **Development:** Local com Docker Compose
2. **Staging:** Railway ou AWS (ambiente de testes)
3. **Production:** AWS com alta disponibilidade

### **8.2 Pipeline CI/CD**

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test
      
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          docker build -t fitcoach-api .
          docker push $REGISTRY/fitcoach-api
          kubectl apply -f k8s/
```

---

## **9. Considerações Futuras**

### **9.1 Integrações Planejadas**

- **Wearables:** Apple Health, Google Fit, Fitbit
- **Pagamentos:** Stripe, PagSeguro
- **Nutrição:** MyFitnessPal API
- **Mapas:** Google Maps para localização de academias

### **9.2 Evolução da Arquitetura**

- **Machine Learning:** Recomendações inteligentes de exercícios
- **Real-time:** WebSockets para chat em tempo real
- **Offline-first:** Sincronização robusta para uso offline
- **Multi-tenant:** Suporte a redes de academias

---

## **10. Riscos Técnicos e Mitigações**

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|----------|
| Complexidade da inteligência logística | Alta | Alto | Implementação incremental, começar simples |
| Performance em dispositivos antigos | Média | Médio | Otimização de bundle, lazy loading |
| Sincronização offline | Alta | Alto | Implementar conflict resolution robusto |
| Escalabilidade do banco | Baixa | Alto | Read replicas, particionamento |

---

**Aprovações:**
- [ ] Tech Lead
- [ ] DevOps Engineer
- [ ] Security Engineer
- [ ] Product Owner

**Histórico de Versões:**
- v1.0 - Janeiro 2025 - Versão inicial da arquitetura