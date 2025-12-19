import 'package:bytebank/domain/entities/balance.dart';

/// Repository interface for balances. Implementations should live in the
/// infrastructure layer (e.g. Firestore-backed repository).
abstract class IBalanceRepository {
  /// Returns all balances for a given `userId`.
  Future<List<Balance>> getBalances({required String userId});

  /// Returns a single balance by its id.
  Future<Balance> getBalanceById({required String userId, required String balanceId});

  /// Updates a balance. Should persist and return the updated Balance.
  Future<Balance> updateBalance({required String userId, required Balance balance});

  /// Creates a new balance record.
  Future<Balance> createBalance({required String userId, required Balance balance});

  /// Listens to balance changes for a user as a stream.
  Stream<List<Balance>> listenBalances({required String userId});

  /// Optionally perform multiple balance updates atomically using a batch
  /// provided by infrastructure (e.g. Firestore batch). Implementations may
  /// expose an overload that accepts a batch object — keep the interface
  /// focused on domain types.
  ///
  /// Perform an atomic delta update to a balance's amount. The `delta`
  /// is added to the stored amount (positive for credit, negative for debit).
  /// `batch` is an opaque object forwarded to infrastructure implementations
  /// (e.g. Firestore's `WriteBatch`) and may be null.
  Future<void> updateBalanceByDelta({
    required String userId,
    required String balanceId,
    required double delta,
    Object? batch,
  });
}
