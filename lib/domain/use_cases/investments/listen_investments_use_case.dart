import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';

class ListenInvestmentsUseCase {
  final IInvestmentRepository repository;

  ListenInvestmentsUseCase({required this.repository});

  Stream<List<Investment>> call({required String userId}) {
    return repository.listenInvestments(userId: userId);
  }
}
