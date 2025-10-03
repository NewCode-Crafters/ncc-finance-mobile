import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/validators.dart';
import 'package:bytebank/features/authentication/services/auth_exceptions.dart';
import 'package:bytebank/features/authentication/services/auth_service.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? successMessage;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    String? successMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    isAuthenticated,
    successMessage,
  ];
}

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  AuthNotifier(this._authService);

  Future<bool> login(String email, String password) async {
    if (!Validators.isValidEmail(email)) {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Por favor, insira um e-mail válido.',
      );
      notifyListeners();
      return false;
    }

    return await _executeAuthAction(() => _authService.login(email, password));
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!Validators.isValidEmail(email)) {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Por favor, insira um e-mail válido.',
      );
      notifyListeners();
      return false;
    }

    return await _executeAuthAction(() async {
      await _authService.signUp(name: name, email: email, password: password);
    });
  }

  Future<bool> _executeAuthAction(Future<void> Function() authAction) async {
    _state = AuthState(
      isLoading: true,
      isAuthenticated: _state.isAuthenticated,
      errorMessage: null,
      successMessage: null,
    );
    notifyListeners();

    try {
      await authAction();
      _state = _state.copyWith(isLoading: false, isAuthenticated: true);
      notifyListeners();
      return true;
    } on InvalidCredentialsException {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: "Credenciais inválidas. Por favor, tente novamente.",
      );
      notifyListeners();
      return false;
    } on UserNotFoundException {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: "Usuário não encontrado. Por favor, verifique o e-mail ou cadastre-se.",
      );
      notifyListeners();
      return false;
    } on EmailAlreadyInUseException {
      // NEW: Add this block
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Este e-mail já está em uso por outra conta.',
      );
      notifyListeners();
      return false;
    } on WeakPasswordException {
      // NEW: Add this block too
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'A senha é muito fraca. Por favor, escolha uma mais forte.',
      );
      notifyListeners();
      return false;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Ocorreu um erro desconhecido.',
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    _state = AuthState(
      isLoading: true,
      isAuthenticated: _state.isAuthenticated,
      errorMessage: null,
      successMessage: null,
    );
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email: email);
      _state = _state.copyWith(
        isLoading: false,
        successMessage: 'E-mail de redefinição de senha enviado. Por favor, verifique sua caixa de entrada.',
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Ocorreu um erro desconhecido.',
      );
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _authService.logout();
      _state = const AuthState();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao encerrar a sessão. Por favor, tente novamente.',
      );
    }

    notifyListeners();
  }

  void clearMessages() {
    // Using the constructor directly to ensure messages are cleared,
    // as copyWith doesn't handle null overrides correctly.
    _state = AuthState(
      isLoading: _state.isLoading,
      isAuthenticated: _state.isAuthenticated,
      errorMessage: null,
      successMessage: null,
    );
    notifyListeners();
  }

  // Only for Unit Test at the moment
  void updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
