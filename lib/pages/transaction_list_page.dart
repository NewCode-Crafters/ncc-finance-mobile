import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/nav_bar.dart';
import 'package:flutter_application_1/models/nav_model.dart';
import 'package:flutter_application_1/services/transaction_list_service.dart';
import 'package:flutter_application_1/theme/theme.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
} 

class _TransactionListPageState extends State<TransactionListPage> {
  dynamic? _transaction;
  bool _loading = false;
  String? _error;
  int selectedTab = 0;
  List<NavModel> items = [];

  Future<void> _getRandomTransaction() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dynamic transaction = await TransactionListService.fetchRandomTransaction();
      setState(() {
        _transaction = transaction;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getRandomTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
            ? Text('Error: $_error')
            : _transaction == null
            ? const Text('No Transaction found')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(_transaction!.spriteUrl),
                  Text(
                    _transaction!.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Weight: ${_transaction!.weight}", style: const TextStyle(color: Colors.white)),
                  Text("Types: ${_transaction!.types.join(', ')}", style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  ..._transaction!.stats.entries.map(
                    (e) => Text('${e.key}: ${e.value}', style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _getRandomTransaction,
                    child: const Text('Get Another Transaction'),

                  ),
                ],
              ),
      ),
    );
  }
}
