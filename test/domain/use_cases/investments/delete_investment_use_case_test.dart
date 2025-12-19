import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/use_cases/investments/delete_investment_use_case.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';
import 'package:bytebank/domain/entities/investment.dart';

class _FakeInvestmentRepository implements IInvestmentRepository {
  String? lastDeletedId;

  @override
  Future<void> deleteInvestment({
    required String userId,
    required String investmentId,
  }) async {
    lastDeletedId = investmentId;
  }

  @override
  Future<Investment> createInvestment({
    required String userId,
    required Investment investment,
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
  test('DeleteInvestmentUseCase forwards delete to repository', () async {
    final repo = _FakeInvestmentRepository();
    final useCase = DeleteInvestmentUseCase(repository: repo);

    await useCase.call(userId: 'user-1', investmentId: 'inv-123');

    expect(repo.lastDeletedId, 'inv-123');
  });
}
