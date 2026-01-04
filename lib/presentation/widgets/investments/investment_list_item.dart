import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bytebank/presentation/widgets/common/app_snackbar.dart';
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
          onTap: () async {
            // Lógica: mostrar nas 3 primeiras vezes (globalmente). Depois, só mostrar
            // se já passou 1 hora desde a última exibição.
            final messenger = ScaffoldMessenger.of(context);

            final prefs = await SharedPreferences.getInstance();

            const countKey = 'investment_snack_shown_count';
            const lastShownKey = 'investment_snack_last_shown_ms';

            final shownCount = prefs.getInt(countKey) ?? 0;
            final lastShownMs = prefs.getInt(lastShownKey);
            final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

            var shouldShow = false;

         

            if (!shouldShow) {
              if (shownCount < 3) {
                // nas primeiras 3 vezes sempre mostra
                shouldShow = true;
              } else if (lastShownMs == null) {
                // caso estranho: se não tiver timestamp, permitir a exibição e ajustar timestamp
                shouldShow = true;
              } else {
                final elapsedMs = nowMs - lastShownMs;
                  if (elapsedMs >= const Duration(hours: 1).inMilliseconds) {
                  shouldShow = true;
                }
              }
            }

               // Impor intervalo mínimo de 15 segundos entre exibições
            if (lastShownMs != null) {
              final elapsedSinceLastMs = nowMs - lastShownMs;
              if (elapsedSinceLastMs < const Duration(seconds: 15).inMilliseconds) {
                // ainda não passou 15 segundos desde a última exibição -> não mostrar
                shouldShow = false;
              }
            }

            if (shouldShow) {
              final message = 'Clique longo para resgatar este investimento, ou você pode deslizar para esquerda para resgatar.';
            
              // Show using the app snack bar builder through the captured messenger
              // to preserve the app style without using BuildContext after await.
              messenger.showSnackBar(buildAppSnackBar(message, AppMessageType.info));

              // Atualiza contadores/timestamps
              final newCount = shownCount + 1;
              await prefs.setInt(countKey, newCount);
              await prefs.setInt(lastShownKey, nowMs);
            }
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
