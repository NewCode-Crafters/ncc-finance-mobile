import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/validators.dart';
import 'package:flutter_application_1/features/authentication/services/auth_exceptions.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, isAuthenticated];
}

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  AuthNotifier(this._authService);

  Future<void> login(String email, String password) async {
    if (!Validators.isValidEmail(email)) {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Please enter a valid email.',
      );
      notifyListeners();
      return;
    }

    await _executeAuthAction(() => _authService.login(email, password));
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!Validators.isValidEmail(email)) {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Please enter a valid email.',
      );
      notifyListeners();
      return;
    }
    await _executeAuthAction(
      () => _authService.signUp(name: name, email: email, password: password),
    );
  }

  Future<void> _executeAuthAction(Future<void> Function() authAction) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);

    try {
      await authAction();
      _state = _state.copyWith(isLoading: false, isAuthenticated: true);
    } on InvalidCredentialsException {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: "Invalid credentials. Please try again.",
      );
    } on UserNotFoundException {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: "User not found. Please check the email or sign up.",
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'An unknown error occurred.',
      );
    }

    notifyListeners();
  }
}
