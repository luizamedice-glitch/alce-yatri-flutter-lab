import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://54-94-146-177.sslip.io');

void main() => runApp(const PassengerApp());

class PassengerApp extends StatelessWidget {
  const PassengerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Alce Yatri Passageiro',
    theme: ThemeData(colorSchemeSeed: const Color(0xFFFF00BE), useMaterial3: true),
    home: const PassengerHome(),
  );
}

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});
  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  Timer? timer;
  final username = TextEditingController(text: 'alce-teste');
  final password = TextEditingController();
  bool connected = false;
  Map<String, dynamic>? ride;
  String? error;
  bool busy = false;

  @override
  void initState() {
    super.initState();

  }

  Future<Map<String, dynamic>> request(String method, String path, [Map<String, dynamic>? body]) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final req = await client.openUrl(method, Uri.parse('$apiUrl$path'));
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.authorizationHeader, 'Basic ${base64Encode(utf8.encode('${username.text}:${password.text}'))}');
      if (body != null) req.write(jsonEncode(body));
      final res = await req.close().timeout(const Duration(seconds: 8));
      final raw = await res.transform(utf8.decoder).join();
      if (res.statusCode == 401) throw const HttpException('Credenciais incorretas (401)');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (res.statusCode >= 400) throw HttpException('HTTP ${res.statusCode}: ${decoded['error']}');
      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> connect() async {
    if (username.text.isEmpty || password.text.isEmpty) return;
    try {
      await request('GET', '/health');
      if (!mounted) return;
      setState(() { connected = true; error = null; });
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 3), (_) => refresh());
      await refresh();
    } catch (e) {
      if (mounted) setState(() => error = 'Falha na conexão: $e');
    }
  }

  Future<void> refresh() async {
    try {
      final data = await request('GET', '/rides/current');
      if (mounted) setState(() { ride = data['ride'] as Map<String, dynamic>?; error = null; });
    } catch (e) {
      if (mounted) setState(() => error = 'API indisponível: $e');
    }
  }

  Future<void> createRide() async {
    setState(() => busy = true);
    try {
      final data = await request('POST', '/rides', {});
      if (mounted) setState(() { ride = data['ride'] as Map<String, dynamic>; error = null; });
    } catch (e) {
      if (mounted) setState(() => error = 'Não foi possível solicitar: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() { timer?.cancel(); username.dispose(); password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final status = ride?['status'] as String? ?? 'nenhuma corrida';
    final active = ride != null && !['completed', 'cancelled'].contains(status);
    return Scaffold(
      appBar: AppBar(title: const Text('Alce Yatri • Passageiro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Laboratório: corridas simuladas via API compartilhada.'),
          const SizedBox(height: 12),
          if (!connected) ...[
            TextField(controller: username, decoration: const InputDecoration(labelText: 'Usuário de testes')),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha de testes')),
            FilledButton(onPressed: connect, child: const Text('Conectar à API')),
          ],
          Text('Estado: $status', style: Theme.of(context).textTheme.titleLarge),
          if (ride != null) Text('Corrida: ${ride!['id']}'),
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          FilledButton(onPressed: !connected || busy || active ? null : createRide, child: const Text('Solicitar corrida de teste')),
          OutlinedButton(onPressed: connected ? refresh : null, child: const Text('Atualizar status')),
        ]),
      ),
    );
  }
}
