/// Cache policy configuration for local data storage.
///
/// Defines TTL (time-to-live) and expiration logic for cached data.
class CachePolicy {
  /// Default TTL: 5 minutes
  static const Duration defaultTTL = Duration(minutes: 5);

  /// Time-to-live duration for this cache policy.
  final Duration ttl;

  const CachePolicy({this.ttl = defaultTTL});

  /// Checks if cached data is expired based on [cachedAt] timestamp.
  ///
  /// Returns true if the cached data is older than the TTL.
  bool isExpired(DateTime cachedAt) {
    final now = DateTime.now();
    final age = now.difference(cachedAt);
    return age > ttl;
  }

  /// Returns the expiration timestamp for data cached at [cachedAt].
  DateTime getExpirationTime(DateTime cachedAt) {
    return cachedAt.add(ttl);
  }
}

/// Metadata for cached data.
class CacheMetadata {
  /// Timestamp when the data was cached.
  final DateTime cachedAt;

  /// Cache version for invalidation (optional).
  final int version;

  const CacheMetadata({
    required this.cachedAt,
    this.version = 1,
  });

  /// Create CacheMetadata from JSON map.
  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      version: json['version'] as int? ?? 1,
    );
  }

  /// Convert CacheMetadata to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'cachedAt': cachedAt.toIso8601String(),
      'version': version,
    };
  }

  /// Create a new CacheMetadata with current timestamp.
  static CacheMetadata now() {
    return CacheMetadata(cachedAt: DateTime.now());
  }
}
