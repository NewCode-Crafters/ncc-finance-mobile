import 'package:bytebank/features/investments/models/investment.dart';
import 'package:bytebank/features/investments/notifiers/investment_notifier.dart';
import 'package:bytebank/features/investments/services/investment_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'investment_notifier_test.mocks.dart';

@GenerateMocks([InvestmentService])
void main() {
  late MockInvestmentService mockInvestmentService;
  late InvestmentNotifier investmentNotifier;

  setUp(() {
    mockInvestmentService = MockInvestmentService();
    investmentNotifier = InvestmentNotifier(mockInvestmentService);
  });

  test(
    'fetchInvestments should update state with a list of investments',
    () async {
      final fakeInvestments = [
        Investment(
          id: '1',
          name: 'Tesouro Selic',
          amount: 5000.0,
          category: 'FIXED_INCOME',
          type: 'GOVERNMENT_BOND',
          investedAt: DateTime.now(),
          balanceId: 'b1',
        ),
      ];

      when(
        mockInvestmentService.getInvestments(userId: anyNamed('userId')),
      ).thenAnswer((_) async => fakeInvestments);

      await investmentNotifier.fetchInvestments(userId: 'test_user');

      expect(investmentNotifier.state.investments, fakeInvestments);
      expect(investmentNotifier.state.isLoading, isFalse);
    },
  );

  test('fetchInvestments should handle no investments case', () async {
    when(
      mockInvestmentService.getInvestments(userId: anyNamed('userId')),
    ).thenAnswer((_) async => []);

    await investmentNotifier.fetchInvestments(userId: 'test_user');

    expect(investmentNotifier.state.investments, isEmpty);
    expect(investmentNotifier.state.isLoading, isFalse);
  });

  test('fetchInvestments should correctly calculate summary totals', () async {
    final fakeInvestments = [
      Investment(
        id: '1',
        name: 'Fixed 1',
        amount: 1000.0,
        category: 'FIXED_INCOME',
        type: 'T1',
        investedAt: DateTime.now(),
        balanceId: 'b1',
      ),
      Investment(
        id: '2',
        name: 'Variable 1',
        amount: 500.0,
        category: 'VARIABLE_INCOME',
        type: 'T2',
        investedAt: DateTime.now(),
        balanceId: 'b1',
      ),
      Investment(
        id: '3',
        name: 'Fixed 2',
        amount: 250.50,
        category: 'FIXED_INCOME',
        type: 'T3',
        investedAt: DateTime.now(),
        balanceId: 'b1',
      ),
    ];

    when(
      mockInvestmentService.getInvestments(userId: anyNamed('userId')),
    ).thenAnswer((_) async => fakeInvestments);

    await investmentNotifier.fetchInvestments(userId: 'test_user');

    expect(investmentNotifier.state.totalInvestments, 1750.50);
    expect(investmentNotifier.state.totalFixedIncome, 1250.50);
    expect(investmentNotifier.state.totalVariableIncome, 500.0);
    expect(investmentNotifier.state.isLoading, isFalse);
  });

  test(
    'fetchInvestments should prepare aggregated data for the chart',
    () async {
      final fakeInvestments = [
        Investment(
          id: '1',
          name: 'Fixed 1',
          amount: 1000.0,
          category: 'FIXED_INCOME',
          type: 'GOVERNMENT_BOND',
          investedAt: DateTime.now(),
          balanceId: 'b1',
        ),
        Investment(
          id: '2',
          name: 'Variable 1',
          amount: 500.0,
          category: 'VARIABLE_INCOME',
          type: 'STOCK_MARKET',
          investedAt: DateTime.now(),
          balanceId: 'b1',
        ),
        Investment(
          id: '3',
          name: 'Fixed 2',
          amount: 250.0,
          category: 'FIXED_INCOME',
          type: 'GOVERNMENT_BOND',
          investedAt: DateTime.now(),
          balanceId: 'b1',
        ),
      ];

      when(
        mockInvestmentService.getInvestments(userId: anyNamed('userId')),
      ).thenAnswer((_) async => fakeInvestments);

      await investmentNotifier.fetchInvestments(userId: 'test_user');

      final chartData = investmentNotifier.state.chartData;
      expect(chartData, isA<Map<String, double>>());
      expect(chartData['GOVERNMENT_BOND'], 1250.0); // 1000.0 + 250.0
      expect(chartData['STOCK_MARKET'], 500.0);
    },
  );
}
