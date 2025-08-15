# **Plano de Testes e Critérios de Aceitação**
# **FitCoach Pro - MVP**

**Versão:** 1.0  
**Data:** Janeiro 2025  
**Autor:** Arquiteto de Software  
**Status:** Draft  

---

## **1. Visão Geral**

### **1.1 Objetivos do Plano de Testes**
- Garantir qualidade e confiabilidade do MVP
- Validar todos os requisitos funcionais e não-funcionais
- Assegurar experiência de usuário consistente
- Verificar segurança e proteção de dados
- Confirmar performance adequada

### **1.2 Escopo dos Testes**
- **Incluído:** Todas as funcionalidades do MVP, APIs, interfaces mobile e web
- **Excluído:** Funcionalidades pós-MVP, integrações futuras

### **1.3 Estratégia de Testes**
- **Pirâmide de Testes:** 70% unitários, 20% integração, 10% E2E
- **Shift-Left:** Testes desde o início do desenvolvimento
- **Automação:** Máxima automação possível
- **Continuous Testing:** Integração com CI/CD

---

## **2. Tipos de Testes**

### **2.1 Testes Unitários**
**Objetivo:** Validar componentes individuais  
**Cobertura Mínima:** 80%  
**Ferramentas:** Jest, React Native Testing Library  

#### **2.1.1 Backend - Testes de Serviços**
```typescript
// Exemplo: AuthService.test.ts
describe('AuthService', () => {
  describe('register', () => {
    it('should create user with valid data', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'SecurePass123',
        role: 'personal_trainer'
      };
      
      const result = await authService.register(userData);
      
      expect(result.success).toBe(true);
      expect(result.user.email).toBe(userData.email);
      expect(result.user.emailVerified).toBe(false);
    });
    
    it('should reject duplicate email', async () => {
      // Criar usuário primeiro
      await authService.register({
        email: 'duplicate@example.com',
        password: 'SecurePass123',
        role: 'personal_trainer'
      });
      
      // Tentar criar novamente
      const result = await authService.register({
        email: 'duplicate@example.com',
        password: 'AnotherPass123',
        role: 'client'
      });
      
      expect(result.success).toBe(false);
      expect(result.error).toBe('EMAIL_ALREADY_EXISTS');
    });
  });
});
```

#### **2.1.2 Frontend - Testes de Componentes**
```typescript
// Exemplo: LoginScreen.test.tsx
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import LoginScreen from '../LoginScreen';

describe('LoginScreen', () => {
  it('should display validation errors for invalid inputs', async () => {
    const { getByTestId, getByText } = render(<LoginScreen />);
    
    const emailInput = getByTestId('email-input');
    const passwordInput = getByTestId('password-input');
    const loginButton = getByTestId('login-button');
    
    fireEvent.changeText(emailInput, 'invalid-email');
    fireEvent.changeText(passwordInput, '123');
    fireEvent.press(loginButton);
    
    await waitFor(() => {
      expect(getByText('Email inválido')).toBeTruthy();
      expect(getByText('Senha deve ter pelo menos 8 caracteres')).toBeTruthy();
    });
  });
});
```

### **2.2 Testes de Integração**
**Objetivo:** Validar interação entre componentes  
**Escopo:** APIs, banco de dados, serviços externos  

#### **2.2.1 Testes de API**
```typescript
// Exemplo: workout.integration.test.ts
describe('Workout API Integration', () => {
  let authToken: string;
  let clientId: string;
  let gymId: string;
  
  beforeAll(async () => {
    // Setup: criar personal trainer, cliente e academia
    const trainer = await createTestPersonalTrainer();
    authToken = await getAuthToken(trainer.email);
    
    const client = await createTestClient(trainer.id);
    clientId = client.id;
    
    const gym = await createTestGym(trainer.id);
    gymId = gym.id;
  });
  
  it('should create workout with intelligent suggestions', async () => {
    const workoutData = {
      clientId,
      gymId,
      name: 'Treino de Peito',
      objective: 'hypertrophy',
      targetMuscles: ['chest', 'triceps'],
      duration: 60
    };
    
    const response = await request(app)
      .post('/api/workouts')
      .set('Authorization', `Bearer ${authToken}`)
      .send(workoutData)
      .expect(201);
    
    expect(response.body.workout.exercises).toHaveLength(4);
    expect(response.body.workout.exercises[0].equipment).toContain('bench');
    expect(response.body.suggestedAlternatives).toBeDefined();
  });
});
```

### **2.3 Testes End-to-End (E2E)**
**Objetivo:** Validar fluxos completos do usuário  
**Ferramentas:** Detox (React Native), Playwright (Web)  

#### **2.3.1 Fluxo Crítico - Criação de Treino**
```typescript
// Exemplo: workout-creation.e2e.ts
describe('Workout Creation Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
    await loginAsPersonalTrainer();
  });
  
  it('should create workout with gym equipment adaptation', async () => {
    // 1. Navegar para lista de clientes
    await element(by.id('clients-tab')).tap();
    
    // 2. Selecionar cliente
    await element(by.id('client-item-0')).tap();
    
    // 3. Criar novo treino
    await element(by.id('create-workout-button')).tap();
    
    // 4. Selecionar academia
    await element(by.id('gym-selector')).tap();
    await element(by.text('Academia Teste')).tap();
    
    // 5. Definir objetivo
    await element(by.id('objective-selector')).tap();
    await element(by.text('Hipertrofia')).tap();
    
    // 6. Verificar sugestões inteligentes
    await waitFor(element(by.id('exercise-suggestions'))).toBeVisible();
    
    // 7. Aceitar sugestões
    await element(by.id('accept-suggestions-button')).tap();
    
    // 8. Salvar treino
    await element(by.id('save-workout-button')).tap();
    
    // 9. Verificar sucesso
    await expect(element(by.text('Treino criado com sucesso!'))).toBeVisible();
  });
});
```

### **2.4 Testes de Performance**
**Objetivo:** Validar tempos de resposta e throughput  
**Ferramentas:** Artillery, K6  

#### **2.4.1 Teste de Carga - API**
```yaml
# artillery-config.yml
config:
  target: 'https://api.fitcoach.com'
  phases:
    - duration: 60
      arrivalRate: 10
    - duration: 120
      arrivalRate: 50
    - duration: 60
      arrivalRate: 100
  processor: './test-functions.js'

scenarios:
  - name: 'Workout Creation Load Test'
    weight: 70
    flow:
      - post:
          url: '/api/auth/login'
          json:
            email: '{{ $randomEmail() }}'
            password: 'TestPass123'
          capture:
            - json: '$.token'
              as: 'authToken'
      - post:
          url: '/api/workouts'
          headers:
            Authorization: 'Bearer {{ authToken }}'
          json:
            clientId: '{{ $randomUUID() }}'
            gymId: '{{ $randomUUID() }}'
            name: 'Load Test Workout'
            objective: 'hypertrophy'
```

### **2.5 Testes de Segurança**
**Objetivo:** Validar proteção contra vulnerabilidades  
**Ferramentas:** OWASP ZAP, Snyk  

#### **2.5.1 Testes de Autenticação**
```typescript
describe('Security Tests', () => {
  describe('Authentication', () => {
    it('should reject requests without valid token', async () => {
      const response = await request(app)
        .get('/api/clients')
        .expect(401);
      
      expect(response.body.error).toBe('UNAUTHORIZED');
    });
    
    it('should reject expired tokens', async () => {
      const expiredToken = generateExpiredToken();
      
      const response = await request(app)
        .get('/api/clients')
        .set('Authorization', `Bearer ${expiredToken}`)
        .expect(401);
      
      expect(response.body.error).toBe('TOKEN_EXPIRED');
    });
    
    it('should implement rate limiting', async () => {
      const requests = Array(6).fill(null).map(() => 
        request(app)
          .post('/api/auth/login')
          .send({ email: 'test@example.com', password: 'wrong' })
      );
      
      const responses = await Promise.all(requests);
      const lastResponse = responses[responses.length - 1];
      
      expect(lastResponse.status).toBe(429);
      expect(lastResponse.body.error).toBe('RATE_LIMIT_EXCEEDED');
    });
  });
});
```

---

## **3. Critérios de Aceitação por Funcionalidade**

### **3.1 RF001 - Sistema de Autenticação**

#### **3.1.1 Registro de Personal Trainer**
**Cenário:** Personal trainer se registra com dados válidos  
**Dado:** Usuário acessa tela de registro  
**Quando:** Preenche todos os campos obrigatórios com dados válidos  
**Então:** 
- ✅ Conta é criada com sucesso
- ✅ Email de confirmação é enviado
- ✅ Usuário é redirecionado para tela de confirmação
- ✅ Senha é criptografada no banco

**Cenário:** Tentativa de registro com email duplicado  
**Dado:** Email já existe no sistema  
**Quando:** Usuário tenta se registrar com mesmo email  
**Então:**
- ✅ Erro é exibido: "Email já cadastrado"
- ✅ Registro não é completado
- ✅ Sugestão de login é oferecida

#### **3.1.2 Login**
**Cenário:** Login com credenciais válidas  
**Dado:** Usuário possui conta ativa e confirmada  
**Quando:** Insere email e senha corretos  
**Então:**
- ✅ Login é realizado com sucesso
- ✅ Token JWT é gerado
- ✅ Usuário é redirecionado para dashboard
- ✅ Última data de login é atualizada

### **3.2 RF002 - Inteligência Logística**

#### **3.2.1 Cadastro de Academia**
**Cenário:** Personal trainer cadastra nova academia  
**Dado:** Personal trainer está logado  
**Quando:** Preenche dados da academia e seleciona equipamentos  
**Então:**
- ✅ Academia é salva no banco de dados
- ✅ Equipamentos são associados à academia
- ✅ Academia aparece na lista de opções
- ✅ Validação de campos obrigatórios funciona

#### **3.2.2 Criação de Treino Inteligente**
**Cenário:** Criação de treino com sugestões baseadas em equipamentos  
**Dado:** Academia com equipamentos cadastrados  
**Quando:** Personal trainer cria treino selecionando academia e objetivo  
**Então:**
- ✅ Sistema sugere exercícios compatíveis com equipamentos
- ✅ Exercícios são filtrados por objetivo
- ✅ Alternativas são oferecidas quando necessário
- ✅ Treino pode ser personalizado manualmente

### **3.3 RF003 - Gestão de Clientes**

#### **3.3.1 Cadastro de Cliente**
**Cenário:** Personal trainer cadastra novo cliente  
**Dado:** Personal trainer está logado  
**Quando:** Preenche formulário completo de cliente  
**Então:**
- ✅ Cliente é salvo com todos os dados
- ✅ Anamnese é armazenada de forma segura
- ✅ Fotos são opcionais e requerem consentimento
- ✅ Dados médicos são criptografados

#### **3.3.2 Acompanhamento de Progresso**
**Cenário:** Visualização de progresso do cliente  
**Dado:** Cliente com histórico de avaliações  
**Quando:** Personal trainer acessa dashboard do cliente  
**Então:**
- ✅ Gráficos de evolução são exibidos
- ✅ Comparativo de fotos funciona
- ✅ Métricas são calculadas corretamente
- ✅ Relatório pode ser exportado

---

## **4. Testes de Usabilidade**

### **4.1 Cenários de Teste**

#### **4.1.1 Primeiro Uso - Personal Trainer**
**Objetivo:** Validar onboarding e facilidade de uso inicial  
**Participantes:** 5 personal trainers sem experiência com o app  
**Tarefas:**
1. Registrar-se no aplicativo
2. Cadastrar primeira academia
3. Adicionar primeiro cliente
4. Criar primeiro treino

**Métricas de Sucesso:**
- ✅ 80% completam todas as tarefas sem ajuda
- ✅ Tempo médio < 15 minutos
- ✅ SUS Score > 70
- ✅ 0 erros críticos

#### **4.1.2 Uso Diário - Criação de Treino**
**Objetivo:** Validar eficiência do fluxo principal  
**Participantes:** 5 personal trainers experientes  
**Tarefas:**
1. Criar treino para cliente existente
2. Adaptar treino para academia diferente
3. Personalizar exercícios sugeridos

**Métricas de Sucesso:**
- ✅ Tempo médio < 5 minutos
- ✅ 90% consideram mais rápido que método atual
- ✅ Inteligência logística é percebida como útil

### **4.2 Testes de Acessibilidade**

#### **4.2.1 Conformidade WCAG 2.1**
- ✅ Contraste mínimo 4.5:1
- ✅ Navegação por teclado funcional
- ✅ Screen reader compatibility
- ✅ Textos alternativos em imagens
- ✅ Foco visual claro

#### **4.2.2 Testes com Usuários com Deficiência**
- ✅ 2 usuários com deficiência visual
- ✅ 2 usuários com deficiência motora
- ✅ Feedback incorporado antes do lançamento

---

## **5. Ambiente de Testes**

### **5.1 Configuração de Ambientes**

#### **5.1.1 Ambiente de Desenvolvimento**
```yaml
# docker-compose.test.yml
version: '3.8'
services:
  postgres-test:
    image: postgres:15
    environment:
      POSTGRES_DB: fitcoach_test
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_pass
    ports:
      - "5433:5432"
  
  redis-test:
    image: redis:7-alpine
    ports:
      - "6380:6379"
  
  api-test:
    build: .
    environment:
      NODE_ENV: test
      DATABASE_URL: postgresql://test_user:test_pass@postgres-test:5432/fitcoach_test
      REDIS_URL: redis://redis-test:6379
    depends_on:
      - postgres-test
      - redis-test
```

#### **5.1.2 Dados de Teste**
```typescript
// test-data/seeds.ts
export const testPersonalTrainers = [
  {
    name: 'João Silva',
    email: 'joao@test.com',
    cref: 'CREF123456-SP',
    specialties: ['Musculação', 'Funcional']
  },
  {
    name: 'Maria Santos',
    email: 'maria@test.com',
    cref: 'CREF789012-RJ',
    specialties: ['Pilates', 'Yoga']
  }
];

export const testGyms = [
  {
    name: 'Academia Completa',
    equipment: ['bench_press', 'leg_press', 'treadmill', 'dumbbells'],
    address: {
      street: 'Rua Teste, 123',
      city: 'São Paulo',
      state: 'SP'
    }
  }
];
```

### **5.2 Automação de Testes**

#### **5.2.1 Pipeline CI/CD**
```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:unit
      - run: npm run test:coverage
      
  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run test:integration
      
  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run build
      - run: npm run test:e2e
```

---

## **6. Métricas de Qualidade**

### **6.1 Cobertura de Código**
- **Meta:** 80% cobertura geral
- **Crítico:** 90% cobertura em lógica de negócio
- **Aceitável:** 70% cobertura em UI components

### **6.2 Métricas de Performance**
- **API Response Time:** < 2s para 95% das requests
- **App Launch Time:** < 3s em dispositivos médios
- **Memory Usage:** < 150MB em uso normal
- **Battery Impact:** Classificação "Low" na App Store

### **6.3 Métricas de Qualidade**
- **Bug Density:** < 1 bug por 1000 linhas de código
- **Critical Bugs:** 0 em produção
- **Test Execution Time:** < 10 minutos para suite completa
- **Flaky Tests:** < 5% de instabilidade

---

## **7. Critérios de Release**

### **7.1 Critérios Obrigatórios (Go/No-Go)**
- ✅ Todos os testes críticos passando
- ✅ Cobertura de código > 80%
- ✅ 0 vulnerabilidades de segurança críticas
- ✅ Performance dentro dos SLAs
- ✅ Testes de usabilidade aprovados
- ✅ Backup e recovery testados

### **7.2 Critérios de Qualidade**
- ✅ SUS Score > 70 nos testes de usabilidade
- ✅ Tempo de resposta < 2s para operações críticas
- ✅ Taxa de sucesso > 99% nos testes E2E
- ✅ Conformidade LGPD validada
- ✅ Documentação técnica completa

### **7.3 Plano de Rollback**
- **Trigger:** Bugs críticos ou performance degradada
- **Tempo:** < 15 minutos para rollback completo
- **Validação:** Testes automatizados pós-rollback
- **Comunicação:** Notificação automática para stakeholders

---

## **8. Monitoramento Pós-Deploy**

### **8.1 Testes de Fumaça (Smoke Tests)**
```typescript
// smoke-tests.ts
describe('Production Smoke Tests', () => {
  it('should have healthy API endpoints', async () => {
    const healthCheck = await fetch('/api/health');
    expect(healthCheck.status).toBe(200);
    
    const authEndpoint = await fetch('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email: 'test', password: 'test' })
    });
    expect(authEndpoint.status).toBe(400); // Bad request, not server error
  });
  
  it('should have database connectivity', async () => {
    const dbHealth = await fetch('/api/health/database');
    expect(dbHealth.status).toBe(200);
  });
});
```

### **8.2 Monitoramento Contínuo**
- **Synthetic Tests:** Executados a cada 5 minutos
- **Real User Monitoring:** Métricas de performance real
- **Error Tracking:** Alertas automáticos para erros
- **Performance Monitoring:** Dashboards em tempo real

---

## **9. Relatórios de Teste**

### **9.1 Template de Relatório**
```markdown
# Relatório de Execução de Testes
**Data:** [DATA]
**Versão:** [VERSÃO]
**Ambiente:** [AMBIENTE]

## Resumo Executivo
- **Total de Testes:** [NÚMERO]
- **Testes Passaram:** [NÚMERO] ([PERCENTUAL]%)
- **Testes Falharam:** [NÚMERO] ([PERCENTUAL]%)
- **Cobertura de Código:** [PERCENTUAL]%
- **Duração Total:** [TEMPO]

## Detalhes por Categoria
### Testes Unitários
- Executados: [NÚMERO]
- Sucesso: [PERCENTUAL]%
- Falhas Críticas: [NÚMERO]

### Testes de Integração
- Executados: [NÚMERO]
- Sucesso: [PERCENTUAL]%
- Falhas Críticas: [NÚMERO]

## Bugs Encontrados
| ID | Severidade | Descrição | Status |
|----|------------|-----------|--------|
| BUG-001 | Alta | [Descrição] | Aberto |

## Recomendações
- [Recomendação 1]
- [Recomendação 2]
```

### **9.2 Dashboards de Qualidade**
- **Grafana Dashboard:** Métricas em tempo real
- **SonarQube:** Qualidade de código
- **TestRail:** Gestão de casos de teste
- **Allure:** Relatórios visuais de execução

---

**Aprovações:**
- [ ] QA Lead
- [ ] Tech Lead
- [ ] Product Owner
- [ ] DevOps Engineer

**Histórico de Versões:**
- v1.0 - Janeiro 2025 - Plano inicial de testes para MVP