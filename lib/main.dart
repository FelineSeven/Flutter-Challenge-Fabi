import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() => runApp(const GreenGoApp());

class Entrega {
  final String id;
  final String cliente;
  bool entregado;

  Entrega({
    required this.id,
    required this.cliente,
    this.entregado = false,
  });
}

class GreenGoApp extends StatefulWidget {
  const GreenGoApp({super.key});

  @override
  State<GreenGoApp> createState() => _GreenGoAppState();
}

class _GreenGoAppState extends State<GreenGoApp> {
  final List<Entrega> _entregas = [
    Entrega(id: '1', cliente: 'Café Rose'),
    Entrega(id: '2', cliente: 'Floristeria Miss Lavanda'),
    Entrega(id: '3', cliente: 'Panadería Mmm... Croissant'),
  ];

  void _marcarEntregado(String id) {
    setState(() {
      final entrega = _entregas.firstWhere((e) => e.id == id);
      entrega.entregado = !entrega.entregado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenGo Logistics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          primary: const Color(0xFFB388FF),
          secondary: const Color(0xFFF8BBD0),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('💜 GreenGo Logistics'),
            backgroundColor: const Color(0xFFE1BEE7),
            bottom: const TabBar(
              indicatorColor: Colors.deepPurple,
              tabs: [
                Tab(icon: Icon(Icons.pedal_bike), text: 'Repartidor'),
                Tab(icon: Icon(Icons.supervisor_account), text: 'Supervisor'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _RepartidorScreen(entregas: _entregas, onEntregar: _marcarEntregado),
              _SupervisorScreen(entregas: _entregas),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepartidorScreen extends StatefulWidget {
  final List<Entrega> entregas;
  final Function(String) onEntregar;

  const _RepartidorScreen({required this.entregas, required this.onEntregar});

  @override
  State<_RepartidorScreen> createState() => _RepartidorScreenState();
}

class _RepartidorScreenState extends State<_RepartidorScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _verificarEntregas() {
    final completadas = widget.entregas.where((e) => e.entregado).length;
    if (completadas == widget.entregas.length) {
      _confettiController.play();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎉 ¡Felicidades!'),
          content: const Text(
              'Has completado todas tus entregas \n¡Excelente trabajo! 💜'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Yupii!'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF3E5F5),
          padding: const EdgeInsets.all(12),
          child: ListView.builder(
            itemCount: widget.entregas.length,
            itemBuilder: (context, index) {
              final entrega = widget.entregas[index];
              return Card(
                color: entrega.entregado ? const Color(0xFFE1BEE7) : Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: Icon(
                    entrega.entregado ? Icons.favorite : Icons.pedal_bike,
                    color: entrega.entregado ? Colors.purple : Colors.grey,
                    size: 32,
                  ),
                  title: Text(
                    entrega.cliente,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    entrega.entregado
                        ? 'Entregado con amor <3'
                        : 'Pendiente de entrega',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      widget.onEntregar(entrega.id);
                      _verificarEntregas();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: entrega.entregado
                          ? Colors.purple[200]
                          : Colors.pinkAccent[100],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                        entrega.entregado ? 'Desmarcar' : 'Pedido entregado'),
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.purple,
              Colors.pink,
              Colors.amber,
              Colors.white,
            ],
          ),
        ),
      ],
    );
  }
}

class _SupervisorScreen extends StatelessWidget {
  final List<Entrega> entregas;

  const _SupervisorScreen({required this.entregas});

  @override
  Widget build(BuildContext context) {
    final completadas =
        entregas.where((e) => e.entregado).length / entregas.length;

    return Container(
      color: const Color(0xFFF8BBD0),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Progreso de entregas 💜',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: completadas,
            backgroundColor: Colors.white,
            color: Colors.purpleAccent,
            minHeight: 10,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: entregas.length,
              itemBuilder: (context, index) {
                final entrega = entregas[index];
                return Card(
                  color: entrega.entregado
                      ? Colors.purple[100]
                      : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      entrega.entregado ? Icons.check_circle : Icons.timer,
                      color: entrega.entregado ? Colors.purple : Colors.pink,
                    ),
                    title: Text(
                      entrega.cliente,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(entrega.entregado
                        ? 'Entregado 💌'
                        : 'Pendiente 🚴‍♀️'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

