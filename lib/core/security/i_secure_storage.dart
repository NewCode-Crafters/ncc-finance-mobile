/// Interface abstrata para armazenamento seguro de dados sensíveis.
/// 
/// Esta interface permite trocar a implementação concreta (ex: flutter_secure_storage)
/// por fakes/mocks durante os testes, mantendo a arquitetura limpa e testável.
/// 
/// Casos de uso:
/// - Armazenar tokens de autenticação
/// - Armazenar PINs ou senhas temporárias
/// - Armazenar chaves de criptografia
/// - Armazenar preferências sensíveis
abstract class ISecureStorage {
  /// Salva um valor de forma segura usando uma chave.
  /// 
  /// O valor é criptografado e armazenado no Keychain (iOS) ou Keystore (Android).
  /// 
  /// Throws [SecureStorageException] se houver erro ao salvar.
  Future<void> save(String key, String value);

  /// Lê um valor armazenado pela chave.
  /// 
  /// Retorna `null` se a chave não existir.
  /// 
  /// Throws [SecureStorageException] se houver erro ao ler.
  Future<String?> read(String key);

  /// Remove um valor pela chave.
  /// 
  /// Não lança exceção se a chave não existir.
  /// 
  /// Throws [SecureStorageException] se houver erro ao deletar.
  Future<void> delete(String key);

  /// Remove todos os valores armazenados.
  /// 
  /// Útil para logout ou reset completo do app.
  /// 
  /// Throws [SecureStorageException] se houver erro ao limpar.
  Future<void> deleteAll();

  /// Verifica se uma chave existe no armazenamento.
  /// 
  /// Retorna `true` se a chave existe, `false` caso contrário.
  Future<bool> containsKey(String key);
}

/// Exceção lançada quando há erro no armazenamento seguro.
class SecureStorageException implements Exception {
  final String message;
  final dynamic originalError;

  const SecureStorageException(this.message, [this.originalError]);

  @override
  String toString() => 'SecureStorageException: $message';
}
