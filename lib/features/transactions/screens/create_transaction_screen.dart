import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';

import 'package:bytebank/core/widgets/app_snackbar.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_attachments_notifier.dart';
import 'package:bytebank/features/transactions/services/transaction_attachment_service.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:bytebank/core/services/metadata_service.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/transactions/notifiers/transaction_notifier.dart';
import 'package:bytebank/features/transactions/services/financial_transaction_service.dart';
import 'package:bytebank/features/transactions/utils/transaction_helpers.dart';

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

  TransactionCategory? _selectedCategory;
  bool _isLoading = false;
  TransactionType _selectedType = TransactionType.expense;
  late final TransactionAttachmentService _attachService;

  @override
  void initState() {
    super.initState();
    _attachService = TransactionAttachmentService();
  }

  void _onToggleTypePressed(int index) {
    setState(() {
      _selectedType = index == 0
          ? TransactionType.expense
          : TransactionType.income;
      _selectedCategory = null;
    });
  }

  Future<void> _handleCreateTransaction() async {
    if (_selectedCategory == null || _amountController.numberValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildAppSnackBar(
          'Por favor, selecione uma categoria e preencha o valor.',
          AppMessageType.warning,
        ),
      );
      return;
    }

    if (_selectedType == TransactionType.expense) {
      final currentBalance = context.read<BalanceNotifier>().state.totalBalance;
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
      final transactionService = context.read<FinancialTransactionService>();
      final balanceNotifier = context.read<BalanceNotifier>();
      final transactionNotifier = context.read<TransactionNotifier>();
      final navigator = Navigator.of(context);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final balanceId = context.read<BalanceNotifier>().state.balances.first.id;
      final attachmentsNotifier = context
          .read<TransactionAttachmentsNotifier>();

      final amount = _selectedType == TransactionType.income
          ? _amountController.numberValue
          : -_amountController.numberValue;

      final transactionRef = await transactionService.createTransaction(
        userId: userId,
        data: {
          'amount': amount,
          'balanceId': balanceId,
          'category': _selectedCategory!.id,
          'date': DateTime.now(),
          'description': _descriptionController.text,
        },
      );

      // After creating the transaction, upload any selected attachments sequentially.
      final filesToUpload = List<File>.from(attachmentsNotifier.selected);

      for (final f in filesToUpload) {
        try {
          await _attachService.uploadSingle(
            userId: userId,
            transactionId: transactionRef.id,
            file: f,
          );
        } catch (e) {
          // Show which file failed but continue uploading the rest.
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              buildAppSnackBar(
                'Falha ao enviar ${p.basename(f.path)}: ${e.toString()}',
                AppMessageType.error,
              ),
            );
          }
        }
      }

      // Clear local selections and refresh state after uploads.
      attachmentsNotifier.clear();

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

    if (res == null || res.files.isEmpty) {
      return;
    }

    final path = res.files.single.path;
    if (path == null) {
      return;
    }

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
          // Button on top, helper text below to avoid horizontal overflow on small screens
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
                          Icon(
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
    final notifier = context.watch<TransactionNotifier>();

    final categories = _selectedType == TransactionType.income
        ? notifier.incomeCategories
        : notifier.expenseCategories;

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
                    initialValue: _selectedCategory,
                    hint: const Text(
                      'Selecione uma categoria',
                      style: TextStyle(color: AppColors.textSubtle),
                    ),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors
                              .lightGreenColor, // Set your desired border color for the enabled state
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors
                              .lightGreenColor, // Set your desired border color for the focused state
                          width: 2.0,
                        ),
                      ),
                    ),
                    items: categories.map((category) {
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
                        _selectedCategory = value;
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
