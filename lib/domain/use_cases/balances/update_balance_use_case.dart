import 'package:bytebank/domain/repositories/balance_repository.dart';

class UpdateBalanceUseCase {
  final IBalanceRepository repository;

  UpdateBalanceUseCase(this.repository);

  /// Update a balance by a delta amount. Positive delta credits, negative debits.
  Future<void> call({required String userId, required String balanceId, required double delta, Object? batch}) async {
    return repository.updateBalanceByDelta(userId: userId, balanceId: balanceId, delta: delta, batch: batch);
  }
}
