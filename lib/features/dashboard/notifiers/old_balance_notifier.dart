import 'package:flutter/material.dart';
import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';

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
  final IBalanceRepository _balanceService;
  BalanceState _state = BalanceState();

  BalanceState get state => _state;

  BalanceNotifier(this._balanceService);

  // ok
  Future<void> fetchBalances({required String userId}) async {
    Future.microtask(() {
      _state = BalanceState(isLoading: true);
      notifyListeners();
    });

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
