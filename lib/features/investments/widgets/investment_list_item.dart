import 'package:flutter/material.dart';
import 'package:bytebank/features/investments/models/investment.dart';
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
        color: Colors.orange,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.white),
            SizedBox(height: 4),
            Text(
              'Resgatar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
