import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/features/investments/models/investment.dart';
import 'package:flutter_application_1/features/investments/services/investment_exceptions.dart';
import 'package:flutter_application_1/features/investments/services/investment_service.dart';

class InvestmentState {
  final List<Investment> investments;
  final bool isLoading;
  final double totalInvestments;
  final double totalFixedIncome;
  final double totalVariableIncome;
  final Map<String, double> chartData;
  final String? errorMessage;

  InvestmentState({
    this.investments = const [],
    this.isLoading = false,
    this.totalInvestments = 0.0,
    this.totalFixedIncome = 0.0,
    this.totalVariableIncome = 0.0,
    this.chartData = const {}, // Default to an empty map
    this.errorMessage,
  });

  InvestmentState copyWith({
    List<Investment>? investments,
    bool? isLoading,
    double? totalInvestments,
    double? totalFixedIncome,
    double? totalVariableIncome,
    Map<String, double>? chartData,
    String? errorMessage,
  }) {
    return InvestmentState(
      investments: investments ?? this.investments,
      isLoading: isLoading ?? this.isLoading,
      totalInvestments: totalInvestments ?? this.totalInvestments,
      totalFixedIncome: totalFixedIncome ?? this.totalFixedIncome,
      totalVariableIncome: totalVariableIncome ?? this.totalVariableIncome,
      chartData: chartData ?? this.chartData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class InvestmentNotifier extends ChangeNotifier {
  final InvestmentService _investmentService;
  InvestmentState _state = InvestmentState();

  InvestmentState get state => _state;

  InvestmentNotifier(this._investmentService);

  Future<void> fetchInvestments({required String userId}) async {
    _state = InvestmentState(isLoading: true);
    notifyListeners();

    try {
      final investments = await _investmentService.getInvestments(
        userId: userId,
      );

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
        // If the type is already in the map, add to its value. Otherwise, create it.
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
      _state = InvestmentState(isLoading: false);
    }

    notifyListeners();
  }

  Future<void> deleteInvestment({
    required String userId,
    required String investmentId,
  }) async {
    try {
      await _investmentService.deleteInvestment(
        userId: userId,
        investmentId: investmentId,
      );
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
