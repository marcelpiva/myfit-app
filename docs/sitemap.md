# MyFit App - Sitemap por Perfil de Usuário

Este documento apresenta a estrutura de navegação do aplicativo MyFit, organizada por perfil de usuário.

## Índice
1. [Fluxo de Autenticação](#1-fluxo-de-autenticação-comum-a-todos)
2. [Visão Student/Aluno](#2-visão-studentaluno)
3. [Visão Trainer/Coach](#3-visão-trainercoach)
4. [Visão Nutritionist](#4-visão-nutritionist)
5. [Visão Gym Owner/Admin](#5-visão-gym-owneradmin)
6. [Telas Compartilhadas](#6-telas-compartilhadas)

---

## 1. Fluxo de Autenticação (Comum a Todos)

```mermaid
flowchart TD
    subgraph auth["🔐 Autenticação"]
        Welcome["/\nWelcomePage"]
        Login["/login\nLoginPage"]
        Register["/register\nRegisterPage"]
        ForgotPwd["/forgot-password\nForgotPasswordPage"]
        OrgSelector["/org-selector\nOrgSelectorPage"]
        CreateOrg["/org/create\nCreateOrgPage"]
        JoinOrg["/org/join\nJoinOrgPage"]
    end

    Welcome --> Login
    Welcome --> Register
    Login --> ForgotPwd
    Login --> OrgSelector
    Register --> OrgSelector
    OrgSelector --> CreateOrg
    OrgSelector --> JoinOrg
    OrgSelector --> Home["/home\nHomePage"]

    style Welcome fill:#e1f5fe
    style Login fill:#e1f5fe
    style Register fill:#e1f5fe
    style ForgotPwd fill:#fff3e0
    style OrgSelector fill:#e8f5e9
    style CreateOrg fill:#e8f5e9
    style JoinOrg fill:#e8f5e9
    style Home fill:#f3e5f5
```

---

## 2. Visão Student/Aluno

O aluno acessa treinos, dieta, acompanha progresso e se comunica com profissionais.

```mermaid
flowchart TD
    subgraph nav["📱 Navegação Principal"]
        Home["/home\n🏠 Home"]
        Workouts["/workouts\n💪 Treinos"]
        Nutrition["/nutrition\n🥗 Dieta"]
        Progress["/progress\n📈 Progresso"]
        Chat["/chat\n💬 Chat"]
    end

    subgraph workouts_sub["Módulo Treinos"]
        WorkoutDetail["/workouts/:id\nDetalhes do Treino"]
        ActiveWorkout["/workouts/active/:id\nTreino Ativo"]
        Templates["/workouts/templates\nTemplates"]
        ProgramDetail["/programs/:id\nDetalhes Programa"]
    end

    subgraph nutrition_sub["Módulo Nutrição"]
        FoodSearch["/nutrition/search\nBuscar Alimento"]
        Barcode["/nutrition/barcode\nScanner Código"]
        RecentMeals["/nutrition/recent\nRefeições Recentes"]
        AISuggestion["/nutrition/ai-suggestion\nSugestão IA"]
        MealLog["/nutrition/meal-log\nRegistro Refeições"]
        NutritionSummary["/nutrition/summary\nResumo Nutricional"]
    end

    subgraph progress_sub["Módulo Progresso"]
        RegisterWeight["/progress/weight\nRegistrar Peso"]
        Measurements["/progress/measurements\nMedidas Corporais"]
        WeightGoal["/progress/goal\nMeta de Peso"]
        ProgressStats["/progress/stats\nEstatísticas"]
        PhotoComparison["/progress/photos/compare\nComparar Fotos"]
    end

    subgraph chat_sub["Módulo Chat"]
        TrainerChat["/trainer-chat\nChat com Trainer"]
        NutritionistChat["/nutritionist-chat\nChat com Nutricionista"]
    end

    Home --> Workouts
    Home --> Nutrition
    Home --> Progress
    Home --> Chat

    Workouts --> WorkoutDetail
    Workouts --> Templates
    WorkoutDetail --> ActiveWorkout
    Workouts --> ProgramDetail

    Nutrition --> FoodSearch
    Nutrition --> Barcode
    Nutrition --> RecentMeals
    Nutrition --> AISuggestion
    Nutrition --> MealLog
    Nutrition --> NutritionSummary

    Progress --> RegisterWeight
    Progress --> Measurements
    Progress --> WeightGoal
    Progress --> ProgressStats
    Progress --> PhotoComparison

    Chat --> TrainerChat
    Chat --> NutritionistChat

    style Home fill:#e3f2fd
    style Workouts fill:#fff3e0
    style Nutrition fill:#e8f5e9
    style Progress fill:#fce4ec
    style Chat fill:#f3e5f5
```

### Fluxo de Treino Ativo

```mermaid
flowchart LR
    subgraph workout_flow["🏋️ Fluxo de Treino"]
        Start["Iniciar Treino"]
        Active["Treino Ativo\n(Fullscreen)"]
        Exercise["Exercício\nAtual"]
        Rest["Descanso\nTimer"]
        Complete["Treino\nConcluído"]
    end

    Start --> Active
    Active --> Exercise
    Exercise --> Rest
    Rest --> Exercise
    Exercise --> Complete
    Complete --> Progress["📊 Progresso"]

    style Active fill:#ff9800
    style Complete fill:#4caf50
```

---

## 3. Visão Trainer/Coach

O Personal Trainer gerencia alunos, cria treinos e acompanha evolução.

```mermaid
flowchart TD
    subgraph nav["📱 Navegação Principal"]
        Home["/home\n🏠 Dashboard"]
        Students["/students\n👥 Alunos"]
        Workouts["/workouts\n💪 Treinos"]
        Schedule["/schedule\n📅 Agenda"]
        Chat["/chat\n💬 Chat"]
    end

    subgraph students_sub["Gestão de Alunos"]
        StudentWorkouts["/students/:id/workouts\nTreinos do Aluno"]
        StudentProgress["/students/:id/progress\nProgresso do Aluno"]
    end

    subgraph workouts_sub["Criação de Treinos"]
        TrainerPrograms["/trainer-programs\nMeus Programas"]
        ProgramWizard["/programs/wizard\nAssistente Programa"]
        WorkoutBuilder["/workouts/builder\nConstrutor Treino"]
        FromScratch["/workouts/from-scratch\nDo Zero"]
        WithAI["/workouts/with-ai\nCom IA"]
        WorkoutTemplates["/workouts/templates\nTemplates"]
        Progression["/workouts/progression\nProgressão"]
        ExerciseForm["/workouts/exercises/new\nNovo Exercício"]
    end

    subgraph schedule_sub["Agenda"]
        Appointments["Agendamentos"]
        Availability["Disponibilidade"]
    end

    Home --> Students
    Home --> Workouts
    Home --> Schedule
    Home --> Chat

    Students --> StudentWorkouts
    Students --> StudentProgress

    Workouts --> TrainerPrograms
    Workouts --> WorkoutBuilder
    TrainerPrograms --> ProgramWizard
    WorkoutBuilder --> FromScratch
    WorkoutBuilder --> WithAI
    WorkoutBuilder --> WorkoutTemplates
    WorkoutBuilder --> Progression
    WorkoutBuilder --> ExerciseForm

    Schedule --> Appointments
    Schedule --> Availability

    style Home fill:#e3f2fd
    style Students fill:#fff3e0
    style Workouts fill:#e8f5e9
    style Schedule fill:#fce4ec
    style Chat fill:#f3e5f5
```

### Fluxo de Criação de Treino

```mermaid
flowchart LR
    subgraph create_flow["✨ Criação de Treino"]
        Start["Novo Treino"]
        Choose{"Método"}
        Scratch["Do Zero"]
        AI["Com IA"]
        Template["Template"]
        Builder["Construtor"]
        Save["Salvar"]
        Assign["Atribuir\nao Aluno"]
    end

    Start --> Choose
    Choose --> |Manual| Scratch
    Choose --> |Assistido| AI
    Choose --> |Base| Template
    Scratch --> Builder
    AI --> Builder
    Template --> Builder
    Builder --> Save
    Save --> Assign

    style AI fill:#4caf50
    style Save fill:#2196f3
```

---

## 4. Visão Nutritionist

O Nutricionista gerencia pacientes e cria planos alimentares personalizados.

```mermaid
flowchart TD
    subgraph nav["📱 Navegação Principal"]
        Home["/home\n🏠 Dashboard"]
        Patients["/patients\n👥 Pacientes"]
        DietPlans["/diet-plans\n📋 Planos"]
        Nutrition["/nutrition\n🥗 Nutrição"]
        Chat["/chat\n💬 Chat"]
    end

    subgraph patients_sub["Gestão de Pacientes"]
        PatientDetail["/patients/:id/detail\nDetalhes Paciente"]
        PatientDietPlan["/patients/:id/diet-plan\nPlano do Paciente"]
    end

    subgraph plans_sub["Planos Alimentares"]
        DietPlanBuilder["/nutrition/diet-plan/builder\nConstrutor de Dieta"]
        NutritionBuilder["/nutrition/builder\nConstrutor Nutricional"]
    end

    subgraph tools_sub["Ferramentas"]
        FoodSearch["/nutrition/search\nBuscar Alimento"]
        AISuggestion["/nutrition/ai-suggestion\nSugestão IA"]
        NutritionSummary["/nutrition/summary\nAnálise Nutricional"]
    end

    Home --> Patients
    Home --> DietPlans
    Home --> Nutrition
    Home --> Chat

    Patients --> PatientDetail
    Patients --> PatientDietPlan
    PatientDetail --> PatientDietPlan

    DietPlans --> DietPlanBuilder
    DietPlans --> NutritionBuilder

    Nutrition --> FoodSearch
    Nutrition --> AISuggestion
    Nutrition --> NutritionSummary

    style Home fill:#e3f2fd
    style Patients fill:#fff3e0
    style DietPlans fill:#e8f5e9
    style Nutrition fill:#c8e6c9
    style Chat fill:#f3e5f5
```

### Fluxo de Criação de Plano Alimentar

```mermaid
flowchart LR
    subgraph diet_flow["🍽️ Criação de Plano"]
        Select["Selecionar\nPaciente"]
        Assess["Avaliação\nNutricional"]
        Calculate["Calcular\nMacros"]
        Build["Montar\nRefeições"]
        Review["Revisar\nPlano"]
        Assign["Atribuir\nao Paciente"]
    end

    Select --> Assess
    Assess --> Calculate
    Calculate --> Build
    Build --> Review
    Review --> Assign

    style Calculate fill:#4caf50
    style Assign fill:#2196f3
```

---

## 5. Visão Gym Owner/Admin

O proprietário/administrador da academia gerencia equipe, membros e finanças.

```mermaid
flowchart TD
    subgraph nav["📱 Navegação Principal"]
        Home["/gym-home\n🏠 Dashboard"]
        Staff["/staff\n👔 Equipe"]
        Members["/members\n👥 Membros"]
        Billing["/billing\n💰 Financeiro"]
        Settings["/gym-settings\n⚙️ Config"]
    end

    subgraph staff_sub["Gestão de Equipe"]
        TrainersManagement["/trainers-management\nPersonais"]
        StaffRoles["Funções e\nPermissões"]
    end

    subgraph members_sub["Gestão de Membros"]
        MemberDetail["Detalhes\nMembro"]
        MemberPlans["Planos do\nMembro"]
    end

    subgraph financial_sub["Financeiro"]
        BillingDashboard["/billing\nDashboard Financeiro"]
        Reports["/gym-reports\nRelatórios"]
        Payments["/payments\nPagamentos"]
    end

    subgraph settings_sub["Configurações"]
        GymSettings["/gym-settings\nConfig Academia"]
        GymReports["/gym-reports\nRelatórios"]
        Checkin["/checkin\nCheck-in Config"]
    end

    Home --> Staff
    Home --> Members
    Home --> Billing
    Home --> Settings

    Staff --> TrainersManagement
    Staff --> StaffRoles

    Members --> MemberDetail
    Members --> MemberPlans

    Billing --> BillingDashboard
    Billing --> Reports
    Billing --> Payments

    Settings --> GymSettings
    Settings --> GymReports
    Settings --> Checkin

    style Home fill:#e3f2fd
    style Staff fill:#fff3e0
    style Members fill:#e8f5e9
    style Billing fill:#fff9c4
    style Settings fill:#f3e5f5
```

### Sistema de Check-in

```mermaid
flowchart LR
    subgraph checkin_flow["🎫 Sistema Check-in"]
        Config["Configurar\nCheck-in"]
        QRGen["/checkin/qr-generator\nGerar QR"]
        Smart["/checkin/smart\nSmart Check-in"]
        Scanner["/checkin/qr-scanner\nScanner"]
        History["/checkin/history\nHistórico"]
    end

    Config --> QRGen
    Config --> Smart
    Scanner --> History
    Smart --> History

    style QRGen fill:#4caf50
    style Smart fill:#2196f3
```

---

## 6. Telas Compartilhadas

Telas acessíveis por todos os perfis de usuário.

```mermaid
flowchart TD
    subgraph profile["👤 Perfil"]
        ProfilePage["/profile\nMeu Perfil"]
        EditProfile["/profile/edit\nEditar Perfil"]
    end

    subgraph settings["⚙️ Configurações"]
        SettingsPage["/settings\nConfigurações"]
        Notifications["/notifications\nNotificações"]
    end

    subgraph checkin["🎫 Check-in"]
        CheckinPage["/checkin\nCheck-in"]
        CheckinHistory["/checkin/history\nHistórico"]
        QRScanner["/checkin/qr-scanner\nScanner QR"]
        SmartCheckin["/checkin/smart\nSmart Check-in"]
    end

    subgraph extras["🎮 Extras"]
        Leaderboard["/leaderboard\nRanking"]
        Marketplace["/marketplace\nMarketplace"]
        Coach["/coach\nCoach Dashboard"]
    end

    subgraph legal["📄 Legal"]
        About["/about\nSobre"]
        Privacy["/privacy\nPrivacidade"]
        Terms["/terms\nTermos"]
        Help["/help\nAjuda"]
    end

    ProfilePage --> EditProfile
    SettingsPage --> Notifications
    CheckinPage --> CheckinHistory
    CheckinPage --> QRScanner
    CheckinPage --> SmartCheckin

    style ProfilePage fill:#e3f2fd
    style SettingsPage fill:#fff3e0
    style CheckinPage fill:#e8f5e9
    style Leaderboard fill:#fce4ec
    style About fill:#f5f5f5
```

### Marketplace

```mermaid
flowchart LR
    subgraph marketplace_flow["🛒 Marketplace"]
        Browse["/marketplace\nNavegar"]
        TemplateDetail["/marketplace/template/:id\nDetalhes"]
        Checkout["/marketplace/checkout\nCheckout"]
        Purchases["/marketplace/purchases\nMinhas Compras"]
    end

    Browse --> TemplateDetail
    TemplateDetail --> Checkout
    Checkout --> Purchases

    style Browse fill:#e3f2fd
    style Checkout fill:#4caf50
```

---

## Resumo de Rotas por Perfil

| Perfil | Rotas Exclusivas | Rotas Compartilhadas |
|--------|------------------|----------------------|
| **Student** | `/workouts/active/*`, progresso pessoal | Home, Workouts, Nutrition, Progress, Chat |
| **Trainer** | `/students/*`, `/trainer-programs`, `/schedule` | Workouts, Chat, Profile |
| **Coach** | Mesmas do Trainer | Mesmas do Trainer |
| **Nutritionist** | `/patients/*`, `/diet-plans` | Nutrition, Chat, Profile |
| **Gym Owner** | `/gym-*`, `/staff`, `/members`, `/billing` | Settings, Profile |
| **Gym Admin** | Mesmas do Gym Owner | Mesmas do Gym Owner |

---

## Legenda de Cores

| Cor | Significado |
|-----|-------------|
| 🔵 Azul claro | Dashboard/Home |
| 🟠 Laranja | Gestão de pessoas |
| 🟢 Verde | Treinos/Nutrição |
| 🌸 Rosa | Progresso/Agenda |
| 🟣 Roxo | Comunicação |
| 🟡 Amarelo | Financeiro |

---

*Documento gerado automaticamente. Última atualização: Janeiro 2026*
