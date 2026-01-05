import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bytebank/core/security/i_secure_storage.dart';

/// Implementação concreta de [ISecureStorage] usando flutter_secure_storage.
/// 
/// Esta classe encapsula o plugin flutter_secure_storage, fornecendo uma
/// interface consistente e tratamento de erros padronizado.
/// 
/// - iOS: usa Keychain
/// - Android: usa Keystore com criptografia AES
/// - Web/Desktop: usa armazenamento local seguro quando disponível
class SecureStorageService implements ISecureStorage {
  final FlutterSecureStorage _storage;

  /// Cria uma instância do serviço.
  /// 
  /// Aceita uma instância customizada de [FlutterSecureStorage] para testes,
  /// mas usa configurações padrão quando não especificado.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<void> save(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException(
        'Erro ao salvar valor com chave "$key"',
        e,
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException(
        'Erro ao ler valor com chave "$key"',
        e,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException(
        'Erro ao deletar valor com chave "$key"',
        e,
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException(
        'Erro ao deletar todos os valores',
        e,
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw SecureStorageException(
        'Erro ao verificar existência da chave "$key"',
        e,
      );
    }
  }
}
