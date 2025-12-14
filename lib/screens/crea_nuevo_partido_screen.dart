import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/jugador_model.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/partido_model.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/services/api_service.dart';

class CreaNuevoPartidoScreen extends StatefulWidget {
  static const String name = 'crea_nuevo_partido_screen';

  const CreaNuevoPartidoScreen({super.key});

  @override
  State<CreaNuevoPartidoScreen> createState() => _CreaNuevoPartidoScreenState();
}

class _CreaNuevoPartidoScreenState extends State<CreaNuevoPartidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _torneoController = TextEditingController();
  final TextEditingController _rondaController = TextEditingController();

  List<Jugador> _jugadoresDisponibles = [];
  String? _idJugador1Seleccionado;
  String? _idJugador2Seleccionado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarJugadores();
  }

  Future<void> _cargarJugadores() async {
    final jugadores = await _apiService.getAllJugadores();
    if (mounted) {
      setState(() {
        _jugadoresDisponibles = jugadores;
      });
    }
  }

  String _getNombreJugador(String? id) {
    if (id == null) return 'Ninguno seleccionado';
    try {
      final jugador = _jugadoresDisponibles.firstWhere((j) => j.id == id);
      return jugador.nombre;
    } catch (e) {
      return 'Jugador desconocido';
    }
  }

  Future<void> _guardarPartido() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idJugador1Seleccionado == null || _idJugador2Seleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona dos jugadores')));
      return;
    }

    if (_idJugador1Seleccionado == _idJugador2Seleccionado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los jugadores deben ser diferentes')),
      );
      return;
    }

    setState(() => _guardando = true);

    final nuevoPartido = Partido(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      torneo: _torneoController.text,
      ronda: _rondaController.text,
      fecha: DateTime.now(),
      estado: "pendiente",
      idJugador1: _idJugador1Seleccionado!,
      idJugador2: _idJugador2Seleccionado!,
      idGanador: null,
      resultado: Resultado(setsJ1: 0, setsJ2: 0, parciales: []),
    );

    final exito = await _apiService.createPartido(nuevoPartido);

    setState(() => _guardando = false);

    if (exito && mounted) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error de conexión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Partido')),
      body: _guardando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _torneoController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Torneo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emoji_events),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _rondaController,
                      decoration: const InputDecoration(
                        labelText: 'Ronda',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: ExpansionTile(
                        title: Text(
                          _idJugador1Seleccionado == null
                              ? 'Seleccionar Jugador 1'
                              : 'Jugador 1',
                        ),
                        subtitle: Text(
                          _getNombreJugador(_idJugador1Seleccionado),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        leading: const Icon(Icons.person),
                        children: _jugadoresDisponibles.map((jugador) {
                          return RadioListTile<String>(
                            title: Text(jugador.nombre),
                            value: jugador.id,
                            groupValue: _idJugador1Seleccionado,
                            onChanged: (value) {
                              setState(() {
                                _idJugador1Seleccionado = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: ExpansionTile(
                        title: Text(
                          _idJugador2Seleccionado == null
                              ? 'Seleccionar Jugador 2'
                              : 'Jugador 2',
                        ),
                        subtitle: Text(
                          _getNombreJugador(_idJugador2Seleccionado),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        leading: const Icon(Icons.person_outline),
                        children: _jugadoresDisponibles.map((jugador) {
                          return RadioListTile<String>(
                            title: Text(jugador.nombre),
                            value: jugador.id,
                            groupValue: _idJugador2Seleccionado,
                            onChanged: (value) {
                              setState(() {
                                _idJugador2Seleccionado = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: _guardarPartido,
                      icon: const Icon(Icons.save),
                      label: const Text('CREAR PARTIDO'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
