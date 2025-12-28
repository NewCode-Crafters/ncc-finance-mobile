import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';

import 'package:bytebank/presentation/widgets/common/app_snackbar.dart';
import 'package:bytebank/application/notifiers/transaction_attachments_notifier.dart';
import 'package:bytebank/presentation/theme/theme.dart';
import 'package:bytebank/domain/entities/transaction_category.dart';
import 'package:bytebank/presentation/widgets/common/widgets.dart';
import 'package:bytebank/application/notifiers/balance_notifier.dart'
    as app_balance;
import 'package:bytebank/application/notifiers/transaction_notifier.dart'
    as app_notifier;
import 'package:bytebank/domain/entities/financial_transaction.dart';
import 'package:bytebank/core/utils/transaction_utils.dart';

class CreateTransactionScreen extends StatefulWidget {
  static const String routeName = '/create-transaction';
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

enum TransactionType { expense, income }

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );

  String? _selectedCategoryId;
  bool _isLoading = false;
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
  }

  void _onToggleTypePressed(int index) {
    setState(() {
      _selectedType = index == 0
          ? TransactionType.expense
          : TransactionType.income;
      _selectedCategoryId = null;
    });
  }

  Future<void> _handleCreateTransaction() async {
    if (_selectedCategoryId == null || _amountController.numberValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildAppSnackBar(
          'Por favor, selecione uma categoria e preencha o valor.',
          AppMessageType.warning,
        ),
      );
      return;
    }

    if (_selectedType == TransactionType.expense) {
      final currentBalance = context
          .read<app_balance.BalanceNotifier>()
          .state
          .totalBalance;
      final transactionAmount = _amountController.numberValue;

      if (transactionAmount > currentBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar(
            'Saldo insuficiente! Você tem R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(currentBalance)} disponível.',
            AppMessageType.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final balanceNotifier = context.read<app_balance.BalanceNotifier>();
      final transactionNotifier = context
          .read<app_notifier.TransactionNotifier>();
      final navigator = Navigator.of(context);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final balanceId = context
          .read<app_balance.BalanceNotifier>()
          .state
          .balances
          .first
          .id;
      final attachmentsNotifier = context
          .read<TransactionAttachmentsNotifier>();

      final amount = _selectedType == TransactionType.income
          ? _amountController.numberValue
          : -_amountController.numberValue;

      final tx = FinancialTransaction(
        id: '',
        amount: amount,
        balanceId: balanceId,
        category: _selectedCategoryId!,
        date: DateTime.now(),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      await transactionNotifier.createTransaction(tx);

      final created = transactionNotifier.state.transactions.isNotEmpty
          ? transactionNotifier.state.transactions.first
          : null;

      if (created != null && created.id.isNotEmpty) {
        try {
          await attachmentsNotifier.commitAll(
            userId: userId,
            transactionId: created.id,
          );
        } catch (e) {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              buildAppSnackBar(
                'Falha ao enviar anexos: ${e.toString()}',
                AppMessageType.error,
              ),
            );
          }
        }
      }

      if (mounted) {
        await transactionNotifier.fetchTransactions(userId);
        await balanceNotifier.fetchBalances(userId: userId);

        scaffoldMessenger.showSnackBar(
          buildAppSnackBar(
            'Transação realizada com sucesso!',
            AppMessageType.success,
          ),
        );

        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          buildAppSnackBar(
            'Erro ao criar transação: ${e.toString()}',
            AppMessageType.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickOneFile(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final transactionAttachmentsNotifier = context
        .read<TransactionAttachmentsNotifier>();

    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
      withData: false,
    );

    if (res == null || res.files.isEmpty) return;
    final path = res.files.single.path;
    if (path == null) return;

    final file = File(path);
    final size = await file.length();
    if (size > 10 * 1024 * 1024) {
      scaffoldMessenger.showSnackBar(
        buildAppSnackBar('Arquivo excede 10MB.', AppMessageType.error),
      );
      return;
    }

    transactionAttachmentsNotifier.addLocal(file);
  }

  Widget _attachmentsSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final files = context.watch<TransactionAttachmentsNotifier>().selected;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGreenColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Anexos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _pickOneFile(context),
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Selecionar arquivo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imagens ou PDF • máx. 10MB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          if (files.isEmpty)
            Text(
              'Nenhum arquivo selecionado',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Builder(
              builder: (ctx) {
                final itemHeight = 56.0;
                final maxListHeight = 140.0;
                final listHeight = math.min(
                  files.length * itemHeight,
                  maxListHeight,
                );
                return SizedBox(
                  height: listHeight,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: files.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (ctx, i) {
                      final f = files[i];
                      return Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined,
                            color: AppColors.lightGreenColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.basename(f.path),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remover',
                            onPressed: () => context
                                .read<TransactionAttachmentsNotifier>()
                                .removeLocalAt(i),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<app_notifier.TransactionNotifier>();

    final categories = _selectedType == TransactionType.income
        ? notifier.incomeCategories
        : notifier.expenseCategories;

    final seenIds = <String>{};
    final uniqueCategories = <TransactionCategory>[];
    for (final c in categories) {
      if (seenIds.add(c.id)) uniqueCategories.add(c);
    }

    final safeSelected =
        (_selectedCategoryId != null &&
            uniqueCategories.where((c) => c.id == _selectedCategoryId).length ==
                1)
        ? uniqueCategories.firstWhere((c) => c.id == _selectedCategoryId)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Transação')),
      backgroundColor: AppColors.surfaceDefault,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ToggleButtons(
                    isSelected: [
                      _selectedType == TransactionType.expense,
                      _selectedType == TransactionType.income,
                    ],
                    onPressed: (index) {
                      _onToggleTypePressed(index);
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: AppColors.brandTertiary,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('Saída'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('Entrada'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<TransactionCategory>(
                    value: safeSelected,
                    hint: const Text(
                      'Selecione uma categoria',
                      style: TextStyle(color: AppColors.textSubtle),
                    ),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors.lightGreenColor,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors.lightGreenColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                    items: uniqueCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              getIconForCategory(category.id),
                              size: 20,
                              color: AppColors.lightGreenColor,
                            ),
                            const SizedBox(width: 8),
                            Text(category.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value?.id;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    cursorColor: AppColors.textSubtle,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      labelStyle: TextStyle(color: AppColors.textSubtle),
                      floatingLabelStyle: TextStyle(
                        color: AppColors.textSubtle,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors.lightGreenColor,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors.lightGreenColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    cursorColor: AppColors.textSubtle,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      labelStyle: TextStyle(color: AppColors.textSubtle),
                      floatingLabelStyle: TextStyle(
                        color: AppColors.textSubtle,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors.lightGreenColor,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors.lightGreenColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _attachmentsSection(context),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _isLoading
                ? const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Concluir',
                      onPressed: _handleCreateTransaction,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
