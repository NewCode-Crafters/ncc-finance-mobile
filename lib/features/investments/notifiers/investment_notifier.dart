import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/features/investments/models/investment.dart';
import 'package:flutter_application_1/features/investments/services/investment_service.dart';

class InvestmentState {
  final List<Investment> investments;
  final bool isLoading;
  final double totalInvestments;
  final double totalFixedIncome;
  final double totalVariableIncome;
  final Map<String, double> chartData;

  InvestmentState({
    this.investments = const [],
    this.isLoading = false,
    this.totalInvestments = 0.0,
    this.totalFixedIncome = 0.0,
    this.totalVariableIncome = 0.0,
    this.chartData = const {}, // Default to an empty map
  });
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
}
