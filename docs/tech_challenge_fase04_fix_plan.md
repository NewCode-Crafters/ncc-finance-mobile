# 📋 PLANO DE CORREÇÃO - TECH CHALLENGE FIAP FASE 04
**Projeto**: NCC Finance Mobile (Bytebank)  
**Data de Início**: 04 de janeiro de 2026  
**Referência**: `RELATORIO_VALIDACAO_TECNICA.md`

---

## 🎯 BASELINE DO PROJETO

### ✅ Estado Inicial (04/01/2026 - Pré-correção)

**Ambiente:**
```
Flutter 3.35.4 • channel stable
Framework • revision d693b4b9db (2025-09-16)
Dart 3.9.2 • DevTools 2.48.0
```

**Análise Estática (`flutter analyze`):**
- ✅ **Status**: 3 warnings (não-críticos)
- ⚠️ **Issues**:
  - `deprecated_member_use` em `TextFormField.value` (3 ocorrências)
  - Arquivos: 
    - `lib\presentation\screens\investments\create_investment_screen.dart:160:15`
    - `lib\presentation\screens\transactions\create_transaction_screen.dart:375:21`
    - `lib\presentation\screens\transactions\edit_transaction_screen.dart:134:15`
  - **Ação**: Substituir `value` por `initialValue` (quick fix)
  - **Tempo de execução**: 7.6s

**Testes Unitários (`flutter test`):**
- ✅ **Status**: 100% PASS
- ✅ **Total**: 134 testes executados
- ✅ **Tempo**: ~21 segundos
- ✅ **Cobertura**: Notifiers, Repositories, Use Cases, Mappers

**Dependências:**
- ✅ `flutter pub get` executado com sucesso
- ⚠️ 10 pacotes com versões mais recentes disponíveis (não-bloqueante)
- 📦 Principais: `provider ^6.1.5+1`, `get_it 7.7.0`, `firebase_core ^4.0.0`

**Arquitetura:**
- ✅ Clean Architecture (4 camadas: domain/application/infrastructure/presentation)
- ✅ Injeção de Dependência (GetIt)
- ✅ State Management (Provider + ChangeNotifier)

---

## 📊 RESUMO DE GAPS (do Relatório de Validação)

| Gap | Prioridade | Impacto | Esforço | Status |
|-----|-----------|---------|---------|--------|
| 1. Cache Local Ausente | 🔴 CRÍTICO | Alto | 5-6h | ⏳ Pendente |
| 2. flutter_secure_storage Ausente | 🟡 ALTO | Médio | 1-2h | ⏳ Pendente |
| 3. State Management Básico | 🟡 MÉDIO | Baixo | 6-10h | 📝 Planejado (Longo Prazo) |
| 4. Pré-carregamento de Dados | 🟢 BAIXO | Baixo | 30min | ⏳ Pendente |
| 5. Rotas com Lazy Loading | 🟢 BAIXO | Muito Baixo | 1-2h | 📝 Planejado (Futuro) |

---

## 🚀 PLANO DE EXECUÇÃO POR FASE

### 📌 **PRÉ-FASE: Correções Rápidas (30 min)** ✅ CONCLUÍDA
**Objetivo**: Limpar warnings do `flutter analyze`

- [x] **PR-1**: Fix `deprecated_member_use` warnings
  - Substituir `value` por `initialValue` nos 3 arquivos
  - Validação: `flutter analyze` deve retornar 0 issues ✅
  - Testes: `flutter test` deve continuar 100% pass ✅

---

### 🔒 **FASE 1: Segurança Imediata** (3-4 horas)
**Objetivo**: Adicionar armazenamento seguro e documentar estratégia de segurança

#### F1.1: Adicionar flutter_secure_storage
- [ ] Adicionar dependência `flutter_secure_storage: ^9.0.0` ao `pubspec.yaml`
- [ ] Criar `lib/infrastructure/services/secure_storage_service.dart`
  ```dart
  class SecureStorageService {
    final _storage = const FlutterSecureStorage();
    
    Future<void> save(String key, String value) async {
      await _storage.write(key: key, value: value);
    }
    
    Future<String?> read(String key) async {
      return await _storage.read(key: key);
    }
    
    Future<void> delete(String key) async {
      await _storage.delete(key: key);
    }
    
    Future<void> deleteAll() async {
      await _storage.deleteAll();
    }
  }
  ```
- [ ] Registrar `SecureStorageService` no DI (`lib/core/di/injection_container.dart`)
- [ ] Criar teste unitário: `test/infrastructure/services/secure_storage_service_test.dart`
- [ ] Executar `flutter pub get`
- [ ] Validar: `flutter analyze` (0 issues)
- [ ] Validar: `flutter test` (todos passam)

#### F1.2: Documentar Estratégia de Segurança
- [ ] Adicionar seção "Security Best Practices" ao `README.md`
- [ ] Documentar:
  - Firebase Auth (email/password)
  - HTTPS obrigatório
  - SecureStorage para dados sensíveis
  - Rotação de credenciais
  - Firestore Security Rules (link ou exemplo)

**Critério de Aceite**:
- ✅ `flutter analyze` com 0 issues
- ✅ `flutter test` 100% pass
- ✅ SecureStorageService registrado no DI
- ✅ Documentação de segurança no README

---

### 💾 **FASE 2: Cache Local (MVP)** (6-8 horas)
**Objetivo**: Implementar cache híbrido (local + remote) para Transactions

#### F2.1: Setup Hive
- [ ] Adicionar dependências:
  ```yaml
  dependencies:
    hive: ^2.2.3
    hive_flutter: ^1.1.0
  dev_dependencies:
    hive_generator: ^2.0.0
  ```
- [ ] Executar `flutter pub get`
- [ ] Inicializar Hive no `main.dart`:
  ```dart
  await Hive.initFlutter();
  await Hive.openBox<FinancialTransactionCache>('transactions');
  ```

#### F2.2: Criar Data Source Local
- [ ] Criar `lib/infrastructure/data_sources/local/hive_transaction_data_source.dart`
- [ ] Criar modelo Hive: `lib/infrastructure/dtos/financial_transaction_cache.dart`
  ```dart
  @HiveType(typeId: 1)
  class FinancialTransactionCache extends HiveObject {
    @HiveField(0)
    String id;
    
    @HiveField(1)
    double amount;
    
    @HiveField(2)
    String category;
    
    @HiveField(3)
    DateTime date;
    
    @HiveField(4)
    DateTime cachedAt;
    
    // ... outros campos
  }
  ```
- [ ] Executar `flutter pub run build_runner build`
- [ ] Implementar CRUD no `HiveTransactionDataSource`

#### F2.3: Refatorar Repository para Cache Híbrido
- [ ] Modificar `lib/infrastructure/repositories/firebase_transaction_repository.dart`:
  ```dart
  class FirebaseTransactionRepository implements IFinancialTransactionRepository {
    final FirebaseTransactionDataSource _remoteDS;
    final HiveTransactionDataSource _localDS; // NOVO
    final Duration _cacheTTL = Duration(minutes: 5); // NOVO
    
    @override
    Future<List<FinancialTransactionEntity>> getTransactions(...) async {
      // 1. Tentar cache primeiro
      final cached = await _localDS.getAll();
      if (cached.isNotEmpty && !_isCacheExpired(cached.first.cachedAt)) {
        return cached.map((c) => _mapper.cacheToDomain(c)).toList();
      }
      
      // 2. Buscar remoto
      try {
        final remote = await _remoteDS.getTransactions(...);
        await _localDS.saveAll(remote); // Atualizar cache
        return remote;
      } catch (e) {
        // 3. Fallback para cache (mesmo expirado)
        if (cached.isNotEmpty) return cached.map(...).toList();
        rethrow;
      }
    }
    
    bool _isCacheExpired(DateTime cachedAt) {
      return DateTime.now().difference(cachedAt) > _cacheTTL;
    }
  }
  ```
- [ ] Atualizar DI para injetar `HiveTransactionDataSource`
- [ ] Criar testes para cache híbrido:
  - Cache hit (dados recentes)
  - Cache miss (buscar remoto)
  - Fallback offline (remoto falha, retorna cache expirado)

#### F2.4: Validação e Testes
- [ ] Teste manual offline:
  1. Carregar transações online
  2. Desconectar wifi/dados
  3. Verificar se app carrega do cache
- [ ] Executar `flutter analyze` (0 issues)
- [ ] Executar `flutter test` (todos passam)

**Critério de Aceite**:
- ✅ Hive configurado e inicializado
- ✅ Cache híbrido funcionando (online + offline)
- ✅ TTL de 5 minutos implementado
- ✅ Testes unitários cobrindo cache
- ✅ App funciona offline (com dados cacheados)

---

### ⚡ **FASE 3: Performance e UX** (2-3 horas)
**Objetivo**: Pré-carregamento e indicador de conectividade

#### F3.1: Pré-carregamento de Dados
- [ ] Modificar `lib/presentation/screens/authentication/auth_wrapper.dart`:
  ```dart
  StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        final userId = snapshot.data!.uid;
        
        // PRÉ-CARREGAR DADOS CRÍTICOS
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<BalanceNotifier>().fetchBalances(userId: userId);
          context.read<ProfileNotifier>().fetchProfile(userId);
        });
        
        return const DashboardScreen();
      }
      return const OnboardingCarouselScreen();
    },
  )
  ```
- [ ] Testar tempo de carregamento do Dashboard

#### F3.2: Indicador de Conectividade
- [ ] Adicionar dependência `connectivity_plus: ^6.0.0`
- [ ] Criar `lib/core/services/connectivity_service.dart`
- [ ] Adicionar listener global de conectividade
- [ ] Mostrar banner amarelo quando offline: "Modo offline, mostrando dados salvos"
- [ ] Ocultar banner quando online

**Critério de Aceite**:
- ✅ Dashboard carrega mais rápido (dados pré-carregados)
- ✅ Indicador de conectividade visível
- ✅ UX clara sobre modo offline

---

### 📱 **FASE 4: State Management (Opcional - Longo Prazo)** (10-15 horas)
**Objetivo**: Migrar gradualmente para BLoC/Cubit

⚠️ **NOTA**: Esta fase é opcional e deve ser executada somente se houver tempo e necessidade. A arquitetura atual com Provider é funcional e adequada.

#### F4.1: Setup BLoC
- [ ] Adicionar dependência `flutter_bloc: ^8.x`
- [ ] Criar estrutura base:
  - `lib/application/blocs/`
  - `lib/application/events/`
  - `lib/application/states/`

#### F4.2: Migrar TransactionNotifier → TransactionBloc
- [ ] Criar `TransactionEvent` (FetchTransactions, CreateTransaction, etc.)
- [ ] Criar `TransactionState` (Initial, Loading, Loaded, Error)
- [ ] Implementar `TransactionBloc`
- [ ] Atualizar UI para usar `BlocBuilder`/`BlocConsumer`
- [ ] Atualizar testes para `BlocTest`

#### F4.3: Manter Híbrido
- [ ] Manter Provider para módulos menores (Auth, Profile)
- [ ] Documentar estratégia híbrida

**Critério de Aceite**:
- ✅ BLoC funcionando para Transactions
- ✅ Testes atualizados
- ✅ Provider mantido em outros módulos

---

## ✅ CHECKLIST DE VALIDAÇÃO PÓS-MUDANÇA

Executar após cada fase:

### Análise Estática
- [ ] `flutter analyze` → 0 issues (ou warnings não-críticos documentados)

### Testes
- [ ] `flutter test` → 100% pass
- [ ] Novos testes adicionados para novas funcionalidades
- [ ] Cobertura mantida ou aumentada

### Build
- [ ] `flutter build apk --debug` → sucesso
- [ ] App inicia sem erros
- [ ] Funcionalidades existentes não quebraram

### Testes Manuais (Críticos)
- [ ] Login/Logout funciona
- [ ] Dashboard carrega balances e profile
- [ ] Transactions: criar, editar, deletar, listar
- [ ] Investments: criar, listar, resgatar
- [ ] Profile: visualizar, editar foto
- [ ] Offline: app carrega dados do cache (após Fase 2)

### Code Review
- [ ] Commits pequenos e atômicos
- [ ] Mensagens descritivas
- [ ] Código segue padrões do projeto
- [ ] Sem código comentado ou debug prints

---

## 📝 LOG DE EXECUÇÃO

### 04/01/2026 - Baseline Estabelecido (Primeira Passada)
- ✅ Executado `flutter --version`: Flutter 3.35.4, Dart 3.9.2
- ✅ Executado `flutter pub get`: Sucesso
- ✅ Executado `flutter analyze`: 3 warnings (deprecated_member_use)
- ✅ Executado `flutter test`: 134 testes passaram (32s)
- ✅ Criado `docs/tech_challenge_fase04_fix_plan.md`
- ✅ Criado `RELATORIO_VALIDACAO_TECNICA.md`

### 04/01/2026 - Baseline Revalidado
- ✅ Re-executado `flutter pub get`: Sucesso (10 pacotes com versões mais recentes disponíveis)
- ✅ Re-executado `flutter analyze`: 3 warnings confirmados
  - Paths atualizados com formato Windows: `lib\presentation\...` 
  - Linhas e colunas precisas: `:160:15`, `:375:21`, `:134:15`
  - Tempo de execução: 7.6s
- ✅ Re-executado `flutter test`: 134 testes passaram (21s)
- ✅ Branch criada: `fix/tech-challenge-fase04` (a partir de `dev`)
- ✅ Status git: 2 arquivos untracked (relatórios)
- 📋 Próxima ação: Corrigir warnings do analyze (PRÉ-FASE)

### 04/01/2026 - PRÉ-FASE: Correções Rápidas (CONCLUÍDA)
- ✅ Status: **COMPLETO**
- ✅ Branch: `fix/tech-challenge-fase04`
- ✅ Arquivos alterados (3):
  - `lib/presentation/screens/investments/create_investment_screen.dart`
  - `lib/presentation/screens/transactions/create_transaction_screen.dart`
  - `lib/presentation/screens/transactions/edit_transaction_screen.dart`
- ✅ Mudança: `value` → `initialValue` em `DropdownButtonFormField`
- ✅ Validação: `flutter analyze` → **0 issues** (7.7s)
- ✅ Validação: `flutter test` → **134/134 pass** (16s)
- ✅ Commit: `5853cc8` - "fix: corrige deprecated_member_use warnings"
- 📋 Próxima ação: FASE 1 (Segurança Imediata)

### [DATA] - FASE 1: Segurança
- [ ] Status: Pendente
- [ ] PR: #XXX
- [ ] Notas: ...

### [DATA] - FASE 2: Cache Local
- [ ] Status: Pendente
- [ ] PR: #XXX
- [ ] Notas: ...

### [DATA] - FASE 3: Performance e UX
- [ ] Status: Pendente
- [ ] PR: #XXX
- [ ] Notas: ...

---

## 🎓 LIÇÕES APRENDIDAS

_(Atualizar conforme o projeto avança)_

### O que funcionou bem:
- TBD

### Desafios encontrados:
- TBD

### Melhorias para o futuro:
- TBD

---

## 📚 REFERÊNCIAS

- [RELATORIO_VALIDACAO_TECNICA.md](../RELATORIO_VALIDACAO_TECNICA.md) - Relatório completo de validação
- [README.md](../README.md) - Documentação principal do projeto
- [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [Hive Documentation](https://docs.hivedb.dev/)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- [BLoC Pattern](https://bloclibrary.dev/)

---

**Status Geral**: ✅ BASELINE VALIDADO - PRONTO PARA PRÉ-FASE  
**Branch de Trabalho**: `fix/tech-challenge-fase04` (criada em 04/01/2026)  
**Branch Base**: `dev`  
**Última Atualização**: 04/01/2026  
**Responsável**: Equipe NCC Finance
