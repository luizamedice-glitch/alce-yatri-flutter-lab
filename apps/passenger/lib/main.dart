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
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF00BE)), useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF9F8FB)),
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
  int consecutiveFailures = 0;
  bool refreshing = false;

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
    if (refreshing) return;
    refreshing = true;
    try {
      final data = await request('GET', '/rides/current');
      if (mounted) setState(() { ride = data['ride'] as Map<String, dynamic>?; error = null; consecutiveFailures = 0; });
    } catch (e) {
      if (mounted) setState(() { consecutiveFailures++; error = consecutiveFailures >= 2 ? 'Conexão instável. Tentando reconectar automaticamente…' : null; });
    } finally {
      refreshing = false;
    }
  }

  Future<void> createRide() async {
    setState(() => busy = true);
    try {
      final data = await request('POST', '/rides', {});
      if (mounted) setState(() { ride = data['ride'] as Map<String, dynamic>; error = null; });
    } catch (e) {
      if (mounted) setState(() => error = 'Não foi possível confirmar a solicitação. Atualize o status antes de tentar novamente: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() { timer?.cancel(); username.dispose(); password.dispose(); super.dispose(); }

  String get statusLabel {
    switch (ride?['status']) {
      case 'requested': return 'Procurando motorista';
      case 'accepted': return 'Motorista a caminho';
      case 'driver_arrived': return 'Motorista chegou';
      case 'in_progress': return 'Viagem em andamento';
      case 'completed': return 'Viagem concluída';
      case 'cancelled': return 'Corrida cancelada';
      default: return 'Pronto para viajar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = ride?['status'] as String?;
    final active = status != null && !['completed', 'cancelled'].contains(status);
    final pink = theme.colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F8FB),
        title: const Text('ALCE YATRI', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        actions: [IconButton(onPressed: connected ? refresh : null, icon: const Icon(Icons.refresh), tooltip: 'Atualizar corrida')],
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Sua próxima viagem começa aqui', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Mobilidade simples, do seu jeito.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
        const SizedBox(height: 20),
        Container(
          height: 170,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [pink, const Color(0xFF8024B9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24)),
          child: Stack(children: [
            Positioned(right: 22, top: 22, child: Icon(Icons.route_rounded, color: Colors.white.withOpacity(0.7), size: 96)),
            Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 30),
              const SizedBox(height: 12),
              const Text('Vamos nessa?', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
              const Text('Solicite uma viagem de teste.', style: TextStyle(color: Colors.white)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        Card(elevation: 0, color: Colors.white, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Minha corrida', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            CircleAvatar(backgroundColor: pink.withOpacity(0.12), child: Icon(active ? Icons.directions_car : Icons.pin_drop, color: pink)),
            const SizedBox(width: 12),
            Expanded(child: Text(statusLabel, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
          ]),
          if (ride != null) ...[
            const SizedBox(height: 8),
            Text('Identificação: ${ride!['id']}', style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: !connected || busy || active ? null : createRide,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(active ? 'Corrida em andamento' : 'Solicitar corrida'),
          )),
          TextButton.icon(onPressed: connected ? refresh : null, icon: const Icon(Icons.sync), label: const Text('Atualizar acompanhamento')),
        ]))),
        const SizedBox(height: 14),
        if (!connected) Card(elevation: 0, color: Colors.white, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Conectar ao laboratório', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: username, decoration: const InputDecoration(labelText: 'Usuário', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 8),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: connect, child: const Text('Conectar à API'))),
        ]))),
        if (error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(error!, style: TextStyle(color: theme.colorScheme.error))),
        const SizedBox(height: 12),
        const Center(child: Text('AMBIENTE DE TESTES • SEM CORRIDAS REAIS', style: TextStyle(fontSize: 11, color: Colors.black45, letterSpacing: 1))),
      ])),
    );
  }
}
