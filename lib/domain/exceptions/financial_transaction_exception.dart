/// Domain-level exceptions for financial transaction operations.
///
/// Keep domain exceptions lightweight and expressive so infrastructure
/// adapters can map external errors (e.g., Firebase exceptions) to
/// domain errors that use-cases and presentation layers understand.
abstract class FinancialTransactionException implements Exception {
  final String message;
  const FinancialTransactionException([
    this.message = 'Financial transaction error',
  ]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when an operation attempts to access a transaction that doesn't exist.
class FinancialTransactionNotFoundException
    extends FinancialTransactionException {
  const FinancialTransactionNotFoundException([
    super.message = 'Transaction not found',
  ]);
}

/// Thrown when validation of a transaction fails (business rule violation).
class FinancialTransactionValidationException
    extends FinancialTransactionException {
  const FinancialTransactionValidationException([
    super.message = 'Invalid transaction data',
  ]);
}

/// Thrown when a repository or external data source returns an unexpected error.
class FinancialTransactionRepositoryException
    extends FinancialTransactionException {
  const FinancialTransactionRepositoryException([
    super.message = 'Repository error',
  ]);
}
