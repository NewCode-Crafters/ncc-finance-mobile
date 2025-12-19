import 'package:bytebank/domain/repositories/investment_repository.dart';

class DeleteInvestmentUseCase {
  final IInvestmentRepository repository;

  DeleteInvestmentUseCase({required this.repository});

  Future<void> call({
    required String userId,
    required String investmentId,
  }) async {
    return await repository.deleteInvestment(
      userId: userId,
      investmentId: investmentId,
    );
  }
}
