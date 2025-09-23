import 'package:flutter/material.dart';
import 'package:bytebank/core/models/nav_model.dart';
import 'package:bytebank/features/pokemons/services/pokemons_service.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  dynamic? _pokemon;
  bool _loading = false;
  String? _error;
  int selectedTab = 0;
  List<NavModel> items = [];

  Future<void> _getRandomPokemon() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dynamic pokemon = await PokemonListService.fetchRandomPokemon();
      setState(() {
        _pokemon = pokemon;
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
    _getRandomPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
            ? Text('Error: $_error')
            : _pokemon == null
            ? const Text('No Pokemon found')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(_pokemon!.spriteUrl),
                  Text(
                    _pokemon!.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Weight: ${_pokemon!.weight}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Types: ${_pokemon!.types.join(', ')}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  ..._pokemon!.stats.entries.map(
                    (e) => Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _getRandomPokemon,
                    child: const Text('Get Another Pokemon'),
                  ),
                ],
              ),
      ),
    );
  }
}
