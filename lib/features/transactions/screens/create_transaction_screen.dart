import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/metadata_service.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/dashboard/notifiers/balance_notifier.dart';
import 'package:flutter_application_1/features/transactions/notifiers/transaction_notifier.dart';
import 'package:flutter_application_1/features/transactions/services/financial_transaction_service.dart';
import 'package:flutter_application_1/features/transactions/utils/transaction_helpers.dart';
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

    try {
      final transactionService = context.read<FinancialTransactionService>();
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
        await context.read<TransactionNotifier>().fetchTransactions(userId);
        await context.read<BalanceNotifier>().fetchBalances(userId: userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Transação realizada com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green[600],
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar transação: ${e.toString()}')),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CupertinoSlidingSegmentedControl<TransactionType>(
              groupValue: _selectedType,
              children: const {
                TransactionType.expense: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Despesa'),
                ),
                TransactionType.income: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Receita'),
                ),
              },
              onValueChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    _selectedCategory = null;
                  });
                }
              },
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
