import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/dashboard/models/balance.dart';
import 'package:flutter_application_1/features/dashboard/services/balance_service.dart';

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
  final BalanceService _balanceService;
  BalanceState _state = BalanceState();

  BalanceState get state => _state;

  BalanceNotifier(this._balanceService);

  Future<void> fetchBalances({required String userId}) async {
    _state = BalanceState(isLoading: true);
    notifyListeners();

    try {
      final balances = await _balanceService.getBalances(userId: userId);

      final total = balances.fold<double>(
        0.0,
        (sum, item) => sum + item.amount,
      );

      _state = BalanceState(
        balances: balances,
        totalBalance: total,
        isLoading: false,
      );
    } catch (e) {
      _state = BalanceState(balances: [], totalBalance: 0.0, isLoading: false);
    }

    notifyListeners();
  }
}
