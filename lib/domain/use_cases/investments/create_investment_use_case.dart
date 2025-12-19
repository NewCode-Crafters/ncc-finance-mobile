import 'package:bytebank/domain/entities/investment.dart';
import 'package:bytebank/domain/repositories/investment_repository.dart';

class CreateInvestmentUseCase {
  final IInvestmentRepository repository;

  CreateInvestmentUseCase({required this.repository});

  Future<Investment> call({
    required String userId,
    required Investment investment,
  }) async {
    return await repository.createInvestment(
      userId: userId,
      investment: investment,
    );
  }
}
