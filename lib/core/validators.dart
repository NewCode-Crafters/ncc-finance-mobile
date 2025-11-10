/// Centralized validation utilities for the application.
/// 
/// This class provides static methods for validating various types of user input
/// including email, password, amounts, categories, and more. All methods return
/// null if validation passes, or an error message string if validation fails.
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Checks if an email string matches a valid email pattern.
  /// 
  /// Returns true if the email is valid, false otherwise.
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  /// Validates an email address with detailed error messages.
  /// 
  /// Returns null if valid, or an error message string if invalid.
  /// 
  /// Example:
  /// ```dart
  /// final error = Validators.validateEmail(emailInput);
  /// if (error != null) {
  ///   // Show error to user
  /// }
  /// ```
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!isValidEmail(value)) {
      return 'Email inválido';
    }
    if (value.length > 254) {
      return 'Email muito longo';
    }
    return null;
  }

  /// Validates a password with comprehensive security requirements.
  /// 
  /// Requirements:
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (value.length > 128) {
      return 'Senha muito longa';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve conter letra maiúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter letra minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter número';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Senha deve conter caractere especial';
    }
    return null;
  }

  /// Validates a person's name.
  /// 
  /// Requirements:
  /// - Not empty
  /// - At least 2 characters
  /// - Maximum 100 characters
  /// - Only letters, spaces, hyphens, and apostrophes
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Nome muito curto';
    }
    
    if (trimmed.length > 100) {
      return 'Nome muito longo';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes, accented characters)
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-\']+$').hasMatch(trimmed)) {
      return 'Nome contém caracteres inválidos';
    }
    
    return null;
  }

  /// Validates a transaction or investment amount.
  /// 
  /// Requirements:
  /// - Not empty
  /// - Valid numeric format
  /// - Greater than zero
  /// - Maximum value: 999,999,999.99
  /// - Maximum 2 decimal places
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valor é obrigatório';
    }
    
    // Remove currency formatting if present (R$, spaces, etc.)
    final cleanValue = value.replaceAll(RegExp(r'[^\d.,\-]'), '');
    
    // Convert comma to period for decimal parsing
    final normalizedValue = cleanValue.replaceAll(',', '.');
    
    final amount = double.tryParse(normalizedValue);
    if (amount == null) {
      return 'Valor inválido';
    }
    
    if (amount <= 0) {
      return 'Valor deve ser maior que zero';
    }
    
    if (amount > 999999999.99) {
      return 'Valor muito alto';
    }
    
    // Check decimal places
    final parts = normalizedValue.split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Use no máximo 2 casas decimais';
    }
    
    return null;
  }

  /// Validates a transaction category.
  /// 
  /// The category must be one of the predefined valid categories.
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Categoria é obrigatória';
    }
    
    final validCategories = [
      'Alimentação',
      'Transporte',
      'Moradia',
      'Saúde',
      'Educação',
      'Lazer',
      'Compras',
      'Contas',
      'Salário',
      'Freelance',
      'Investimentos',
      'Outros',
    ];
    
    if (!validCategories.contains(value)) {
      return 'Categoria inválida';
    }
    
    return null;
  }

  /// Validates a description field.
  /// 
  /// Description is optional, but if provided, must not exceed 500 characters.
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validateDescription(String? value) {
    // Description is optional
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length > 500) {
      return 'Descrição muito longa (máximo 500 caracteres)';
    }
    
    return null;
  }

  /// Validates a date value.
  /// 
  /// Requirements:
  /// - Not null
  /// - Not before January 1, 1900
  /// - Not more than 1 year in the future
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Data é obrigatória';
    }
    
    final now = DateTime.now();
    final minDate = DateTime(1900, 1, 1);
    final maxDate = now.add(const Duration(days: 365));
    
    if (value.isBefore(minDate)) {
      return 'Data muito antiga';
    }
    
    if (value.isAfter(maxDate)) {
      return 'Data não pode estar muito no futuro';
    }
    
    return null;
  }

  /// Validates an investment type.
  /// 
  /// The type must be one of the predefined valid investment types.
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validateInvestmentType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tipo de investimento é obrigatório';
    }
    
    final validTypes = [
      'Renda Fixa',
      'Renda Variável',
      'Fundos',
      'Previdência',
      'Outros',
    ];
    
    if (!validTypes.contains(value)) {
      return 'Tipo de investimento inválido';
    }
    
    return null;
  }

  /// Validates a Brazilian phone number.
  /// 
  /// Accepts formats like (XX) XXXXX-XXXX or (XX) XXXX-XXXX.
  /// Validates the area code (DDD) is between 11 and 99.
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    // Remove formatting characters
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Brazilian phone: (XX) XXXXX-XXXX or (XX) XXXX-XXXX
    if (cleaned.length < 10 || cleaned.length > 11) {
      return 'Telefone inválido';
    }
    
    // Check if starts with valid DDD (area code)
    final ddd = int.tryParse(cleaned.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) {
      return 'DDD inválido';
    }
    
    return null;
  }

  /// Validates a Brazilian CPF (Cadastro de Pessoas Físicas).
  /// 
  /// Performs checksum validation to ensure the CPF is mathematically valid.
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    // Remove formatting characters
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Check for known invalid CPFs (all same digit)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleaned)) {
      return 'CPF inválido';
    }
    
    // Calculate first verification digit
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleaned[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 >= 10) digit1 = 0;
    
    if (digit1 != int.parse(cleaned[9])) {
      return 'CPF inválido';
    }
    
    // Calculate second verification digit
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleaned[i]) * (11 - i);
    }
    int digit2 = 11 - (sum % 11);
    if (digit2 >= 10) digit2 = 0;
    
    if (digit2 != int.parse(cleaned[10])) {
      return 'CPF inválido';
    }
    
    return null;
  }

  /// Validates a URL.
  /// 
  /// URL is optional, but if provided, must be a valid http or https URL.
  /// 
  /// Returns null if valid, or an error message string if invalid.
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'URL inválida';
    }
    
    if (!['http', 'https'].contains(uri.scheme)) {
      return 'URL deve usar http ou https';
    }
    
    return null;
  }
}
