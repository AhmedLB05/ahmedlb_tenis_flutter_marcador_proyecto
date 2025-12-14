import 'package:flutter/material.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/partido_model.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/jugador_model.dart';

class ResultadoScreen extends StatelessWidget {
  static const String name = 'resultado_screen';
  final Partido partido;

  const ResultadoScreen({super.key, required this.partido});

  @override
  Widget build(BuildContext context) {
    final j1 = partido.jugador1Obj!;
    final j2 = partido.jugador2Obj!;

    final bool ganaJ1 = partido.idGanador == partido.idJugador1;
    final Jugador ganador = ganaJ1 ? j1 : j2;

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado Final')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              "Ganador del Torneo",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            Text(
              ganador.nombre.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Card(
              color: ganaJ1 ? Colors.green.shade100 : Colors.white,
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: j1.foto.isNotEmpty
                      ? NetworkImage(j1.foto)
                      : null,
                  child: j1.foto.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(
                  j1.nombre,
                  style: TextStyle(
                    fontWeight: ganaJ1 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: ganaJ1
                    ? const Text(
                        "VICTORIA",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text("Finalista"),
                trailing: Text(
                  "${partido.resultado.setsJ1}",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: !ganaJ1 ? Colors.green.shade100 : Colors.white,
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: j2.foto.isNotEmpty
                      ? NetworkImage(j2.foto)
                      : null,
                  child: j2.foto.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(
                  j2.nombre,
                  style: TextStyle(
                    fontWeight: !ganaJ1 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: !ganaJ1
                    ? const Text(
                        "VICTORIA",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text("Finalista"),
                trailing: Text(
                  "${partido.resultado.setsJ2}",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
