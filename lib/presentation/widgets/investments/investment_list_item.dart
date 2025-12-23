import 'package:bytebank/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/domain/entities/investment.dart';
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
        child: InkWell(
          onLongPress: () async {
            showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: const Text('Resgatar investimento'),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await onConfirmDelete();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          onTap: () {
            final message = 'Clique longo para resgatar este investimento, ou você pode deslizar para esquerda para resgatar.';

            showAppSnackBar(context, message, AppMessageType.info);
          },
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
      ),
    );
  }
}
