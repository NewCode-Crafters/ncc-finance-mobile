import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/application/notifiers/investment_notifier.dart';
import 'package:bytebank/domain/use_cases/investments/get_investments_use_case.dart';
import 'package:bytebank/domain/use_cases/investments/create_investment_use_case.dart';
import 'package:bytebank/domain/use_cases/investments/delete_investment_use_case.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeInvestmentRepository implements IInvestmentRepository {
  final List<Investment> Function() provider;
  FakeInvestmentRepository(this.provider);

  @override
  Future<Investment> createInvestment({
    required String userId,
    required Investment investment,
  }) async {
    // return the investment with an assigned id
    return investment.copyWith(id: 'created-id');
  }

  @override
  Future<void> deleteInvestment({
    required String userId,
    required String investmentId,
  }) async {
    return;
  }

  @override
  Future<Investment> getInvestmentById({
    required String userId,
    required String investmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Investment>> getInvestments({required String userId}) async {
    return provider();
  }

  @override
  Future<Investment> updateInvestment({
    required String userId,
    required Investment investment,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Investment>> listenInvestments({required String userId}) {
    return Stream.value(provider());
  }
}

void main() {
  late GetInvestmentsUseCase fakeGet;
  late CreateInvestmentUseCase fakeCreate;
  late DeleteInvestmentUseCase fakeDelete;
  late InvestmentNotifier investmentNotifier;

  setUp(() {
    // default provider returns empty list
    final fakeRepo = FakeInvestmentRepository(() => []);
    fakeGet = GetInvestmentsUseCase(repository: fakeRepo);
    fakeCreate = CreateInvestmentUseCase(repository: fakeRepo);
    fakeDelete = DeleteInvestmentUseCase(repository: fakeRepo);
    investmentNotifier = InvestmentNotifier(fakeGet, fakeCreate, fakeDelete);
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

      final fakeRepo = FakeInvestmentRepository(() => fakeInvestments);
      fakeGet = GetInvestmentsUseCase(repository: fakeRepo);
      fakeCreate = CreateInvestmentUseCase(repository: fakeRepo);
      fakeDelete = DeleteInvestmentUseCase(repository: fakeRepo);
      investmentNotifier = InvestmentNotifier(fakeGet, fakeCreate, fakeDelete);

      await investmentNotifier.fetchInvestments(userId: 'test_user');

      expect(investmentNotifier.state.investments, fakeInvestments);
      expect(investmentNotifier.state.isLoading, isFalse);
    },
  );

  test('fetchInvestments should handle no investments case', () async {
    final fakeRepo = FakeInvestmentRepository(() => []);
    fakeGet = GetInvestmentsUseCase(repository: fakeRepo);
    fakeCreate = CreateInvestmentUseCase(repository: fakeRepo);
    fakeDelete = DeleteInvestmentUseCase(repository: fakeRepo);
    investmentNotifier = InvestmentNotifier(fakeGet, fakeCreate, fakeDelete);

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

    final fakeRepo = FakeInvestmentRepository(() => fakeInvestments);
    fakeGet = GetInvestmentsUseCase(repository: fakeRepo);
    fakeCreate = CreateInvestmentUseCase(repository: fakeRepo);
    fakeDelete = DeleteInvestmentUseCase(repository: fakeRepo);
    investmentNotifier = InvestmentNotifier(fakeGet, fakeCreate, fakeDelete);

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

      final fakeRepo2 = FakeInvestmentRepository(() => fakeInvestments);
      fakeGet = GetInvestmentsUseCase(repository: fakeRepo2);
      fakeCreate = CreateInvestmentUseCase(repository: fakeRepo2);
      fakeDelete = DeleteInvestmentUseCase(repository: fakeRepo2);
      investmentNotifier = InvestmentNotifier(fakeGet, fakeCreate, fakeDelete);

      await investmentNotifier.fetchInvestments(userId: 'test_user');

      final chartData = investmentNotifier.state.chartData;
      expect(chartData, isA<Map<String, double>>());
      expect(chartData['GOVERNMENT_BOND'], 1250.0); // 1000.0 + 250.0
      expect(chartData['STOCK_MARKET'], 500.0);
    },
  );
}
