# Advanced Validation Guide - NCC Finance Mobile

## Table of Contents
1. [Overview](#overview)
2. [Validation Architecture](#validation-architecture)
3. [Form Validation](#form-validation)
4. [Field Validators](#field-validators)
5. [Real-Time Validation](#real-time-validation)
6. [Business Logic Validation](#business-logic-validation)
7. [Error Handling](#error-handling)
8. [Best Practices](#best-practices)

## Overview

Validation is a critical aspect of data integrity and user experience. This guide outlines the validation strategies used in NCC Finance Mobile and provides patterns for implementing advanced validation.

### Validation Principles

1. **Multi-Layer Validation**: Validate at UI, business logic, and server levels
2. **Fail Fast**: Provide immediate feedback to users
3. **Clear Messages**: Use friendly, actionable error messages in Portuguese
4. **Type Safety**: Leverage Dart's type system for compile-time validation
5. **Consistent Patterns**: Use the same validation approach across features

### Current Implementation Status

- ✅ Email validation in `Validators` class
- ✅ Basic field validation in UI forms
- ✅ Server-side validation via Firestore Security Rules
- ⚠️ Advanced field validation (to be enhanced)
- ⚠️ Real-time validation feedback (to be enhanced)

## Validation Architecture

### Three-Layer Validation

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)          │
│  - Field-level validation            │
│  - Form-level validation             │
│  - Real-time feedback                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Business Logic Layer (Notifiers)   │
│  - Complex validation rules          │
│  - Cross-field validation            │
│  - Business constraints              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Data Layer (Firebase Rules)        │
│  - Server-side validation            │
│  - Security constraints              │
│  - Data integrity rules              │
└─────────────────────────────────────┘
```

## Form Validation

### Enhanced Validators Class

Extend the current `Validators` class with comprehensive validation methods:

```dart
// lib/core/validators.dart
class Validators {
  // Email Validation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

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

  // Password Validation
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
    
    // Check for uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve conter letra maiúscula';
    }
    
    // Check for lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter letra minúscula';
    }
    
    // Check for digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter número';
    }
    
    // Check for special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Senha deve conter caractere especial';
    }
    
    return null;
  }

  // Name Validation
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
    
    // Check for valid characters (letters, spaces, hyphens)
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-\']+$').hasMatch(trimmed)) {
      return 'Nome contém caracteres inválidos';
    }
    
    return null;
  }

  // Transaction Amount Validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valor é obrigatório';
    }
    
    // Remove currency formatting if present
    final cleanValue = value.replaceAll(RegExp(r'[^\d.,\-]'), '');
    
    // Convert to standard decimal format
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

  // Category Validation
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
      'Outros',
    ];
    
    if (!validCategories.contains(value)) {
      return 'Categoria inválida';
    }
    
    return null;
  }

  // Description Validation
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

  // Date Validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Data é obrigatória';
    }
    
    final now = DateTime.now();
    final minDate = DateTime(1900, 1, 1);
    final maxDate = now.add(const Duration(days: 365)); // Allow 1 year in future
    
    if (value.isBefore(minDate)) {
      return 'Data muito antiga';
    }
    
    if (value.isAfter(maxDate)) {
      return 'Data não pode estar muito no futuro';
    }
    
    return null;
  }

  // Investment Type Validation
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

  // Phone Number Validation (Brazilian format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    // Remove formatting
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

  // CPF Validation (Brazilian tax ID)
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    // Remove formatting
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Check for known invalid CPFs
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleaned)) {
      return 'CPF inválido';
    }
    
    // Calculate verification digits
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleaned[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 >= 10) digit1 = 0;
    
    if (digit1 != int.parse(cleaned[9])) {
      return 'CPF inválido';
    }
    
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

  // URL Validation
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
```

## Field Validators

### Transaction Form Validation

```dart
// lib/features/transactions/utils/transaction_validators.dart
class TransactionValidators {
  // Composite validation for transaction creation
  static String? validateTransactionAmount(String? value, {required bool isExpense}) {
    // First, validate format
    final formatError = Validators.validateAmount(value);
    if (formatError != null) return formatError;
    
    // Additional business rules
    final amount = double.parse(value!.replaceAll(',', '.'));
    
    if (isExpense && amount > 100000) {
      return 'Despesa muito alta. Confirme o valor.';
    }
    
    if (!isExpense && amount > 1000000) {
      return 'Receita muito alta. Confirme o valor.';
    }
    
    return null;
  }
  
  // Category validation with business rules
  static String? validateTransactionCategory(String? value, {required bool isExpense}) {
    final baseError = Validators.validateCategory(value);
    if (baseError != null) return baseError;
    
    // Ensure category matches transaction type
    final expenseCategories = ['Alimentação', 'Transporte', 'Moradia', 'Saúde', 'Lazer'];
    final incomeCategories = ['Salário', 'Freelance', 'Investimentos', 'Outros'];
    
    if (isExpense && !expenseCategories.contains(value)) {
      return 'Categoria inválida para despesa';
    }
    
    if (!isExpense && !incomeCategories.contains(value)) {
      return 'Categoria inválida para receita';
    }
    
    return null;
  }
  
  // Validate transaction date
  static String? validateTransactionDate(DateTime? value) {
    if (value == null) {
      return 'Data é obrigatória';
    }
    
    // Don't allow future transactions more than 1 day ahead
    final maxFutureDate = DateTime.now().add(const Duration(days: 1));
    if (value.isAfter(maxFutureDate)) {
      return 'Data não pode estar no futuro';
    }
    
    // Don't allow very old transactions
    final minDate = DateTime.now().subtract(const Duration(days: 365 * 5)); // 5 years
    if (value.isBefore(minDate)) {
      return 'Data muito antiga';
    }
    
    return null;
  }
}
```

### Investment Form Validation

```dart
// lib/features/investments/utils/investment_validators.dart
class InvestmentValidators {
  static String? validateInvestmentAmount(String? value) {
    final baseError = Validators.validateAmount(value);
    if (baseError != null) return baseError;
    
    final amount = double.parse(value!.replaceAll(',', '.'));
    
    // Minimum investment amount
    if (amount < 100) {
      return 'Valor mínimo de investimento: R\$ 100,00';
    }
    
    return null;
  }
  
  static String? validateInvestmentName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome do investimento é obrigatório';
    }
    
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Nome muito curto (mínimo 3 caracteres)';
    }
    
    if (trimmed.length > 100) {
      return 'Nome muito longo (máximo 100 caracteres)';
    }
    
    return null;
  }
  
  static String? validateReturnRate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final rate = double.tryParse(value.replaceAll(',', '.'));
    if (rate == null) {
      return 'Taxa inválida';
    }
    
    if (rate < -100 || rate > 1000) {
      return 'Taxa deve estar entre -100% e 1000%';
    }
    
    return null;
  }
}
```

## Real-Time Validation

### Form with Real-Time Validation

```dart
// lib/features/transactions/screens/create_transaction_screen.dart
class CreateTransactionScreen extends StatefulWidget {
  @override
  _CreateTransactionScreenState createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  bool _isExpense = true;
  DateTime _selectedDate = DateTime.now();
  
  // Validation state
  bool _autoValidate = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Transação')),
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidate 
          ? AutovalidateMode.onUserInteraction 
          : AutovalidateMode.disabled,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Transaction Type Selector
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text('Despesa')),
                ButtonSegment(value: false, label: Text('Receita')),
              ],
              selected: {_isExpense},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isExpense = newSelection.first;
                  _selectedCategory = null; // Reset category
                });
              },
            ),
            SizedBox(height: 16),
            
            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Valor *',
                prefixText: 'R\$ ',
                hintText: '0,00',
                helperText: 'Digite o valor da transação',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => TransactionValidators.validateTransactionAmount(
                value,
                isExpense: _isExpense,
              ),
              onChanged: (_) {
                // Trigger validation on change after first attempt
                if (_autoValidate) {
                  _formKey.currentState?.validate();
                }
              },
            ),
            SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoria *',
                helperText: 'Selecione uma categoria',
              ),
              items: _getCategoriesForType(_isExpense)
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              validator: (value) => TransactionValidators.validateTransactionCategory(
                value,
                isExpense: _isExpense,
              ),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                if (_autoValidate) {
                  _formKey.currentState?.validate();
                }
              },
            ),
            SizedBox(height: 16),
            
            // Date Picker
            ListTile(
              title: Text('Data'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            
            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: 'Opcional',
              ),
              maxLines: 3,
              maxLength: 500,
              validator: Validators.validateDescription,
            ),
            SizedBox(height: 24),
            
            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Salvar Transação'),
            ),
          ],
        ),
      ),
    );
  }
  
  List<String> _getCategoriesForType(bool isExpense) {
    if (isExpense) {
      return ['Alimentação', 'Transporte', 'Moradia', 'Saúde', 'Lazer', 'Compras', 'Outros'];
    } else {
      return ['Salário', 'Freelance', 'Investimentos', 'Bonificação', 'Outros'];
    }
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _submitForm() {
    // Enable auto-validation for future changes
    setState(() {
      _autoValidate = true;
    });
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, corrija os erros no formulário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate date separately
    final dateError = TransactionValidators.validateTransactionDate(_selectedDate);
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateError), backgroundColor: Colors.red),
      );
      return;
    }
    
    // All validation passed, submit the form
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final transaction = FinancialTransaction(
      id: '',
      amount: _isExpense ? -amount : amount,
      category: _selectedCategory!,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
      balanceId: '', // Will be set by service
    );
    
    // Call notifier to create transaction
    context.read<TransactionNotifier>().createTransaction(transaction);
    
    Navigator.pop(context);
  }
}
```

## Business Logic Validation

### Notifier-Level Validation

```dart
// lib/features/transactions/notifiers/transaction_notifier.dart
class TransactionNotifier extends ChangeNotifier {
  final FinancialTransactionService _service;
  
  Future<bool> createTransaction(FinancialTransaction transaction) async {
    // Business logic validation
    final validationErrors = _validateTransaction(transaction);
    if (validationErrors.isNotEmpty) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: validationErrors.join('\n'),
      );
      notifyListeners();
      return false;
    }
    
    try {
      await _service.createTransaction(transaction);
      await loadTransactions(); // Refresh list
      return true;
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Erro ao criar transação');
      notifyListeners();
      return false;
    }
  }
  
  List<String> _validateTransaction(FinancialTransaction transaction) {
    final errors = <String>[];
    
    // Amount validation
    if (transaction.amount == 0) {
      errors.add('Valor não pode ser zero');
    }
    
    // Category validation
    if (transaction.category.isEmpty) {
      errors.add('Categoria é obrigatória');
    }
    
    // Date validation
    if (transaction.date.isAfter(DateTime.now().add(Duration(days: 1)))) {
      errors.add('Data não pode estar muito no futuro');
    }
    
    // Business rule: Check for duplicate transactions
    final isDuplicate = _checkDuplicateTransaction(transaction);
    if (isDuplicate) {
      errors.add('Transação duplicada detectada. Confirme os dados.');
    }
    
    return errors;
  }
  
  bool _checkDuplicateTransaction(FinancialTransaction transaction) {
    // Check if similar transaction exists in last 5 minutes
    final recentTransactions = _state.transactions.where((t) =>
      t.amount == transaction.amount &&
      t.category == transaction.category &&
      t.date.difference(transaction.date).inMinutes.abs() < 5
    );
    
    return recentTransactions.isNotEmpty;
  }
}
```

## Error Handling

### User-Friendly Error Messages

```dart
class ValidationErrorMessages {
  static const Map<String, String> errors = {
    // Email errors
    'email_required': 'Email é obrigatório',
    'email_invalid': 'Email inválido',
    'email_too_long': 'Email muito longo',
    
    // Password errors
    'password_required': 'Senha é obrigatória',
    'password_too_short': 'Senha muito curta (mínimo 8 caracteres)',
    'password_no_uppercase': 'Senha deve conter letra maiúscula',
    'password_no_lowercase': 'Senha deve conter letra minúscula',
    'password_no_number': 'Senha deve conter número',
    'password_no_special': 'Senha deve conter caractere especial',
    
    // Amount errors
    'amount_required': 'Valor é obrigatório',
    'amount_invalid': 'Valor inválido',
    'amount_zero': 'Valor deve ser maior que zero',
    'amount_too_high': 'Valor muito alto',
    'amount_decimals': 'Use no máximo 2 casas decimais',
    
    // Category errors
    'category_required': 'Categoria é obrigatória',
    'category_invalid': 'Categoria inválida',
    
    // Date errors
    'date_required': 'Data é obrigatória',
    'date_future': 'Data não pode estar no futuro',
    'date_too_old': 'Data muito antiga',
  };
  
  static String getMessage(String key) {
    return errors[key] ?? 'Erro de validação';
  }
}
```

### Error Display Widget

```dart
class ValidationErrorWidget extends StatelessWidget {
  final String? errorMessage;
  
  const ValidationErrorWidget({Key? key, this.errorMessage}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red.shade900, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Best Practices

### 1. Validation Timing

```dart
// ✅ Good: Validate on submit first, then on change
autovalidateMode: _hasAttemptedSubmit 
  ? AutovalidateMode.onUserInteraction 
  : AutovalidateMode.disabled

// ❌ Bad: Always validate (annoying for users)
autovalidateMode: AutovalidateMode.always
```

### 2. Clear Error Messages

```dart
// ✅ Good: Specific, actionable message
'Senha deve ter pelo menos 8 caracteres'

// ❌ Bad: Vague message
'Senha inválida'
```

### 3. Progressive Validation

```dart
// ✅ Good: Show success indicators
TextFormField(
  decoration: InputDecoration(
    suffixIcon: _isValid ? Icon(Icons.check_circle, color: Colors.green) : null,
  ),
)
```

### 4. Consistent Patterns

```dart
// ✅ Good: Consistent return types
static String? validateXxx(String? value) {
  if (/* invalid */) return 'Error message';
  return null; // Valid
}
```

### 5. Reusable Validators

```dart
// ✅ Good: Compose validators
String? validateTransactionForm() {
  return validateAmount(_amount) ??
         validateCategory(_category) ??
         validateDate(_date);
}
```

## Conclusion

Effective validation improves user experience and data quality. Key takeaways:

1. **Validate at multiple layers** for defense in depth
2. **Provide immediate feedback** for better UX
3. **Use clear, actionable messages** in Portuguese
4. **Leverage type safety** to catch errors at compile time
5. **Test validation logic** thoroughly

The validation patterns outlined in this guide ensure data integrity while providing a smooth user experience in the NCC Finance Mobile application.
