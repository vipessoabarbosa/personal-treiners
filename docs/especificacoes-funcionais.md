# **Especificações Funcionais Detalhadas**
# **FitCoach Pro - MVP**

**Versão:** 1.0  
**Data:** Janeiro 2025  
**Autor:** Arquiteto de Software  
**Status:** Draft  

---

## **1. Visão Geral**

### **1.1 Escopo do Documento**
Este documento detalha as especificações funcionais para o MVP do FitCoach Pro, incluindo:
- Fluxos de usuário detalhados
- Regras de negócio específicas
- Critérios de aceitação técnicos
- Validações e tratamento de erros
- Interfaces e integrações

### **1.2 Convenções**
- **[RF-XXX]** = Requisito Funcional
- **[RN-XXX]** = Regra de Negócio
- **[CA-XXX]** = Critério de Aceitação
- **[VL-XXX]** = Validação
- **[ER-XXX]** = Tratamento de Erro

---

## **2. RF001 - Sistema de Autenticação**

### **2.1 Descrição Geral**
Sistema completo de autenticação e autorização para personal trainers e clientes.

### **2.2 Fluxos de Usuário**

#### **2.2.1 Fluxo de Registro - Personal Trainer**
```
1. Usuário acessa tela de registro
2. Seleciona tipo "Personal Trainer"
3. Preenche dados básicos:
   - Nome completo
   - Email
   - Senha
   - Confirmação de senha
   - Telefone
4. Preenche dados profissionais:
   - CREF (opcional)
   - Especialidades
   - Bio profissional
5. Aceita termos de uso e política de privacidade
6. Clica em "Criar Conta"
7. Recebe email de confirmação
8. Confirma email e é redirecionado para onboarding
```

#### **2.2.2 Fluxo de Login**
```
1. Usuário acessa tela de login
2. Insere email e senha
3. Clica em "Entrar"
4. Sistema valida credenciais
5. Redireciona para dashboard apropriado
```

### **2.3 Regras de Negócio**

**[RN-001]** Email deve ser único no sistema  
**[RN-002]** Senha deve ter mínimo 8 caracteres, incluindo maiúscula, minúscula e número  
**[RN-003]** CREF deve seguir formato brasileiro (CREF + número + estado)  
**[RN-004]** Conta fica inativa até confirmação do email  
**[RN-005]** Máximo 5 tentativas de login por hora por IP  

### **2.4 Validações**

**[VL-001]** Email: formato válido, máximo 255 caracteres  
**[VL-002]** Senha: mínimo 8, máximo 128 caracteres  
**[VL-003]** Nome: mínimo 2, máximo 100 caracteres  
**[VL-004]** Telefone: formato brasileiro válido  
**[VL-005]** CREF: formato CREF000000-UF (opcional)  

### **2.5 Critérios de Aceitação**

**[CA-001]** Personal trainer consegue se registrar com dados válidos  
**[CA-002]** Sistema impede registro com email duplicado  
**[CA-003]** Email de confirmação é enviado em até 30 segundos  
**[CA-004]** Login funciona após confirmação do email  
**[CA-005]** Senha é criptografada no banco de dados  
**[CA-006]** Rate limiting funciona após 5 tentativas  

---

## **3. RF002 - Inteligência Logística**

### **3.1 Descrição Geral**
Sistema que adapta treinos baseado nos equipamentos disponíveis em cada academia.

### **3.2 Fluxos de Usuário**

#### **3.2.1 Cadastro de Academia**
```
1. Personal acessa "Minhas Academias"
2. Clica em "Adicionar Academia"
3. Preenche dados da academia:
   - Nome
   - Endereço completo
   - Telefone (opcional)
   - Observações (opcional)
4. Seleciona equipamentos disponíveis por categoria:
   - Cardio (esteira, bike, elíptico, etc.)
   - Musculação (supino, leg press, puxador, etc.)
   - Funcional (TRX, kettlebell, medicine ball, etc.)
   - Livre (halteres, barras, anilhas, etc.)
5. Salva academia
6. Academia fica disponível para seleção em treinos
```

#### **3.2.2 Criação de Treino Inteligente**
```
1. Personal seleciona cliente
2. Escolhe academia onde será o treino
3. Sistema carrega equipamentos disponíveis
4. Personal define:
   - Objetivo do treino (força, hipertrofia, resistência, etc.)
   - Grupos musculares alvo
   - Duração estimada
   - Nível de dificuldade
5. Sistema sugere exercícios baseados em:
   - Equipamentos disponíveis
   - Objetivo selecionado
   - Histórico do cliente
6. Personal pode:
   - Aceitar sugestões
   - Modificar exercícios
   - Adicionar exercícios manuais
   - Ajustar séries/repetições/carga
7. Salva treino e envia para cliente
```

### **3.3 Regras de Negócio**

**[RN-006]** Cada academia deve ter pelo menos 5 equipamentos cadastrados  
**[RN-007]** Treino deve ter mínimo 3 exercícios  
**[RN-008]** Sistema prioriza exercícios compostos quando possível  
**[RN-009]** Sugestões respeitam limitações físicas do cliente  
**[RN-010]** Exercícios alternativos são oferecidos quando equipamento não disponível  

### **3.4 Algoritmo de Sugestão**

```typescript
interface SuggestionAlgorithm {
  // Entrada
  client: Client;
  gym: Gym;
  objective: WorkoutObjective;
  targetMuscles: MuscleGroup[];
  duration: number;
  
  // Processo
  1. Filtrar exercícios por equipamentos disponíveis
  2. Aplicar filtros de limitações do cliente
  3. Priorizar por objetivo (força/hipertrofia/resistência)
  4. Balancear grupos musculares
  5. Considerar tempo disponível
  6. Aplicar progressão baseada no histórico
  
  // Saída
  suggestedExercises: Exercise[];
  alternativeExercises: Exercise[];
}
```

### **3.5 Critérios de Aceitação**

**[CA-007]** Personal consegue cadastrar academia com equipamentos  
**[CA-008]** Sistema sugere exercícios baseados nos equipamentos  
**[CA-009]** Sugestões respeitam objetivo do treino  
**[CA-010]** Exercícios alternativos são oferecidos  
**[CA-011]** Treino pode ser salvo e editado posteriormente  

---

## **4. RF003 - Gestão de Clientes**

### **4.1 Descrição Geral**
Sistema completo para cadastro, avaliação e acompanhamento de clientes.

### **4.2 Fluxos de Usuário**

#### **4.2.1 Cadastro de Cliente**
```
1. Personal acessa "Meus Clientes"
2. Clica em "Adicionar Cliente"
3. Preenche dados pessoais:
   - Nome completo
   - Data de nascimento
   - Gênero
   - Telefone
   - Email (opcional)
4. Preenche dados de emergência:
   - Contato de emergência
   - Telefone de emergência
5. Realiza anamnese:
   - Histórico médico
   - Medicamentos em uso
   - Lesões anteriores
   - Limitações físicas
   - Experiência com exercícios
6. Define objetivos:
   - Objetivo principal
   - Objetivos secundários
   - Meta de prazo
   - Disponibilidade semanal
7. Avaliação física inicial:
   - Medidas corporais
   - Fotos (opcional)
   - Testes funcionais
8. Salva cliente
```

#### **4.2.2 Acompanhamento de Progresso**
```
1. Personal acessa perfil do cliente
2. Visualiza dashboard com:
   - Gráfico de evolução de peso
   - Gráfico de evolução de medidas
   - Comparativo de fotos
   - Histórico de treinos
   - Evolução de cargas
3. Pode adicionar nova avaliação:
   - Novas medidas
   - Novas fotos
   - Observações
4. Sistema gera relatório automático de progresso
```

### **4.3 Regras de Negócio**

**[RN-011]** Cliente deve ter pelo menos nome e data de nascimento  
**[RN-012]** Anamnese é obrigatória antes do primeiro treino  
**[RN-013]** Fotos são opcionais e requerem consentimento  
**[RN-014]** Dados médicos são confidenciais e criptografados  
**[RN-015]** Avaliação deve ser atualizada a cada 30 dias  

### **4.4 Estrutura de Dados - Anamnese**

```typescript
interface Anamnese {
  // Histórico Médico
  hasCardiacProblems: boolean;
  hasBloodPressureIssues: boolean;
  hasDiabetes: boolean;
  hasRespiratoryProblems: boolean;
  hasJointProblems: boolean;
  currentMedications: string[];
  
  // Histórico de Exercícios
  exerciseExperience: 'beginner' | 'intermediate' | 'advanced';
  previousInjuries: Injury[];
  currentLimitations: string[];
  
  // Estilo de Vida
  sleepHours: number;
  stressLevel: 1 | 2 | 3 | 4 | 5;
  smokingHabits: 'never' | 'former' | 'current';
  alcoholConsumption: 'never' | 'social' | 'regular';
  
  // Objetivos
  primaryGoal: Goal;
  secondaryGoals: Goal[];
  targetDate: Date;
  weeklyAvailability: number;
}
```

### **4.5 Critérios de Aceitação**

**[CA-012]** Personal consegue cadastrar cliente com dados completos  
**[CA-013]** Anamnese é salva de forma segura e criptografada  
**[CA-014]** Dashboard de progresso exibe gráficos corretos  
**[CA-015]** Fotos são armazenadas com segurança  
**[CA-016]** Relatório de progresso é gerado automaticamente  

---

## **5. RF004 - Sistema de Treinos**

### **5.1 Descrição Geral**
Sistema para criação, personalização e acompanhamento de treinos.

### **5.2 Estrutura de Treino**

```typescript
interface Workout {
  id: string;
  clientId: string;
  gymId: string;
  name: string;
  description?: string;
  objective: WorkoutObjective;
  estimatedDuration: number; // minutos
  difficulty: 1 | 2 | 3 | 4 | 5;
  exercises: WorkoutExercise[];
  notes?: string;
  status: 'draft' | 'active' | 'completed';
  scheduledDate?: Date;
  completedDate?: Date;
  createdAt: Date;
}

interface WorkoutExercise {
  exerciseId: string;
  order: number;
  sets: ExerciseSet[];
  restTime: number; // segundos
  notes?: string;
  equipment: Equipment[];
  muscleGroups: MuscleGroup[];
}

interface ExerciseSet {
  reps?: number;
  weight?: number;
  duration?: number; // segundos
  distance?: number; // metros
  completed: boolean;
  actualReps?: number;
  actualWeight?: number;
}
```

### **5.3 Biblioteca de Exercícios**

#### **5.3.1 Categorização**
- **Por Grupo Muscular:** Peito, Costas, Ombros, Bíceps, Tríceps, Pernas, Core
- **Por Equipamento:** Livre, Máquinas, Funcional, Cardio
- **Por Movimento:** Empurrar, Puxar, Agachar, Puxar do Chão
- **Por Objetivo:** Força, Hipertrofia, Resistência, Mobilidade

#### **5.3.2 Dados do Exercício**
```typescript
interface Exercise {
  id: string;
  name: string;
  description: string;
  instructions: string[];
  muscleGroups: MuscleGroup[];
  equipment: Equipment[];
  difficulty: 1 | 2 | 3 | 4 | 5;
  videoUrl?: string;
  imageUrls: string[];
  variations: ExerciseVariation[];
  contraindications: string[];
  tips: string[];
}
```

### **5.4 Regras de Negócio**

**[RN-016]** Treino deve ter entre 3 e 15 exercícios  
**[RN-017]** Cada exercício deve ter pelo menos 1 série  
**[RN-018]** Tempo de descanso deve ser entre 30s e 5min  
**[RN-019]** Carga deve ser progressiva ao longo das semanas  
**[RN-020]** Exercícios contraindícados não podem ser sugeridos  

### **5.5 Critérios de Aceitação**

**[CA-017]** Personal consegue criar treino com exercícios da biblioteca  
**[CA-018]** Sistema valida estrutura do treino antes de salvar  
**[CA-019]** Cliente consegue visualizar treino no app  
**[CA-020]** Progresso é registrado após execução  
**[CA-021]** Histórico de treinos é mantido  

---

## **6. RF005 - Dashboard e Relatórios**

### **6.1 Dashboard do Personal Trainer**

#### **6.1.1 Métricas Principais**
- Total de clientes ativos
- Treinos agendados hoje
- Treinos completados esta semana
- Taxa de aderência média dos clientes
- Receita mensal (futuro)

#### **6.1.2 Widgets**
```typescript
interface DashboardWidget {
  // Agenda do Dia
  todaySchedule: {
    client: Client;
    workout: Workout;
    time: Date;
    gym: Gym;
  }[];
  
  // Clientes Recentes
  recentClients: {
    client: Client;
    lastWorkout: Date;
    adherenceRate: number;
  }[];
  
  // Estatísticas
  stats: {
    totalClients: number;
    activeClients: number;
    completedWorkouts: number;
    averageAdherence: number;
  };
}
```

### **6.2 Dashboard do Cliente**

#### **6.2.1 Visão Geral**
- Próximo treino agendado
- Progresso semanal
- Evolução de peso/medidas
- Conquistas e badges

#### **6.2.2 Gráficos de Progresso**
- Evolução de peso corporal
- Evolução de medidas (cintura, braço, etc.)
- Progressão de cargas por exercício
- Frequência de treinos

### **6.3 Relatórios**

#### **6.3.1 Relatório de Progresso do Cliente**
```typescript
interface ProgressReport {
  period: DateRange;
  client: Client;
  
  // Métricas Físicas
  weightProgress: {
    initial: number;
    current: number;
    change: number;
    trend: 'up' | 'down' | 'stable';
  };
  
  // Métricas de Performance
  strengthProgress: {
    exercise: Exercise;
    initialLoad: number;
    currentLoad: number;
    improvement: number;
  }[];
  
  // Aderência
  adherence: {
    scheduledWorkouts: number;
    completedWorkouts: number;
    rate: number;
  };
  
  // Observações
  notes: string[];
  recommendations: string[];
}
```

### **6.4 Critérios de Aceitação**

**[CA-022]** Dashboard carrega em menos de 2 segundos  
**[CA-023]** Gráficos são responsivos e interativos  
**[CA-024]** Relatórios podem ser exportados em PDF  
**[CA-025]** Dados são atualizados em tempo real  

---

## **7. Tratamento de Erros**

### **7.1 Categorias de Erro**

#### **7.1.1 Erros de Validação**
**[ER-001]** Campos obrigatórios não preenchidos  
**[ER-002]** Formato de dados inválido  
**[ER-003]** Valores fora do range permitido  

#### **7.1.2 Erros de Negócio**
**[ER-004]** Email já cadastrado  
**[ER-005]** Cliente não encontrado  
**[ER-006]** Academia sem equipamentos suficientes  

#### **7.1.3 Erros de Sistema**
**[ER-007]** Falha na conexão com banco de dados  
**[ER-008]** Serviço indisponível  
**[ER-009]** Timeout na requisição  

### **7.2 Mensagens de Erro**

Todas as mensagens devem ser:
- Claras e em português
- Orientadas à ação
- Não técnicas para o usuário final
- Logadas com detalhes técnicos para debug

---

## **8. Integrações**

### **8.1 Integrações Internas**
- Auth Service ↔ User Service
- Workout Service ↔ Gym Service
- Progress Service ↔ Client Service
- Notification Service ↔ Todos os serviços

### **8.2 Integrações Externas (Futuras)**
- Google Maps API (localização de academias)
- SendGrid (emails transacionais)
- Firebase Cloud Messaging (push notifications)
- Cloudinary (processamento de imagens)

---

**Aprovações:**
- [ ] Product Owner
- [ ] Tech Lead
- [ ] UX Designer
- [ ] QA Lead

**Histórico de Versões:**
- v1.0 - Janeiro 2025 - Especificações iniciais do MVP