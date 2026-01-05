import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/core/security/i_secure_storage.dart';
import '../../fakes/fake_secure_storage.dart';

void main() {
  group('SecureStorageService', () {
    late ISecureStorage secureStorage;

    setUp(() {
      // Usa fake para não depender do plugin real nos testes
      secureStorage = FakeSecureStorage();
    });

    test('deve salvar e recuperar um valor', () async {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      await secureStorage.save(key, value);
      final result = await secureStorage.read(key);

      // Assert
      expect(result, equals(value));
    });

    test('deve retornar null para chave inexistente', () async {
      // Act
      final result = await secureStorage.read('non_existent_key');

      // Assert
      expect(result, isNull);
    });

    test('deve deletar um valor específico', () async {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';
      await secureStorage.save(key, value);

      // Act
      await secureStorage.delete(key);
      final result = await secureStorage.read(key);

      // Assert
      expect(result, isNull);
    });

    test('deve deletar todos os valores', () async {
      // Arrange
      await secureStorage.save('key1', 'value1');
      await secureStorage.save('key2', 'value2');
      await secureStorage.save('key3', 'value3');

      // Act
      await secureStorage.deleteAll();
      final result1 = await secureStorage.read('key1');
      final result2 = await secureStorage.read('key2');
      final result3 = await secureStorage.read('key3');

      // Assert
      expect(result1, isNull);
      expect(result2, isNull);
      expect(result3, isNull);
    });

    test('deve verificar se uma chave existe', () async {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';
      await secureStorage.save(key, value);

      // Act
      final exists = await secureStorage.containsKey(key);
      final notExists = await secureStorage.containsKey('non_existent');

      // Assert
      expect(exists, isTrue);
      expect(notExists, isFalse);
    });

    test('deve sobrescrever valor existente', () async {
      // Arrange
      const key = 'test_key';
      const oldValue = 'old_value';
      const newValue = 'new_value';

      // Act
      await secureStorage.save(key, oldValue);
      await secureStorage.save(key, newValue);
      final result = await secureStorage.read(key);

      // Assert
      expect(result, equals(newValue));
    });

    test('deve suportar múltiplas chaves simultaneamente', () async {
      // Arrange & Act
      await secureStorage.save('auth_token', 'token_123');
      await secureStorage.save('refresh_token', 'refresh_456');
      await secureStorage.save('user_pin', '1234');

      // Assert
      expect(await secureStorage.read('auth_token'), equals('token_123'));
      expect(await secureStorage.read('refresh_token'), equals('refresh_456'));
      expect(await secureStorage.read('user_pin'), equals('1234'));
    });

    test('deve lançar exceção quando fake está configurado para erro', () async {
      // Arrange
      final fake = FakeSecureStorage();
      fake.shouldThrowError = true;
      fake.errorMessage = 'Erro simulado de storage';

      // Act & Assert
      expect(
        () async => await fake.save('key', 'value'),
        throwsA(isA<SecureStorageException>()),
      );
      expect(
        () async => await fake.read('key'),
        throwsA(isA<SecureStorageException>()),
      );
      expect(
        () async => await fake.delete('key'),
        throwsA(isA<SecureStorageException>()),
      );
      expect(
        () async => await fake.deleteAll(),
        throwsA(isA<SecureStorageException>()),
      );
      expect(
        () async => await fake.containsKey('key'),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });
}
