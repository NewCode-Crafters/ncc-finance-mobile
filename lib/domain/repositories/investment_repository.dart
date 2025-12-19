import 'package:bytebank/domain/entities/investment.dart';

/// Repository interface for investments.
/// Implementations should be provided by the infrastructure layer.
abstract class IInvestmentRepository {
  /// Returns all investments for a given user.
  Future<List<Investment>> getInvestments({required String userId});

  /// Returns a single investment by id.
  Future<Investment> getInvestmentById({
    required String userId,
    required String investmentId,
  });

  /// Creates a new investment and returns the created entity (including id).
  Future<Investment> createInvestment({
    required String userId,
    required Investment investment,
  });

  /// Deletes an investment.
  Future<void> deleteInvestment({
    required String userId,
    required String investmentId,
  });

  /// Updates an investment and returns the updated entity.
  Future<Investment> updateInvestment({
    required String userId,
    required Investment investment,
  });

  /// Stream investments for a user (realtime updates).
  Stream<List<Investment>> listenInvestments({required String userId});
}
