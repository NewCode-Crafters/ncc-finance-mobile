class InvestmentException implements Exception {
  final String message;
  InvestmentException(this.message);
}

class InsufficientFundsException implements Exception {
  final String message;
  InsufficientFundsException(this.message);

  @override
  String toString() => message;
}
