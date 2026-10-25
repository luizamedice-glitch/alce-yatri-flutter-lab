import 'package:flutter/material.dart';

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
  String status = 'Nenhuma corrida';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alce Yatri • Passageiro')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Laboratório offline — dados simulados.'),
        const SizedBox(height: 24),
        Text('Estado: $status', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => setState(() => status = 'Corrida solicitada (simulação)'),
          child: const Text('Simular solicitação')),
        OutlinedButton(onPressed: () => setState(() => status = 'Nenhuma corrida'),
          child: const Text('Reiniciar')),
      ]),
    ),
  );
}
