import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';

class GetInvestmentsUseCase {
  final IInvestmentRepository repository;

  GetInvestmentsUseCase({required this.repository});

  Future<List<Investment>> call({required String userId}) async {
    return await repository.getInvestments(userId: userId);
  }
}
