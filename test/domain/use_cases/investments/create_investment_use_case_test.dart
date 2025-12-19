import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/use_cases/investments/create_investment_use_case.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';

class _FakeInvestmentRepository implements IInvestmentRepository {
  Investment? lastCreated;

  @override
  Future<Investment> createInvestment({
    required String userId,
    required Investment investment,
  }) async {
    lastCreated = investment.copyWith(id: 'generated-id');
    return lastCreated!;
  }

  @override
  Future<void> deleteInvestment({
    required String userId,
    required String investmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Investment> getInvestmentById({
    required String userId,
    required String investmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Investment>> getInvestments({required String userId}) {
    throw UnimplementedError();
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
    return const Stream.empty();
  }
}

void main() {
  test(
    'CreateInvestmentUseCase forwards call to repository and returns created investment',
    () async {
      final repo = _FakeInvestmentRepository();
      final useCase = CreateInvestmentUseCase(repository: repo);

      final investment = Investment(
        id: '',
        name: 'Test',
        amount: 100.0,
        category: 'Stocks',
        type: 'Long',
        investedAt: DateTime.utc(2024, 1, 1),
        balanceId: 'balance-1',
      );

      final result = await useCase.call(
        userId: 'user-1',
        investment: investment,
      );

      expect(result.id, 'generated-id');
      expect(repo.lastCreated, isNotNull);
      expect(repo.lastCreated!.name, 'Test');
    },
  );
}
