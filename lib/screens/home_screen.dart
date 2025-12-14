import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/partido_model.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/services/api_service.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/screens/crea_nuevo_partido_screen.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/screens/partido_screen.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/screens/resultado_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String name = 'home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Partido> partidos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    setState(() => _cargando = true);
    final lista = await _apiService.getPartidos();
    if (mounted) {
      setState(() {
        partidos = lista;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Torneo Ahmed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarPartidos,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarPartidos,
              child: ListView.builder(
                itemCount: partidos.length,
                itemBuilder: (context, index) {
                  final partido = partidos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      onTap: () {
                        if (partido.estado == 'finalizado') {
                          context.pushNamed(
                            ResultadoScreen.name,
                            extra: partido,
                          );
                        } else {
                          context
                              .pushNamed(PartidoScreen.name, extra: partido)
                              .then((_) {
                                _cargarPartidos();
                              });
                        }
                      },
                      leading: const Icon(Icons.sports_tennis),
                      title: Text(
                        "${partido.jugador1Obj?.nombre ?? 'J1'} vs ${partido.jugador2Obj?.nombre ?? 'J2'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${partido.torneo} - ${partido.ronda}"),
                      trailing: partido.estado == 'finalizado'
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward_ios),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(CreaNuevoPartidoScreen.name).then((_) {
            _cargarPartidos();
          });
        },
        backgroundColor: colors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
