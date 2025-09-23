import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonListService {
  static const String baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  static Future<dynamic> fetchPokemonByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/$name'));

    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }

  static Future<dynamic> fetchRandomPokemon() async {
    final randomId = Random().nextInt(898) + 1; // Pokémon up to Gen 8
    final response = await http.get(Uri.parse('$baseUrl/$randomId'));

    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }

  static fromJson(Map<String, dynamic> json) {
    return (
      name: json['name'],
      spriteUrl: json['sprites']['front_default'],
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      stats: {
        for (var s in json['stats']) s['stat']['name']: s['base_stat'] as int,
      },
      weight: json['weight'],
    );
  }
}
