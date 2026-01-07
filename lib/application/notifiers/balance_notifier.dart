import 'package:flutter/material.dart';
import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/domain/use_cases/balances/get_balances_use_case.dart';
import 'package:bytebank/domain/use_cases/balances/update_balance_use_case.dart';
import 'package:bytebank/application/core/async_status.dart';

/// Immutable state for BalanceNotifier.
///
/// Uses [AsyncStatus] to track operation status (idle/loading/success/error).
class BalanceState {
  final List<Balance> balances;
  final double totalBalance;
  final AsyncStatus status;
  final String? errorMessage;

  const BalanceState({
    this.balances = const [],
    this.totalBalance = 0.0,
    this.status = AsyncStatus.idle,
    this.errorMessage,
  });

  BalanceState copyWith({
    List<Balance>? balances,
    double? totalBalance,
    AsyncStatus? status,
    String? errorMessage,
  }) {
    return BalanceState(
      balances: balances ?? this.balances,
      totalBalance: totalBalance ?? this.totalBalance,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper getters for common status checks
  bool get isLoading => status.isLoading;
  bool get isIdle => status.isIdle;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;
}

class BalanceNotifier extends ChangeNotifier {
  final GetBalancesUseCase _getBalances;
  final UpdateBalanceUseCase _updateBalance;

  BalanceState _state = const BalanceState();
  BalanceState get state => _state;

  BalanceNotifier(this._getBalances, this._updateBalance);

  /// Fetches balances for the given userId.
  ///
  /// State transitions:
  /// - idle -> loading -> success (on success)
  /// - idle -> loading -> error (on failure)
  Future<void> fetchBalances({required String userId}) async {
    // Avoid redundant fetches if already loading
    if (_state.isLoading) return;

    _setState(_state.copyWith(status: AsyncStatus.loading));

    try {
      final balances = await _getBalances.call(userId: userId);
      final total = balances.fold<double>(
        0.0,
        (sum, item) => sum + item.amount,
      );
      _setState(
        _state.copyWith(
          balances: balances,
          totalBalance: total,
          status: AsyncStatus.success,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _setState(
        _state.copyWith(
          status: AsyncStatus.error,
          errorMessage: 'Failed to fetch balances: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateBalanceOnTransaction({
    required String userId,
    required String balanceId,
    required double transactionAmount,
    Object? batch,
  }) async {
    await _updateBalance.call(
      userId: userId,
      balanceId: balanceId,
      delta: transactionAmount,
      batch: batch,
    );
  }

  /// Internal method to update state and notify listeners.
  ///
  /// Only notifies if state actually changed (reduces redundant rebuilds).
  void _setState(BalanceState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
}
