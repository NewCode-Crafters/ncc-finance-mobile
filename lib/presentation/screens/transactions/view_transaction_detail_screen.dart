import 'package:bytebank/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/domain/entities/financial_transaction_entity.dart';
import 'package:bytebank/application/notifiers/transaction_notifier.dart' as app_notifier;
import 'package:bytebank/presentation/utils/transaction_helpers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bytebank/presentation/widgets/transactions/read_only_attachments_section.dart';

class ViewTransactionDetailScreen extends StatelessWidget {
  final FinancialTransaction transaction;

  const ViewTransactionDetailScreen({super.key, required this.transaction});

  Widget _labelledBox(BuildContext ctx, {required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSubtle)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lightGreenColor, width: 2),
          ),
          child: child,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<app_notifier.TransactionNotifier>();
    final isIncome = transaction.amount > 0;
    final categories = isIncome ? notifier.incomeCategories : notifier.expenseCategories;
    final category = categories.isNotEmpty
        ? categories.firstWhere(
            (c) => c.id == transaction.category,
            orElse: () => categories.first,
          )
        : null;
    final categoryLabel = category != null ? category.label : 'Categoria desconhecida';

    final amountText = NumberFormat.simpleCurrency(locale: 'pt_BR').format(transaction.amount.abs());
    final dateText = DateFormat('dd/MM/yyyy').format(transaction.date);

    return Scaffold(
      appBar: AppBar(title: const Text('Visualizar Transação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _labelledBox(
              context,
              label: 'Categoria',
              child: Row(
                children: [
                  Icon(getIconForCategory(transaction.category), color: AppColors.lightGreenColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(categoryLabel)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _labelledBox(
              context,
              label: 'Valor',
              child: Text(amountText, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _labelledBox(
              context,
              label: 'Descrição (opcional)',
              child: Text(transaction.description?.isNotEmpty == true ? transaction.description! : '-', style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 16),
            _labelledBox(
              context,
              label: 'Data',
              child: Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 16),
            ReadOnlyAttachmentsSection(transactionId: transaction.id),
          ],
        ),
      ),
    );
  }
}
