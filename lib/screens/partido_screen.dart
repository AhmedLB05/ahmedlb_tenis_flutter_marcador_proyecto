import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/partido_model.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/jugador_model.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/services/api_service.dart';

class PartidoScreen extends StatefulWidget {
  static const String name = 'partido_screen';

  final Partido partido;

  const PartidoScreen({super.key, required this.partido});

  @override
  State<PartidoScreen> createState() => _PartidoScreenState();
}

class _PartidoScreenState extends State<PartidoScreen> {
  late Partido _partido;
  final ApiService _apiService = ApiService();

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _partido = widget.partido;
  }

  void _procesarPunto(String idJugador) {
    if (_partido.hayGanador()) return;

    int resultadoJuego = _partido.sumarPuntoJugador(idJugador);

    if (resultadoJuego != 0) {
      String idGanadorJuego = (resultadoJuego == 1)
          ? _partido.idJugador1
          : _partido.idJugador2;

      _partido.resolverJuegoGanado(idGanadorJuego);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Juego para ${_getNombreJugador(idGanadorJuego)}"),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    setState(() {});

    if (_partido.hayGanador()) {
      _mostrarDialogoFinPartido();
    }
  }

  String _getNombreJugador(String id) {
    if (id == _partido.idJugador1) return _partido.jugador1Obj?.nombre ?? 'J1';
    return _partido.jugador2Obj?.nombre ?? 'J2';
  }

  Future<void> _guardarYSalir() async {
    setState(() => _guardando = true);
    bool exito = await _apiService.finalizarPartido(_partido);
    setState(() => _guardando = false);

    if (exito && mounted) {
      context.go('/');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el resultado')),
      );
    }
  }

  void _mostrarDialogoFinPartido() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Partido Finalizado!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            const SizedBox(height: 10),
            Text(
              "Ganador: ${_getNombreJugador(_partido.idGanador!)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _guardarYSalir();
            },
            child: const Text("Guardar y Salir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final j1 = _partido.jugador1Obj!;
    final j2 = _partido.jugador2Obj!;

    return Scaffold(
      appBar: AppBar(
        title: Text("${_partido.torneo} - ${_partido.ronda}"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: _guardando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _ColumnaMarcadorJugador(
                          jugador: j1,
                          tieneSaque: _partido.saqueJugador1,
                          esGanador: _partido.idGanador == j1.id,
                          colorFondo: Colors.green.shade50,
                        ),
                      ),
                      const VerticalDivider(width: 1, thickness: 1),
                      Expanded(
                        child: _ColumnaMarcadorJugador(
                          jugador: j2,
                          tieneSaque: !_partido.saqueJugador1,
                          esGanador: _partido.idGanador == j2.id,
                          colorFondo: Colors.blue.shade50,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: _partido.hayGanador()
                                ? null
                                : () => _procesarPunto(j1.id),
                            child: const Text(
                              "PUNTO J1",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: _partido.hayGanador()
                                ? null
                                : () => _procesarPunto(j2.id),
                            child: const Text(
                              "PUNTO J2",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ColumnaMarcadorJugador extends StatelessWidget {
  final Jugador jugador;
  final bool tieneSaque;
  final bool esGanador;
  final Color colorFondo;

  const _ColumnaMarcadorJugador({
    required this.jugador,
    required this.tieneSaque,
    required this.esGanador,
    required this.colorFondo,
  });

  String _obtenerTextoPuntos(int puntos) {
    if (puntos > 4) return puntos.toString();
    switch (puntos) {
      case 0:
        return "0";
      case 1:
        return "15";
      case 2:
        return "30";
      case 3:
        return "40";
      case 4:
        return "AD";
      default:
        return puntos.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: esGanador ? Colors.amber.shade100 : colorFondo,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (tieneSaque)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.sports_tennis, color: Colors.orange, size: 30),
            )
          else
            const SizedBox(height: 38),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: jugador.foto.isNotEmpty
                ? NetworkImage(jugador.foto)
                : null,
            child: jugador.foto.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 15),
          Text(
            jugador.nombre,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Text(
            "SETS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  jugador.juegos[index].toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _obtenerTextoPuntos(jugador.puntos),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.yellowAccent,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
