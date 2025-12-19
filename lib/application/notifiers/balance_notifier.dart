import 'package:flutter/material.dart';
import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/domain/use_cases/balances/get_balances_use_case.dart';
import 'package:bytebank/domain/use_cases/balances/update_balance_use_case.dart';

class BalanceState {
  final List<Balance> balances;
  final double totalBalance;
  final bool isLoading;

  BalanceState({
    this.balances = const [],
    this.totalBalance = 0.0,
    this.isLoading = false,
  });
}

class BalanceNotifier extends ChangeNotifier {
  final GetBalancesUseCase _getBalances;
  final UpdateBalanceUseCase _updateBalance;

  BalanceState _state = BalanceState();
  BalanceState get state => _state;

  BalanceNotifier(this._getBalances, this._updateBalance);

  Future<void> fetchBalances({required String userId}) async {
    Future.microtask(() {
      _state = BalanceState(isLoading: true);
      notifyListeners();
    });

    try {
      final balances = await _getBalances.call(userId: userId);
      final total = balances.fold<double>(
        0.0,
        (sum, item) => sum + item.amount,
      );
      _state = BalanceState(
        balances: balances,
        totalBalance: total,
        isLoading: false,
      );
    } catch (_) {
      _state = BalanceState(balances: [], totalBalance: 0.0, isLoading: false);
    }

    notifyListeners();
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
}
