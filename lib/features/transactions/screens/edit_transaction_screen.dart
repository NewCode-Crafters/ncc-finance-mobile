import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/metadata_service.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/transactions/models/financial_transaction.dart';
import 'package:flutter_application_1/features/transactions/notifiers/transaction_notifier.dart';
import 'package:flutter_application_1/features/transactions/utils/transaction_helpers.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditTransactionScreen extends StatefulWidget {
  static const String routeName = '/edit-transaction';
  final FinancialTransaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late final TextEditingController _descriptionController;
  late final MoneyMaskedTextController _amountController;
  late final TextEditingController _dateController;
  TransactionCategory? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final notifier = context.read<TransactionNotifier>();

    _descriptionController = TextEditingController(
      text: widget.transaction.description,
    );
    _amountController = MoneyMaskedTextController(
      initialValue: widget.transaction.amount.abs(), // Use absolute value
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
    );
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.transaction.date),
    );

    try {
      _selectedCategory = notifier.state.categories.firstWhere(
        (c) => c.id == widget.transaction.category,
      );
    } catch (e) {
      _selectedCategory = null;
    }
  }

  Future<void> _handleUpdateTransaction() async {
    if (_selectedCategory == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = context.read<TransactionNotifier>();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await notifier.editTransaction(
        userId: userId,
        transactionId: widget.transaction.id,
        data: {
          'category': _selectedCategory!.id,
          'description': _descriptionController.text,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transação atualizada com sucesso!'),
            backgroundColor: Colors.green[600],
          ),
        );
        Navigator.of(context).pop();
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
    final isIncome = widget.transaction.amount > 0;

    final categories = isIncome
        ? notifier.incomeCategories
        : notifier.expenseCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Transação')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Data',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              PrimaryButton(
                text: 'Salvar Alterações',
                onPressed: _handleUpdateTransaction,
              ),
          ],
        ),
      ),
    );
  }
}
