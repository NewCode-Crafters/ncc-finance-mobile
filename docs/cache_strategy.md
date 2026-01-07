# Cache Strategy - Bytebank (NCC Finance Mobile)

## Overview

Bytebank implements a **hybrid cache strategy** for financial transactions to improve user experience, reduce Firebase Firestore costs, and enable basic offline functionality.

## Architecture

### Cache-First Strategy

The app follows a **cache-first approach** with intelligent fallbacks:

1. **Fresh Cache (within TTL)**: Return cached data immediately
2. **Expired Cache**: Fetch from remote (Firestore) and update cache
3. **Remote Failure**: Fallback to stale cache if available

```
User Request
    ↓
[Check Cache]
    ↓
Cache Fresh? → YES → Return Cached Data
    ↓ NO
[Fetch from Firestore]
    ↓
Success? → YES → Update Cache → Return Fresh Data
    ↓ NO
[Fallback to Stale Cache]
    ↓
Cache Exists? → YES → Return Stale Data (offline mode)
    ↓ NO
Return Error
```

## Implementation Details

### Technology Stack

- **Local Storage**: Hive (NoSQL key-value database)
- **Serialization**: JSON maps (no codegen)
- **Cache Key**: `userId` (one cache per user)
- **TTL**: 5 minutes (configurable via `CachePolicy`)

### Components

#### 1. `CachePolicy` (`lib/core/cache/cache_policy.dart`)

Defines cache behavior:
- **TTL**: Time-to-live (default: 5 minutes)
- **Expiration Check**: Compares cached timestamp against current time
- **Metadata**: Version and cached-at timestamp

#### 2. `HiveTransactionCacheDataSource` (`lib/infrastructure/data_sources/local/`)

Responsible for:
- Opening/closing Hive box (`transactions_cache`)
- Saving transactions as JSON maps
- Retrieving cached data with metadata
- Cache invalidation (per-user or all)

#### 3. `FirebaseTransactionRepository` (modified)

Implements hybrid logic:
```dart
Future<List<FinancialTransactionEntity>> getTransactions() async {
  // 1. Try cache first
  if (cache exists && !isExpired) {
    return cachedData;
  }
  
  // 2. Fetch remote
  try {
    final remote = await fetchFromFirestore();
    await updateCache(remote);
    return remote;
  } catch (e) {
    // 3. Fallback to stale cache
    if (cache exists) {
      return staleCache; // Better than nothing
    }
    rethrow;
  }
}
```

### Storage Format

Cached data structure (per userId):
```json
{
  "metadata": {
    "cachedAt": "2026-01-05T10:30:00.000Z",
    "version": 1
  },
  "transactions": [
    {
      "id": "txn123",
      "amount": 100.50,
      "category": "Food",
      "balanceId": "bal456",
      "date": "2026-01-05T09:00:00.000Z",
      "description": "Grocery shopping"
    }
  ]
}
```

## Offline Behavior

### What Works Offline

✅ **View Cached Transactions**: Users can see previously loaded transactions  
✅ **Dashboard Charts**: Display charts based on cached data  
✅ **Read Operations**: All GET operations work if cache exists  

### What Doesn't Work Offline

❌ **Create/Update/Delete**: Requires network (Firestore write)  
❌ **Sync Changes**: Cached data doesn't auto-sync when back online  
❌ **Real-time Updates**: Streams (`watchTransactions`) bypass cache  

## Cache vs Firestore Built-in Cache

### Bytebank Custom Cache

- **Scope**: User-scoped transactions only
- **Persistence**: Survives app restarts (Hive storage)
- **Control**: Manual TTL, explicit invalidation
- **Fallback**: Stale cache used when offline
- **Cost**: Zero Firestore reads for fresh cache

### Firestore SDK Cache

- **Scope**: All Firestore documents
- **Persistence**: Default: memory-only (clears on app kill)
- **Control**: Limited (cache size, enabled/disabled)
- **Behavior**: Automatic sync when online
- **Cost**: Counts as free reads (from cache)

**Key Difference**: Bytebank cache **complements** Firestore cache:
- Firestore cache: short-term, automatic
- Bytebank cache: longer TTL, explicit control, offline-first UX

## Cache Invalidation

### Automatic Invalidation

- **TTL Expiry**: After 5 minutes, cache is considered stale
- **Next Request**: Triggers remote fetch + cache update

### Manual Invalidation

```dart
// Clear cache for specific user
await cacheDataSource.clearCache(userId);

// Clear all caches
await cacheDataSource.clearAllCache();
```

**Triggers for Manual Invalidation:**
- User logout (clear user cache)
- Settings > Clear Cache (user-initiated)
- App update (version change detection)

## Performance Characteristics

### Cache Hit (Fresh)

- **Latency**: ~5-10ms (local Hive read)
- **Network**: 0 requests
- **Cost**: $0 (no Firestore read)

### Cache Miss or Expired

- **Latency**: ~200-500ms (Firestore query + network)
- **Network**: 1 Firestore query
- **Cost**: Firestore document reads charged

### Offline with Stale Cache

- **Latency**: ~5-10ms (local read)
- **Data Freshness**: May be outdated (>5 min old)
- **UX**: Better than error (show stale data)

## Testing Strategy

### Unit Tests

✅ `cache_policy_test.dart`:
- TTL expiration logic
- Metadata serialization

✅ `hive_transaction_cache_data_source_test.dart`:
- CRUD operations on cache
- Multiple users isolation
- Cache invalidation

✅ `firebase_transaction_repository_test.dart`:
- Cache-first flow
- Expired cache triggers remote fetch
- Offline fallback to stale cache

### Integration Testing

**Manual Test: Offline Mode**
1. Open app → load transactions (populates cache)
2. Turn OFF wifi/mobile data
3. Navigate to Transactions screen
4. ✅ Verify: Cached transactions display correctly
5. Try to create transaction
6. ❌ Verify: Error shown (requires network)

## Future Improvements

### Phase 3 (Optional)

- [ ] **Write-Through Cache**: Update cache on create/update/delete
- [ ] **Selective Caching**: Cache only last 30 days (reduce storage)
- [ ] **Background Sync**: Queue offline writes, sync when online
- [ ] **Cache Analytics**: Track hit/miss ratio
- [ ] **Multi-Collection Cache**: Extend to investments, balances

### Observability

- [ ] Log cache hits/misses for monitoring
- [ ] Expose cache size in Settings UI
- [ ] Add cache clear option in developer menu

## Related Documentation

- [Hive Documentation](https://docs.hivedb.dev/)
- [Firestore Offline Data](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Tech Challenge Fix Plan](tech_challenge_fase04_fix_plan.md)

## Decision Log

**Why Hive?**
- ✅ No codegen required (simpler setup)
- ✅ Mature, stable package
- ✅ Good Flutter/Dart integration
- ✅ Fast key-value access

**Why NOT SQLite?**
- Overkill for simple key-value cache
- Requires more boilerplate (tables, migrations)
- Hive is faster for our use case

**Why Cache Transactions Only?**
- Transactions change frequently (need TTL)
- Balances/Profiles rarely change (lower priority)
- Focused scope = easier to test

---

**Last Updated**: January 5, 2026  
**Phase**: 2.0 - Cache Local (MVP)  
**Status**: ✅ Implemented and Tested
