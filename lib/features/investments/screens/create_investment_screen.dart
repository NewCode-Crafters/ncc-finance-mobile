import 'package:bytebank/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bytebank/core/widgets/custom_text_field.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/features/dashboard/notifiers/balance_notifier.dart';
import 'package:bytebank/features/investments/notifiers/investment_notifier.dart';
import 'package:bytebank/features/investments/services/investment_exceptions.dart';
import 'package:bytebank/features/investments/services/investment_service.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';

class CreateInvestmentScreen extends StatefulWidget {
  static const String routeName = '/create-investment';
  const CreateInvestmentScreen({super.key});

  @override
  State<CreateInvestmentScreen> createState() => _CreateInvestmentScreenState();
}

class _CreateInvestmentScreenState extends State<CreateInvestmentScreen> {
  final MoneyMaskedTextController _amountController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ', // Adiciona o símbolo "R$"
    decimalSeparator: ',', // Define o separador decimal como vírgula
    thousandSeparator: '.', // Define o separador de milhar como ponto
  );
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
    final amountText = _amountController.text.replaceAll('R\$ ', '').replaceAll(',', '.');
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
      final category = _selectedType! == 'Tesouro Direto' || _selectedType! == 'Previdência Privada' ? 'FIXED_INCOME' : 'VARIABLE_INCOME';
      final investmentData = {
        'name': _selectedType!,
        'amount': amount,
        'category': category,
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
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedType,
              hint: const Text(
                'Selecione o tipo de investimento',
                style: TextStyle(color: AppColors.textSubtle),
              ),
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the enabled state
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the focused state
                    width: 2.0,
                  ),
                ),
              ),
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
            TextField(
              controller: _amountController,
              cursorColor: AppColors.textSubtle,
              decoration: const InputDecoration(
                labelText: 'Valor',
                labelStyle: TextStyle(
                  color: AppColors.textSubtle, // Cor do label quando não está focado
                ),
                floatingLabelStyle: TextStyle(
                  color: AppColors.textSubtle, // Cor do label quando está focado
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the enabled state
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.lightGreenColor, // Set your desired border color for the focused state
                    width: 2.0,
                  ),
                ),
              ),
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
