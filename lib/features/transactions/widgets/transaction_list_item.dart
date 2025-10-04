import 'package:bytebank/core/widgets/app_snackbar.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/features/transactions/models/financial_transaction.dart';
import 'package:bytebank/features/transactions/utils/transaction_helpers.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final FinancialTransaction transaction;
  final String categoryLabel;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isReadOnly;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categoryLabel,
    required this.onDelete,
    required this.onEdit,
    this.isReadOnly = false,
  });

  Widget _buildDismissibleBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final isIncome = transaction.amount > 0;

    final tileContent = Card(
      // Make read-only items look slightly different
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: InkWell(
        // Disable long-press if read-only
        onLongPress: () {
          if (isReadOnly) {
            final message = transaction.category == 'INVESTMENT_REDEMPTION'
                ? 'Transações de resgate de investimento não podem ser editadas ou excluídas.'
                : 'Transações de investimento são somente para visualização.';

            showAppSnackBar(context, message, AppMessageType.info);
          } else {
            showModalBottomSheet(
              context: context,
              builder: (context) => Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Transação'),
                    onTap: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Excluir Transação'),
                    onTap: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                ],
              ),
            );
          }
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.neutral500,
            child: Icon(getIconForCategory(transaction.category)),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(categoryLabel, overflow: TextOverflow.ellipsis),
              ),
              if (isReadOnly) ...[
                const SizedBox(width: 4),
                Icon(Icons.lock, size: 14, color: Colors.grey.shade500),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
              if (transaction.description != null &&
                  transaction.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    transaction.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          trailing: SizedBox(
            width: 90, // Aumentado de 120 para 200 pixels
            child: Text(
              currencyFormatter.format(transaction.amount),
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );

    if (isReadOnly) {
      return tileContent;
    } else {
      return Dismissible(
        key: Key(transaction.id),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onEdit(); // Trigger edit action
            return false; // Don't dismiss the item
          } else {
            onDelete();
            return false; // The dialog will handle the actual deletion/dismissal
          }
        },
        background: _buildDismissibleBackground(
          color: Colors.blue,
          icon: Icons.edit,
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _buildDismissibleBackground(
          color: Colors.red,
          icon: Icons.delete,
          alignment: Alignment.centerRight,
        ),
        child: tileContent,
      );
    }
  }
}
