import 'package:bytebank/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/features/transactions/models/financial_transaction.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/utils/transaction_helpers.dart';
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
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the enabled state
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the focused state
                    width: 2.0,
                  ),
                ),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(getIconForCategory(category.id), size: 20, color: AppColors.lightGreenColor,),
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
              cursorColor: AppColors.textSubtle,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Valor',
                labelStyle: TextStyle(
                  color: AppColors.textSubtle, // Cor do label quando não está focado
                ),
                floatingLabelStyle: TextStyle(
                  color: AppColors.textSubtle, // Cor do label quando está focado
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the enabled state
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the focused state
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              cursorColor: AppColors.textSubtle,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                labelStyle: TextStyle(
                  color: AppColors.textSubtle, // Cor do label quando não está focado
                ),
                floatingLabelStyle: TextStyle(
                  color: AppColors.textSubtle, // Cor do label quando está focado
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the enabled state
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the focused state
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Data',
                labelStyle: TextStyle(
                  color: AppColors.textSubtle, // Cor do label quando não está focado
                ),
                floatingLabelStyle: TextStyle(
                  color: AppColors.textSubtle, // Cor do label quando está focado
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the enabled state
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the focused state
                    width: 2.0,
                  ),
                ),
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
