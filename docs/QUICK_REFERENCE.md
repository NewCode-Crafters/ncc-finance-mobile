# Hexagonal Architecture - Quick Reference Card

**🎯 One-page cheat sheet for developers**

---

## 📁 Folder Structure

```
lib/
├── domain/               # Pure business logic (no dependencies!)
│   ├── entities/         # Business objects (e.g., Transaction, User)
│   ├── repositories/     # Interfaces (ports)
│   └── use_cases/        # Business rules
│
├── infrastructure/       # External service implementations
│   ├── repositories/     # Firebase implementations
│   ├── data_sources/     # Firebase, API clients
│   ├── dtos/            # Data transfer objects
│   └── mappers/         # DTO ↔ Entity conversions
│
├── application/         # Orchestration
│   ├── notifiers/       # State management
│   └── services/        # App-level services
│
├── presentation/        # UI layer
│   ├── screens/         # All screens
│   └── widgets/         # Reusable widgets
│
└── core/               # Shared utilities
    ├── di/             # Dependency injection
    ├── constants/      # App constants
    └── utils/          # Helper functions
```

---

## 📝 File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Entity | `{name}.dart` | `transaction.dart` |
| Repository Interface | `{name}_repository.dart` | `transaction_repository.dart` |
| Use Case | `{verb}_{name}_use_case.dart` | `create_transaction_use_case.dart` |
| DTO | `{name}_dto.dart` | `transaction_dto.dart` |
| Mapper | `{name}_mapper.dart` | `transaction_mapper.dart` |
| Repository Impl | `{source}_{name}_repository.dart` | `firebase_transaction_repository.dart` |
| Notifier | `{name}_notifier.dart` | `transaction_notifier.dart` |
| Screen | `{name}_{purpose}_screen.dart` | `create_transaction_screen.dart` |

---

## 🔄 Dependency Flow

```
Presentation → Application → Domain ← Infrastructure
                                ↑
                         Everything points here!
```

**Rule:** All dependencies point INWARD toward domain.

---

## 🏗️ Creating a New Feature: 5 Steps

### 1️⃣ Domain Layer (Pure Business Logic)

**Entity:**
```dart
// lib/domain/entities/product.dart
class Product extends Equatable {
  final String id;
  final String name;
  final double price;

  const Product({required this.id, required this.name, required this.price});
  
  // Business rule
  bool get isExpensive => price > 100.0;
  
  @override
  List<Object?> get props => [id, name, price];
}
```

**Repository Interface (Port):**
```dart
// lib/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> createProduct(Product product);
}
```

**Use Case:**
```dart
// lib/domain/use_cases/products/get_products_use_case.dart
class GetProductsUseCase {
  final ProductRepository repository;
  
  GetProductsUseCase({required this.repository});
  
  Future<List<Product>> execute() async {
    return await repository.getProducts();
  }
}
```

### 2️⃣ Infrastructure Layer (Adapters)

**DTO:**
```dart
// lib/infrastructure/dtos/product_dto.dart
class ProductDTO {
  final String id;
  final String name;
  final double price;
  
  factory ProductDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductDTO(
      id: doc.id,
      name: data['name'],
      price: data['price'].toDouble(),
    );
  }
  
  Map<String, dynamic> toFirestore() => {'name': name, 'price': price};
}
```

**Mapper:**
```dart
// lib/infrastructure/mappers/product_mapper.dart
class ProductMapper {
  static Product toDomain(ProductDTO dto) {
    return Product(id: dto.id, name: dto.name, price: dto.price);
  }
  
  static ProductDTO toDTO(Product product) {
    return ProductDTO(id: product.id, name: product.name, price: product.price);
  }
}
```

**Repository Implementation:**
```dart
// lib/infrastructure/repositories/firebase_product_repository.dart
class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore firestore;
  
  FirebaseProductRepository({required this.firestore});
  
  @override
  Future<List<Product>> getProducts() async {
    final snapshot = await firestore.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductMapper.toDomain(ProductDTO.fromFirestore(doc)))
        .toList();
  }
}
```

### 3️⃣ Application Layer (Orchestration)

**Notifier:**
```dart
// lib/application/notifiers/product_notifier.dart
class ProductNotifier extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  
  List<Product> _products = [];
  bool _isLoading = false;
  
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  
  ProductNotifier({required this.getProductsUseCase});
  
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    
    _products = await getProductsUseCase.execute();
    _isLoading = false;
    notifyListeners();
  }
}
```

### 4️⃣ Presentation Layer (UI)

**Screen:**
```dart
// lib/presentation/screens/products/products_screen.dart
class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading) return CircularProgressIndicator();
        
        return ListView.builder(
          itemCount: notifier.products.length,
          itemBuilder: (context, index) {
            final product = notifier.products[index];
            return ListTile(title: Text(product.name));
          },
        );
      },
    );
  }
}
```

### 5️⃣ Dependency Injection

**Register in DI Container:**
```dart
// lib/core/di/injection_container.dart
void initializeDependencies() {
  // Firestore
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  
  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => FirebaseProductRepository(firestore: sl()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => GetProductsUseCase(repository: sl()));
  
  // Notifier
  sl.registerFactory(() => ProductNotifier(getProductsUseCase: sl()));
}
```

---

## ✅ Testing Strategy

### Domain Tests (Pure Unit Tests)
```dart
test('Product isExpensive returns true when price > 100', () {
  final product = Product(id: '1', name: 'Laptop', price: 150.0);
  expect(product.isExpensive, true);
});

test('GetProductsUseCase returns products from repository', () async {
  final mockRepo = MockProductRepository();
  when(mockRepo.getProducts()).thenAnswer((_) async => [testProduct]);
  
  final useCase = GetProductsUseCase(repository: mockRepo);
  final result = await useCase.execute();
  
  expect(result, [testProduct]);
});
```

### Infrastructure Tests (Integration)
```dart
test('FirebaseProductRepository maps Firestore docs to entities', () async {
  final fakeFirestore = FakeFirebaseFirestore();
  await fakeFirestore.collection('products').add({'name': 'Test', 'price': 50.0});
  
  final repo = FirebaseProductRepository(firestore: fakeFirestore);
  final products = await repo.getProducts();
  
  expect(products.length, 1);
  expect(products.first.name, 'Test');
});
```

### Application Tests (Unit with Mocks)
```dart
test('ProductNotifier fetches and updates products', () async {
  final mockUseCase = MockGetProductsUseCase();
  when(mockUseCase.execute()).thenAnswer((_) async => [testProduct]);
  
  final notifier = ProductNotifier(getProductsUseCase: mockUseCase);
  await notifier.fetchProducts();
  
  expect(notifier.products, [testProduct]);
  expect(notifier.isLoading, false);
});
```

---

## 🚫 Common Mistakes to Avoid

❌ **Don't:** Import Firebase in domain layer
✅ **Do:** Keep domain pure (no external dependencies)

❌ **Don't:** Put business logic in repositories
✅ **Do:** Put business logic in use cases or entities

❌ **Don't:** Access repositories directly from UI
✅ **Do:** Use notifiers that call use cases

❌ **Don't:** Mix DTO and Entity
✅ **Do:** Use mappers to convert between them

❌ **Don't:** Make use cases do too much
✅ **Do:** Keep use cases small and focused (one action)

---

## 🎯 Checklist for New Feature

- [ ] Create entity in `domain/entities/`
- [ ] Create repository interface in `domain/repositories/`
- [ ] Create use cases in `domain/use_cases/{feature}/`
- [ ] Write unit tests for entity and use cases
- [ ] Create DTO in `infrastructure/dtos/`
- [ ] Create mapper in `infrastructure/mappers/`
- [ ] Create repository implementation in `infrastructure/repositories/`
- [ ] Write integration tests for repository
- [ ] Create/update notifier in `application/notifiers/`
- [ ] Write unit tests for notifier
- [ ] Create/update screens in `presentation/screens/{feature}/`
- [ ] Register dependencies in `core/di/injection_container.dart`
- [ ] Test feature end-to-end

---

## 📚 Need More Details?

- **Full examples:** [hexagonal_architecture_analysis.md](./hexagonal_architecture_analysis.md)
- **Visual diagrams:** [hexagonal_architecture_diagrams.md](./hexagonal_architecture_diagrams.md)
- **Step-by-step guide:** [hexagonal_migration_checklist.md](./hexagonal_migration_checklist.md)
- **Documentation index:** [README_HEXAGONAL.md](./README_HEXAGONAL.md)

---

**💡 Remember:** Keep domain pure, point dependencies inward, test each layer!

**🚀 Happy coding!**
