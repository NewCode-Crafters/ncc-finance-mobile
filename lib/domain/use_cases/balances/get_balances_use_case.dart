import 'package:bytebank/domain/entities/balance.dart';
import 'package:bytebank/domain/repositories/balance_repository.dart';

class GetBalancesUseCase {
  final IBalanceRepository repository;

  GetBalancesUseCase(this.repository);

  Future<List<Balance>> call({required String userId}) async {
    return repository.getBalances(userId: userId);
  }
}
