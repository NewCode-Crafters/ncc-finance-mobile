import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/widgets/custom_text_field.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/investments/notifiers/investment_notifier.dart';
import 'package:bytebank/features/investments/services/investment_exceptions.dart';
import 'package:bytebank/features/investments/services/investment_service.dart';
import 'package:provider/provider.dart';

class CreateInvestmentScreen extends StatefulWidget {
  static const String routeName = '/create-investment';
  const CreateInvestmentScreen({super.key});

  @override
  State<CreateInvestmentScreen> createState() => _CreateInvestmentScreenState();
}

class _CreateInvestmentScreenState extends State<CreateInvestmentScreen> {
  final _amountController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;

  // TODO:  In the future, this could be fetched from the 'metadata' collection in Firestore.
  final List<String> _investmentTypes = [
    'Tesouro Direto',
    'Previdência Privada',
    'Fundo de Investimento',
    'Bolsa de Valores',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateInvestment() async {
    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (_selectedType == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final investmentService = context.read<InvestmentService>();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final balances = await context.read<BalanceNotifier>().state.balances;

      if (userId == null) {
        throw Exception("Usuário não encontrado.");
      }

      if (balances.isEmpty) {
        throw Exception("Usuário sem saldo.");
      }

      final balanceId = balances.first.id;

      final investmentData = {
        'name': _selectedType!,
        'amount': amount,
        'category': 'FIXED_INCOME', // Placeholder category
        'type': _selectedType!.replaceAll(' ', '_').toUpperCase(),
        'investedAt': DateTime.now(),
        'balanceId': balanceId,
      };

      await investmentService.createInvestment(
        userId: userId,
        data: investmentData,
      );

      if (mounted) {
        // Refresh the investments list
        await context.read<InvestmentNotifier>().fetchInvestments(
          userId: userId,
        );
        // Refresh the balances list
        await context.read<BalanceNotifier>().fetchBalances(userId: userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Investimento criado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } on InsufficientFundsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Investimento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Criar um novo investimento',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedType,
              hint: const Text('Selecione o tipo de investimento'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _investmentTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              label: 'Valor a ser investido',
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              PrimaryButton(
                text: 'Concluir',
                onPressed: _handleCreateInvestment,
              ),
          ],
        ),
      ),
    );
  }
}
