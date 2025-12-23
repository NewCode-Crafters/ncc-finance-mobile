import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/use_cases/investments/get_investments_use_case.dart';
import 'package:bytebank/domain/use_cases/investments/create_investment_use_case.dart';
import 'package:bytebank/domain/use_cases/investments/delete_investment_use_case.dart';
import 'package:bytebank/domain/exceptions/investment_exception.dart';

class InvestmentState {
  final List<Investment> investments;
  final bool isLoading;
  final String? errorMessage;
  final double totalInvestments;
  final double totalFixedIncome;
  final double totalVariableIncome;
  final Map<String, double> chartData;

  const InvestmentState({
    this.investments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.totalInvestments = 0.0,
    this.totalFixedIncome = 0.0,
    this.totalVariableIncome = 0.0,
    this.chartData = const {},
  });

  InvestmentState copyWith({
    List<Investment>? investments,
    bool? isLoading,
    String? errorMessage,
    double? totalInvestments,
    double? totalFixedIncome,
    double? totalVariableIncome,
    Map<String, double>? chartData,
  }) {
    return InvestmentState(
      investments: investments ?? this.investments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      totalInvestments: totalInvestments ?? this.totalInvestments,
      totalFixedIncome: totalFixedIncome ?? this.totalFixedIncome,
      totalVariableIncome: totalVariableIncome ?? this.totalVariableIncome,
      chartData: chartData ?? this.chartData,
    );
  }
}

/// A ChangeNotifier that exposes investments and derived statistics.
///
/// It uses fetch-based updates via `GetInvestmentsUseCase`.
class InvestmentNotifier extends ChangeNotifier {
  final GetInvestmentsUseCase _getInvestments;
  final CreateInvestmentUseCase _createInvestment;
  final DeleteInvestmentUseCase _deleteInvestment;

  InvestmentState _state = const InvestmentState();
  InvestmentState get state => _state;

  InvestmentNotifier(
    this._getInvestments,
    this._createInvestment,
    this._deleteInvestment,
  );

  /// Fetch investments once (legacy/tests).
  Future<void> fetchInvestments({required String userId}) async {
    _state = const InvestmentState(isLoading: true);
    notifyListeners();

    try {
      final investments = await _getInvestments.call(userId: userId);

      final total = investments.fold<double>(
        0.0,
        (sum, inv) => sum + inv.amount,
      );

      final fixed = investments
          .where((inv) => inv.category == 'FIXED_INCOME')
          .fold<double>(0.0, (sum, inv) => sum + inv.amount);

      final variable = investments
          .where((inv) => inv.category == 'VARIABLE_INCOME')
          .fold<double>(0.0, (sum, inv) => sum + inv.amount);

      final chartData = <String, double>{};
      for (final investment in investments) {
        chartData.update(
          investment.type,
          (value) => value + investment.amount,
          ifAbsent: () => investment.amount,
        );
      }

      _state = InvestmentState(
        investments: investments,
        isLoading: false,
        totalInvestments: total,
        totalFixedIncome: fixed,
        totalVariableIncome: variable,
        chartData: chartData,
      );
    } catch (e) {
      _state = const InvestmentState(isLoading: false);
    }

    notifyListeners();
  }

  Future<void> createInvestment({
    required String userId,
    required Investment investment,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _createInvestment.call(userId: userId, investment: investment);
      await fetchInvestments(userId: userId);
    } on InvestmentException catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.message);
      notifyListeners();
      return;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Um erro inesperado ocorreu.',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  Future<void> deleteInvestment({
    required String userId,
    required String investmentId,
  }) async {
    try {
      await _deleteInvestment.call(userId: userId, investmentId: investmentId);
      await fetchInvestments(userId: userId);
    } on InvestmentException catch (e) {
      _state = _state.copyWith(errorMessage: e.message);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Um erro inesperado ocorreu.');
      notifyListeners();
    }
  }

  void clearError() {
    if (_state.errorMessage != null) {
      _state = _state.copyWith(errorMessage: null);
    }
  }
}
