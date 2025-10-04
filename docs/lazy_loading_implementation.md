# Implementação de Lazy Loading na Tela de Transações

## Visão Geral

Foi implementado um sistema de lazy loading (carregamento incremental) na tela de transações para melhorar a performance e experiência do usuário. O sistema exibe inicialmente apenas 3 itens e carrega mais conforme o usuário rola a tela.

## Mudanças Implementadas

### 1. TransactionState (transaction_notifier.dart)

Adicionadas novas propriedades para controlar o lazy loading:

```dart
class TransactionState {
  // ... outras propriedades
  final int displayedItemsCount;  // Quantidade de itens sendo exibidos
  final bool hasMore;             // Se há mais itens para carregar
  final bool isLoadingMore;       // Se está carregando mais itens
  
  TransactionState({
    // ... outros parâmetros
    this.displayedItemsCount = 3,  // Começar com 3 itens
    this.hasMore = true,
    this.isLoadingMore = false,
  });
}
```

### 2. TransactionNotifier (transaction_notifier.dart)

#### Método `visibleTransactions` atualizado:
- Agora retorna apenas os itens que devem ser exibidos com base em `displayedItemsCount`
- Aplica o limite tanto para listas filtradas quanto não filtradas

#### Novo método `loadMoreTransactions()`:
```dart
Future<void> loadMoreTransactions() async {
  if (_state.isLoadingMore || !_state.hasMore) return;
  
  _state = _state.copyWith(isLoadingMore: true);
  notifyListeners();
  
  // Simula delay de carregamento
  await Future.delayed(const Duration(milliseconds: 500));
  
  final currentCount = _state.displayedItemsCount;
  final newCount = currentCount + 3; // Carregar mais 3 itens
  final totalItems = // calcula total baseado em filtro ou não
  
  _state = _state.copyWith(
    isLoadingMore: false,
    displayedItemsCount: newCount,
    hasMore: newCount < totalItems,
  );
  notifyListeners();
}
```

#### Método `updateSearchText` atualizado:
- Agora reseta `displayedItemsCount` para 3 ao pesquisar

#### Método `fetchTransactions` atualizado:
- Reseta `displayedItemsCount` para 3 ao carregar transações
- Define `hasMore` baseado na quantidade total de itens

### 3. TransactionsScreen (transactions_screen.dart)

#### ListView.builder atualizado:
- Envolvido em `NotificationListener<ScrollNotification>` para detectar scroll
- `itemCount` agora inclui +1 se houver mais itens (para o indicador de loading)
- Adicionado indicador de loading circular quando `isLoadingMore` é true

```dart
NotificationListener<ScrollNotification>(
  onNotification: (ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
        notifier.state.hasMore &&
        !notifier.state.isLoadingMore) {
      notifier.loadMoreTransactions();
    }
    return false;
  },
  child: ListView.builder(
    itemCount: notifier.visibleTransactions.length + 
               (notifier.state.hasMore ? 1 : 0),
    // ...
  ),
)
```

## Comportamento

1. **Carregamento inicial**: Exibe apenas 3 transações
2. **Scroll para baixo**: Quando o usuário chega ao final da lista, carrega mais 3 itens
3. **Indicador de loading**: Mostra um CircularProgressIndicator quando está carregando
4. **Pesquisa**: Ao pesquisar, reseta para 3 itens e aplica o filtro
5. **Sem mais itens**: Quando não há mais itens, remove o indicador de loading

## Benefícios

- **Performance**: Reduz o uso de memória ao não carregar todas as transações de uma vez
- **Experiência do usuário**: Interface mais responsiva
- **Escalabilidade**: Funciona bem mesmo com muitas transações
- **Compatibilidade**: Mantém funcionalidade de pesquisa intacta

## Configuração

Para ajustar a quantidade de itens carregados por vez, modifique:
- `displayedItemsCount = 3` em `TransactionState`
- `newCount = currentCount + 3` em `loadMoreTransactions()`