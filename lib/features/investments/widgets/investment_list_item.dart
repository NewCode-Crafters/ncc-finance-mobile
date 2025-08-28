import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/investments/models/investment.dart';
import 'package:intl/intl.dart';

class InvestmentListItem extends StatelessWidget {
  final Investment investment;
  final Color indicatorColor;
  final Future<bool> Function() onConfirmDelete;

  const InvestmentListItem({
    super.key,
    required this.investment,
    required this.indicatorColor,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Dismissible(
      key: Key(investment.id),
      direction:
          DismissDirection.endToStart, // Only allow swipe from right to left
      confirmDismiss: (_) => onConfirmDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          leading: Container(width: 10, height: 40, color: indicatorColor),
          title: Text(investment.name),
          subtitle: Text(
            DateFormat('dd/MM/yyyy').format(investment.investedAt),
          ),
          trailing: Text(
            currencyFormatter.format(investment.amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
