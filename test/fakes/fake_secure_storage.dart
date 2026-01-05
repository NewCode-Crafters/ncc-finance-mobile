import 'package:bytebank/core/security/i_secure_storage.dart';

/// Implementação fake de [ISecureStorage] para testes.
/// 
/// Armazena valores em memória (Map), sem usar o plugin real.
/// Útil para testes unitários que não precisam da infraestrutura
/// real de Keychain/Keystore.
class FakeSecureStorage implements ISecureStorage {
  final Map<String, String> _storage = {};

  /// Flag para simular erros durante operações.
  bool shouldThrowError = false;

  /// Mensagem de erro customizada quando [shouldThrowError] é true.
  String errorMessage = 'Simulated error';

  @override
  Future<void> save(String key, String value) async {
    if (shouldThrowError) {
      throw SecureStorageException(errorMessage);
    }
    _storage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    if (shouldThrowError) {
      throw SecureStorageException(errorMessage);
    }
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    if (shouldThrowError) {
      throw SecureStorageException(errorMessage);
    }
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    if (shouldThrowError) {
      throw SecureStorageException(errorMessage);
    }
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    if (shouldThrowError) {
      throw SecureStorageException(errorMessage);
    }
    return _storage.containsKey(key);
  }

  /// Método helper para testes: retorna o conteúdo completo do storage.
  Map<String, String> getAll() => Map.unmodifiable(_storage);

  /// Método helper para testes: limpa o storage sem lançar exceções.
  void clear() => _storage.clear();
}
