import 'package:bytebank/core/widgets/app_snackbar.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/services/financial_transaction_service.dart';
import 'package:bytebank/features/transactions/utils/transaction_helpers.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';

class CreateTransactionScreen extends StatefulWidget {
  static const String routeName = '/create-transaction';
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

enum TransactionType { expense, income }

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );

  TransactionCategory? _selectedCategory;
  bool _isLoading = false;
  TransactionType _selectedType = TransactionType.expense;

  Future<void> _handleCreateTransaction() async {
    if (_selectedCategory == null || _amountController.numberValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma categoria e um valor.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final transactionService = context.read<FinancialTransactionService>();
      final balanceNotifier = context.read<BalanceNotifier>();
      final transactionNotifier = context.read<TransactionNotifier>();
      final navigator = Navigator.of(context);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final balanceId = context.read<BalanceNotifier>().state.balances.first.id;

      final amount = _selectedType == TransactionType.income
          ? _amountController.numberValue
          : -_amountController.numberValue;

      await transactionService.createTransaction(
        userId: userId,
        data: {
          'amount': amount,
          'balanceId': balanceId,
          'category': _selectedCategory!.id,
          'date': DateTime.now(),
          'description': _descriptionController.text,
        },
      );

      if (mounted) {
        await transactionNotifier.fetchTransactions(userId);
        await balanceNotifier.fetchBalances(userId: userId);

        scaffoldMessenger.showSnackBar(
          buildAppSnackBar(
            'Transação realizada com sucesso!',
            AppMessageType.success,
          ),
        );

        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          buildAppSnackBar(
            'Erro ao criar transação: ${e.toString()}',
            AppMessageType.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TransactionNotifier>();

    final categories = _selectedType == TransactionType.income
        ? notifier.incomeCategories
        : notifier.expenseCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Transação')),
      backgroundColor: AppColors.surfaceDefault,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [
                _selectedType == TransactionType.expense,
                _selectedType == TransactionType.income,
              ],
              onPressed: (index) {
                setState(() {
                  _selectedType = TransactionType.values[index];
                  _selectedCategory = null;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: AppColors.brandTertiary,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Saída'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Entrada'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<TransactionCategory>(
              value: _selectedCategory,
              hint: const Text('Selecione uma categoria'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(getIconForCategory(category.id), size: 20),
                      const SizedBox(width: 8),
                      Text(category.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              PrimaryButton(
                text: 'Concluir',
                onPressed: _handleCreateTransaction,
              ),
          ],
        ),
      ),
    );
  }
}
