import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository interface (port) for financial-transaction-related operations.
///
/// Implementations should exist in the infrastructure layer (adapters).
abstract class IFinancialTransactionRepository {
  /// Create a new transaction in the persistent store.
  ///
  /// Returns the created [FinancialTransactionEntity] including any generated id.
  Future<FinancialTransactionEntity> createTransaction(
    FinancialTransactionEntity transaction, {
    WriteBatch? batch,
  });

  /// Update an existing transaction.
  ///
  /// Returns the updated [FinancialTransactionEntity].
  Future<FinancialTransactionEntity> updateTransaction(
    FinancialTransactionEntity transaction,
  );

  /// Delete a transaction by id.
  Future<void> deleteTransaction(String transactionId);

  /// Get a single transaction by id.
  Future<FinancialTransactionEntity?> getTransaction(String transactionId);

  /// Stream transactions for a given balance or globally.
  ///
  /// The optional [balanceId] filters transactions for a specific balance.
  Stream<List<FinancialTransactionEntity>> watchTransactions({
    String? balanceId,
  });

  /// Fetch a paginated list of transactions.
  ///
  /// Use [limit] and [startAfterId] for pagination.
  Future<List<FinancialTransactionEntity>> getTransactions({
    int limit = 50,
    String? startAfterId,
    String? balanceId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
