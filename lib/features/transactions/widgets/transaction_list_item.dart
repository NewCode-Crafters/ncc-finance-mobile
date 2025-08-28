import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/transactions/models/financial_transaction.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final FinancialTransaction transaction;
  final String categoryLabel;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categoryLabel,
    required this.onDelete,
    required this.onEdit,
  });

  IconData _getIconForCategory(String categoryId) {
    switch (categoryId) {
      case 'SALARY':
        return Icons.monetization_on;
      case 'FOOD':
        return Icons.fastfood;
      case 'HOUSING':
        return Icons.house;
      case 'TRANSPORT':
        return Icons.directions_car;
      case 'LEISURE':
        return Icons.sports_esports;
      case 'HEALTH':
        return Icons.healing;
      case 'EDUCATION':
        return Icons.school;
      case 'SHOPPING':
        return Icons.shopping_cart;
      case 'INVESTMENT':
        return Icons.bar_chart;
      case 'INVESTMENT_REDEMPTION':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Transação'),
                    onTap: () {
                      Navigator.of(context).pop(); // Close the modal
                      onEdit();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Excluir Transação'),
                    onTap: () {
                      Navigator.of(context).pop(); // Close the modal
                      onDelete();
                    },
                  ),
                ],
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(_getIconForCategory(transaction.category)),
            ),
            title: Text(categoryLabel),
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
            trailing: Text(
              currencyFormatter.format(transaction.amount),
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
