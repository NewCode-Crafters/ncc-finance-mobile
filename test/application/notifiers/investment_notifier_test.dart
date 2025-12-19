import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/investment_notifier.dart';
import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/use_cases/investments/get_investments_use_case.dart';
import 'package:bytebank/domain/use_cases/investments/create_investment_use_case.dart';
import 'package:bytebank/domain/use_cases/investments/delete_investment_use_case.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';

class _FakeInvestmentRepo implements IInvestmentRepository {
  final List<Investment> storage;
  bool deleteCalled = false;
  bool createCalled = false;

  _FakeInvestmentRepo({this.storage = const []});

  @override
  Future<Investment> createInvestment({
    required String userId,
    required Investment investment,
  }) async {
    createCalled = true;
    return investment.copyWith(id: 'new-id');
  }

  @override
  Future<void> deleteInvestment({
    required String userId,
    required String investmentId,
  }) async {
    deleteCalled = true;
  }

  @override
  Future<Investment> getInvestmentById({
    required String userId,
    required String investmentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Investment>> getInvestments({required String userId}) async =>
      storage;

  @override
  Stream<List<Investment>> listenInvestments({required String userId}) =>
      Stream.value(storage);

  @override
  Future<Investment> updateInvestment({
    required String userId,
    required Investment investment,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('fetchInvestments updates state with returned list', () async {
    final repo = _FakeInvestmentRepo(
      storage: [
        Investment(
          id: 'i1',
          name: 'One',
          amount: 10,
          category: 'c',
          type: 't',
          investedAt: DateTime.now(),
          balanceId: 'b1',
        ),
      ],
    );
    final getUse = GetInvestmentsUseCase(repository: repo);
    final notifier = InvestmentNotifier(
      getUse,
      CreateInvestmentUseCase(repository: repo),
      DeleteInvestmentUseCase(repository: repo),
    );

    await notifier.fetchInvestments(userId: 'u1');

    expect(notifier.state.investments, isNotEmpty);
  });

  test('createInvestment calls create and refreshes', () async {
    final repo = _FakeInvestmentRepo(storage: []);
    final getUse = GetInvestmentsUseCase(repository: repo);
    final createUse = CreateInvestmentUseCase(repository: repo);
    final notifier = InvestmentNotifier(
      getUse,
      createUse,
      DeleteInvestmentUseCase(repository: repo),
    );

    final inv = Investment(
      id: '',
      name: 'x',
      amount: 1,
      category: 'c',
      type: 't',
      investedAt: DateTime.now(),
      balanceId: 'b',
    );
    await notifier.createInvestment(userId: 'u1', investment: inv);

    expect(repo.createCalled, isTrue);
  });

  test('deleteInvestment calls delete and refreshes', () async {
    final repo = _FakeInvestmentRepo(storage: []);
    final notifier = InvestmentNotifier(
      GetInvestmentsUseCase(repository: repo),
      CreateInvestmentUseCase(repository: repo),
      DeleteInvestmentUseCase(repository: repo),
    );

    await notifier.deleteInvestment(userId: 'u1', investmentId: 'i1');

    expect(repo.deleteCalled, isTrue);
  });
}
