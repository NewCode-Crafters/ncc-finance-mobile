# Performance Optimization Guide - NCC Finance Mobile

## Table of Contents
1. [Overview](#overview)
2. [Performance Principles](#performance-principles)
3. [Widget Optimization](#widget-optimization)
4. [State Management Performance](#state-management-performance)
5. [Data Loading Strategies](#data-loading-strategies)
6. [Caching Strategies](#caching-strategies)
7. [Image Optimization](#image-optimization)
8. [List Performance](#list-performance)
9. [Network Optimization](#network-optimization)
10. [Build Optimization](#build-optimization)
11. [Monitoring & Profiling](#monitoring--profiling)

## Overview

Performance optimization is crucial for delivering a smooth, responsive user experience. This guide outlines strategies for optimizing the NCC Finance Mobile application across multiple dimensions.

### Performance Goals

- **App Startup**: < 2 seconds to first meaningful paint
- **Screen Transitions**: 60 FPS (16ms per frame)
- **List Scrolling**: Smooth 60 FPS with 1000+ items
- **Network Requests**: < 1 second for typical operations
- **Memory Usage**: < 200 MB for typical usage
- **Battery Efficiency**: Minimal background activity

## Performance Principles

### 1. Build Only What's Needed
- Use `const` constructors wherever possible
- Minimize widget rebuilds with `Selector` and `Consumer`
- Extract static widgets into separate classes

### 2. Load Data Efficiently
- Implement pagination for large lists
- Use lazy loading for images and data
- Cache frequently accessed data

### 3. Optimize Assets
- Compress images before including
- Use appropriate image formats (WebP > PNG > JPEG)
- Load images at appropriate resolutions

### 4. Monitor Performance
- Use Flutter DevTools for profiling
- Track frame rendering times
- Monitor memory usage patterns

## Widget Optimization

### Const Constructors

```dart
// ❌ Bad: Rebuilds unnecessarily
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Static Text'),
    );
  }
}

// ✅ Good: Uses const constructors
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Text('Static Text');
  }
}
```

### Extract Static Widgets

```dart
// ❌ Bad: Rebuilds entire tree
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionNotifier>(
      builder: (context, notifier, child) {
        return Column(
          children: [
            AppBar(title: Text('Transações')), // Rebuilds unnecessarily
            TransactionList(transactions: notifier.transactions),
          ],
        );
      },
    );
  }
}

// ✅ Good: Static widgets don't rebuild
class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StaticAppBar(), // Doesn't rebuild
        Consumer<TransactionNotifier>(
          builder: (context, notifier, child) {
            return TransactionList(transactions: notifier.transactions);
          },
        ),
      ],
    );
  }
}

class _StaticAppBar extends StatelessWidget {
  const _StaticAppBar({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Transações'));
  }
}
```

### Use Keys Wisely

```dart
// ✅ Good: Use keys for list items
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    final transaction = transactions[index];
    return TransactionCard(
      key: ValueKey(transaction.id), // Helps Flutter identify widgets
      transaction: transaction,
    );
  },
)
```

## State Management Performance

### Targeted Rebuilds with Selector

```dart
// ❌ Bad: Rebuilds for any state change
Consumer<TransactionNotifier>(
  builder: (context, notifier, child) {
    return Text('Total: \${notifier.totalAmount}');
  },
)

// ✅ Good: Only rebuilds when totalAmount changes
Selector<TransactionNotifier, double>(
  selector: (context, notifier) => notifier.totalAmount,
  builder: (context, totalAmount, child) {
    return Text('Total: \$totalAmount');
  },
)
```

### Child Parameter for Static Content

```dart
// ✅ Good: Pass static content as child
Consumer<TransactionNotifier>(
  builder: (context, notifier, child) {
    return Column(
      children: [
        child!, // Static widget, doesn't rebuild
        DynamicContent(data: notifier.data),
      ],
    );
  },
  child: const StaticHeader(), // Built once
)
```

### Debouncing Rapid Updates

```dart
import 'dart:async';

class SearchNotifier extends ChangeNotifier {
  Timer? _debounce;
  String _searchQuery = '';
  
  void updateSearch(String query) {
    // Cancel previous timer
    _debounce?.cancel();
    
    // Create new timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      _performSearch();
      notifyListeners();
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

## Data Loading Strategies

### Lazy Loading Implementation

```dart
class TransactionNotifier extends ChangeNotifier {
  List<FinancialTransaction> _transactions = [];
  bool _hasMore = true;
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  
  static const int _pageSize = 20;
  
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(_pageSize);
      
      // Start after last document for pagination
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        
        final newTransactions = snapshot.docs
            .map((doc) => FinancialTransaction.fromFirestore(doc))
            .toList();
        
        _transactions.addAll(newTransactions);
        
        if (snapshot.docs.length < _pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void reset() {
    _transactions.clear();
    _lastDocument = null;
    _hasMore = true;
  }
}
```

### Infinite Scroll Widget

```dart
class InfiniteScrollList extends StatefulWidget {
  final List<FinancialTransaction> transactions;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoading;
  
  const InfiniteScrollList({
    Key? key,
    required this.transactions,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoading,
  }) : super(key: key);
  
  @override
  _InfiniteScrollListState createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // Load more when 80% scrolled
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      if (widget.hasMore && !widget.isLoading) {
        widget.onLoadMore();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.transactions.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.transactions.length) {
          return TransactionCard(
            key: ValueKey(widget.transactions[index].id),
            transaction: widget.transactions[index],
          );
        }
        
        // Loading indicator at bottom
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
```

### Preloading Strategy

```dart
class DashboardNotifier extends ChangeNotifier {
  Future<void> preloadData() async {
    // Load multiple data sources in parallel
    await Future.wait([
      _loadBalance(),
      _loadRecentTransactions(),
      _loadChartData(),
    ]);
    
    notifyListeners();
  }
  
  Future<void> _loadBalance() async {
    // Load balance data
  }
  
  Future<void> _loadRecentTransactions() async {
    // Load recent transactions
  }
  
  Future<void> _loadChartData() async {
    // Load chart data
  }
}
```

## Caching Strategies

### In-Memory Caching

```dart
class CacheService {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 5);
  
  T? get<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    
    if (timestamp == null) return null;
    
    // Check if cache is still valid
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    
    return _cache[key] as T?;
  }
  
  void set(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }
  
  void clear() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
  
  void invalidate(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }
}
```

### Firebase Offline Persistence

```dart
// Enable offline persistence
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(MyApp());
}
```

### Cache-First Strategy

```dart
class TransactionService {
  final CacheService _cacheService;
  
  Future<List<FinancialTransaction>> getTransactions({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'transactions_list';
    
    // Try cache first
    if (!forceRefresh) {
      final cached = _cacheService.get<List<FinancialTransaction>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }
    
    // Fetch from Firestore
    final transactions = await _fetchFromFirestore();
    
    // Update cache
    _cacheService.set(cacheKey, transactions);
    
    return transactions;
  }
  
  Future<List<FinancialTransaction>> _fetchFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => FinancialTransaction.fromFirestore(doc))
        .toList();
  }
}
```

### Image Caching

```dart
// Firebase Storage automatically caches images
// For additional control, use cached_network_image package

import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  
  const ProfileAvatar({Key? key, required this.imageUrl}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.person),
      memCacheWidth: 200, // Resize for memory efficiency
      memCacheHeight: 200,
      maxWidthDiskCache: 400, // Disk cache settings
      maxHeightDiskCache: 400,
    );
  }
}
```

## Image Optimization

### Loading Appropriate Sizes

```dart
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  
  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).round(),
      cacheHeight: (height * MediaQuery.of(context).devicePixelRatio).round(),
      fit: BoxFit.cover,
    );
  }
}
```

### Lazy Image Loading

```dart
class LazyImageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Image.network(
          images[index],
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
```

### Image Compression

```dart
import 'package:image/image.dart' as img;
import 'dart:typed_data';

Future<Uint8List> compressImage(Uint8List imageBytes) async {
  // Decode image
  final image = img.decodeImage(imageBytes);
  if (image == null) return imageBytes;
  
  // Resize if too large
  img.Image resized = image;
  if (image.width > 1024 || image.height > 1024) {
    resized = img.copyResize(
      image,
      width: image.width > image.height ? 1024 : null,
      height: image.height > image.width ? 1024 : null,
    );
  }
  
  // Compress as JPEG with quality 85
  final compressed = img.encodeJpg(resized, quality: 85);
  
  return Uint8List.fromList(compressed);
}
```

## List Performance

### ListView.builder for Large Lists

```dart
// ✅ Good: Efficient for large lists
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    return TransactionCard(transaction: transactions[index]);
  },
)

// ❌ Bad: Creates all widgets at once
ListView(
  children: transactions.map((t) => TransactionCard(transaction: t)).toList(),
)
```

### Custom ScrollPhysics

```dart
// Improve scroll performance
ListView.builder(
  physics: const ClampingScrollPhysics(), // Faster than default
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)
```

### AddAutomaticKeepAlive for Expensive Widgets

```dart
class ExpensiveListItem extends StatefulWidget {
  @override
  _ExpensiveListItemState createState() => _ExpensiveListItemState();
}

class _ExpensiveListItemState extends State<ExpensiveListItem>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Keep state when scrolled off screen
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Must call super.build()
    
    return ExpensiveWidget();
  }
}
```

## Network Optimization

### Batch Requests

```dart
class BatchService {
  Future<Map<String, dynamic>> loadDashboardData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    
    // Execute multiple queries in parallel
    final results = await Future.wait([
      _getBalance(user.uid),
      _getRecentTransactions(user.uid),
      _getMonthlyStats(user.uid),
    ]);
    
    return {
      'balance': results[0],
      'transactions': results[1],
      'stats': results[2],
    };
  }
}
```

### Request Deduplication

```dart
class RequestDeduplicator {
  final Map<String, Future<dynamic>> _pendingRequests = {};
  
  Future<T> execute<T>(String key, Future<T> Function() request) async {
    // Check if request is already in progress
    if (_pendingRequests.containsKey(key)) {
      return _pendingRequests[key] as Future<T>;
    }
    
    // Create new request
    final future = request();
    _pendingRequests[key] = future;
    
    try {
      final result = await future;
      return result;
    } finally {
      _pendingRequests.remove(key);
    }
  }
}
```

### Connection Pooling

Firebase SDK handles connection pooling automatically, but you can optimize:

```dart
// Reuse Firestore instance
class FirestoreService {
  static final FirebaseFirestore _instance = FirebaseFirestore.instance;
  
  static FirebaseFirestore get instance => _instance;
}
```

## Build Optimization

### Production Build Settings

```yaml
# android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            
            // Enable code obfuscation
            signingConfig signingConfigs.release
        }
    }
}
```

### Dart Optimization Flags

```bash
# Build with optimization
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# iOS build
flutter build ios --release --obfuscate --split-debug-info=build/debug-info
```

### Asset Optimization

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/  # Include only necessary assets
  
  # Use asset variants for different densities
  # assets/images/logo.png
  # assets/images/2.0x/logo.png
  # assets/images/3.0x/logo.png
```

## Monitoring & Profiling

### Performance Monitoring

```dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  Future<void> trackOperation(String name, Future<void> Function() operation) async {
    final trace = FirebasePerformance.instance.newTrace(name);
    await trace.start();
    
    try {
      await operation();
    } finally {
      await trace.stop();
    }
  }
  
  Future<void> trackScreenLoad(String screenName) async {
    final trace = FirebasePerformance.instance.newTrace('screen_$screenName');
    await trace.start();
    
    // Auto-stop after reasonable time
    Future.delayed(Duration(seconds: 3), () => trace.stop());
  }
}
```

### Custom Performance Metrics

```dart
class MetricsCollector {
  static void trackBuildTime(String widgetName, Duration buildTime) {
    if (buildTime.inMilliseconds > 16) {
      print('Warning: $widgetName took ${buildTime.inMilliseconds}ms to build');
    }
  }
  
  static void trackListScrollPerformance(int itemCount, Duration renderTime) {
    final timePerItem = renderTime.inMicroseconds / itemCount;
    print('List render: $itemCount items in ${renderTime.inMilliseconds}ms '
          '(${timePerItem.toStringAsFixed(2)}μs/item)');
  }
}
```

### Flutter DevTools Usage

```bash
# Launch DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Profile app
flutter run --profile
```

**Key DevTools Features:**
1. **Performance View**: Track frame rendering times
2. **Memory View**: Monitor memory allocation and leaks
3. **Network View**: Analyze network requests
4. **Timeline View**: See widget rebuild patterns

## Performance Checklist

### Startup Performance
- [ ] Minimize work in `main()`
- [ ] Use splash screen while loading
- [ ] Defer non-critical initialization
- [ ] Preload critical data only

### Runtime Performance
- [ ] Use `const` constructors
- [ ] Implement lazy loading
- [ ] Use `Selector` for targeted rebuilds
- [ ] Optimize list rendering with `ListView.builder`
- [ ] Cache frequently accessed data

### Network Performance
- [ ] Enable Firestore offline persistence
- [ ] Implement request caching
- [ ] Batch multiple requests
- [ ] Use pagination for large datasets

### Memory Performance
- [ ] Dispose controllers and listeners
- [ ] Limit cache size
- [ ] Compress images before upload
- [ ] Use appropriate image sizes

### Build Performance
- [ ] Enable code obfuscation
- [ ] Use ProGuard/R8 for Android
- [ ] Remove unused dependencies
- [ ] Optimize asset sizes

## Conclusion

Performance optimization is an ongoing process. Key strategies:

1. **Profile First**: Measure before optimizing
2. **Optimize Hot Paths**: Focus on frequently executed code
3. **Lazy Load**: Load data and widgets on demand
4. **Cache Wisely**: Balance freshness with performance
5. **Monitor Production**: Track real-world performance

Regular profiling with Flutter DevTools and Firebase Performance Monitoring helps identify and address performance bottlenecks before they impact users.
