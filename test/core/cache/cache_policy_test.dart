import 'package:bytebank/core/cache/cache_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CachePolicy', () {
    test('isExpired returns false for fresh cache (within TTL)', () {
      const policy = CachePolicy(ttl: Duration(minutes: 5));
      final cachedAt = DateTime.now().subtract(const Duration(minutes: 2));

      expect(policy.isExpired(cachedAt), false);
    });

    test('isExpired returns true for expired cache (beyond TTL)', () {
      const policy = CachePolicy(ttl: Duration(minutes: 5));
      final cachedAt = DateTime.now().subtract(const Duration(minutes: 10));

      expect(policy.isExpired(cachedAt), true);
    });

    test('isExpired returns true for cache exactly at TTL boundary', () {
      const policy = CachePolicy(ttl: Duration(minutes: 5));
      final cachedAt = DateTime.now().subtract(const Duration(minutes: 5, seconds: 1));

      expect(policy.isExpired(cachedAt), true);
    });

    test('getExpirationTime returns correct expiration timestamp', () {
      const policy = CachePolicy(ttl: Duration(minutes: 5));
      final cachedAt = DateTime(2026, 1, 5, 10, 0, 0);
      final expectedExpiration = DateTime(2026, 1, 5, 10, 5, 0);

      expect(policy.getExpirationTime(cachedAt), expectedExpiration);
    });

    test('default TTL is 5 minutes', () {
      const policy = CachePolicy();
      expect(policy.ttl, const Duration(minutes: 5));
    });
  });

  group('CacheMetadata', () {
    test('fromJson creates valid metadata', () {
      final json = {
        'cachedAt': '2026-01-05T10:00:00.000',
        'version': 2,
      };

      final metadata = CacheMetadata.fromJson(json);

      expect(metadata.cachedAt, DateTime.parse('2026-01-05T10:00:00.000'));
      expect(metadata.version, 2);
    });

    test('fromJson uses default version if not provided', () {
      final json = {
        'cachedAt': '2026-01-05T10:00:00.000',
      };

      final metadata = CacheMetadata.fromJson(json);

      expect(metadata.version, 1);
    });

    test('toJson creates valid JSON', () {
      final metadata = CacheMetadata(
        cachedAt: DateTime.parse('2026-01-05T10:00:00.000'),
        version: 3,
      );

      final json = metadata.toJson();

      expect(json['cachedAt'], '2026-01-05T10:00:00.000');
      expect(json['version'], 3);
    });

    test('CacheMetadata.now creates metadata with current timestamp', () {
      final before = DateTime.now();
      final metadata = CacheMetadata.now();
      final after = DateTime.now();

      expect(metadata.cachedAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(metadata.cachedAt.isBefore(after.add(const Duration(seconds: 1))), true);
      expect(metadata.version, 1);
    });
  });
}
