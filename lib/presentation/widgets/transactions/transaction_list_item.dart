import 'package:bytebank/presentation/screens/transactions/view_transaction_detail_screen.dart';
import 'package:bytebank/presentation/widgets/common/app_snackbar.dart';
import 'package:bytebank/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/core/utils/transaction_utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: InkWell(
        onLongPress: () {
          if (isReadOnly) {
            final message = transaction.category == 'INVESTMENT_REDEMPTION'
                ? 'Transações de resgate de investimento não podem ser editadas ou excluídas.'
                : 'Transações de investimento são somente para visualização.';

            showAppSnackBar(context, message, AppMessageType.info);
          } else {
            showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.visibility),
                        title: const Text('Visualizar Transação'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ViewTransactionDetailScreen(transaction: transaction),
                            ),
                          );
                        },
                      ),
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
                ),
              ),
            );
          }
        },
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);

          final prefs = await SharedPreferences.getInstance();
          final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
          
          var shouldShow = false;
          var message = '';
          String? countKey;
          String? lastShownKey;
          int? shownCount;
          int? lastShownMs;

          if (isReadOnly) {
            if(transaction.category == 'INVESTMENT_REDEMPTION'){
              countKey = 'investment_redemption_snack_shown_count';
              lastShownKey = 'investment_redemption_snack_last_shown_ms';
            } else {
              countKey = 'transaction_investment_snack_shown_count';
              lastShownKey = 'transaction_investment_snack_last_shown_ms';
            }
            shownCount = prefs.getInt(countKey) ?? 0;
            lastShownMs = prefs.getInt(lastShownKey);
            message = transaction.category == 'INVESTMENT_REDEMPTION'
                ? 'Transações de resgate de investimento não podem ser editadas ou excluídas.'
                : 'Transações de investimento são somente para visualização.';
          } else {
            countKey = 'transaction_snack_shown_count';
            lastShownKey = 'transaction_snack_last_shown_ms';
            shownCount = prefs.getInt(countKey) ?? 0;
            lastShownMs = prefs.getInt(lastShownKey);
            message = 'Clique longo para visualizar, editar ou excluir esta transação, ou você pode deslizar para direita para editar ou para esquerda para excluir.';
            
          }

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
            width: 90,
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
            onEdit();
            return false;
          } else {
            onDelete();
            return false;
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
