import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/use_cases/investments/get_investments_use_case.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';

class _FakeInvestmentRepository implements IInvestmentRepository {
  @override
  Future<List<Investment>> getInvestments({required String userId}) async {
    return [
      Investment(
        id: 'inv-1',
        name: 'One',
        amount: 50,
        category: 'Bonds',
        type: 'Short',
        investedAt: DateTime.utc(2024, 2, 2),
        balanceId: 'b1',
      ),
    ];
  }

  @override
  Future<Investment> createInvestment({
    required String userId,
    required Investment investment,
  }) {
    throw UnimplementedError();
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
  test('GetInvestmentsUseCase returns list from repository', () async {
    final repo = _FakeInvestmentRepository();
    final useCase = GetInvestmentsUseCase(repository: repo);

    final list = await useCase.call(userId: 'user-1');

    expect(list, isNotEmpty);
    expect(list.first.id, 'inv-1');
  });
}
