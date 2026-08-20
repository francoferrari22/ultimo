import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  String baseUrl = '';
  String apiKey = '';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    baseUrl = (p.getString('baseUrl') ?? '').trim().replaceAll(RegExp(r'/$'), '');
    apiKey = p.getString('apiKey') ?? '';
  }

  Future<void> save(String url, String key) async {
    final p = await SharedPreferences.getInstance();
    baseUrl = url.trim().replaceAll(RegExp(r'/$'), ''); apiKey = key.trim();
    await p.setString('baseUrl', baseUrl); await p.setString('apiKey', apiKey);
  }

  Future<dynamic> get(String path) async {
    if (baseUrl.isEmpty || apiKey.isEmpty) throw Exception('Configura primero el servidor.');
    final r = await http.get(Uri.parse('$baseUrl$path'), headers: {'X-API-Key': apiKey}).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw Exception('Servidor respondió ${r.statusCode}');
    return jsonDecode(r.body);
  }
}
