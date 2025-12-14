import 'dart:convert';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/jugador_model.dart';

List<Partido> partidoListFromJson(String str) => List<Partido>.from(
  json.decode(str)["data"].map((x) => Partido.fromJson(x)),
);

String partidoToJson(Partido data) => json.encode(data.toJson());

class Partido {
  final String id;
  final String torneo;
  final String ronda;
  final DateTime fecha;
  String estado;
  final String idJugador1;
  final String idJugador2;
  String? idGanador;
  Resultado resultado;

  Jugador? jugador1Obj;
  Jugador? jugador2Obj;

  bool esTieBreak = false;
  bool saqueJugador1 = true;

  Partido({
    required this.id,
    required this.torneo,
    required this.ronda,
    required this.fecha,
    required this.estado,
    required this.idJugador1,
    required this.idJugador2,
    required this.idGanador,
    required this.resultado,
  });

  factory Partido.fromJson(Map<String, dynamic> json) => Partido(
    id: json["id"],
    torneo: json["torneo"],
    ronda: json["ronda"],
    fecha: DateTime.parse(json["fecha"]),
    estado: json["estado"],
    idJugador1: json["idJugador1"],
    idJugador2: json["idJugador2"],
    idGanador: json["idGanador"],
    resultado: Resultado.fromJson(json["resultado"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "torneo": torneo,
    "ronda": ronda,
    "fecha": fecha.toIso8601String(),
    "estado": estado,
    "idJugador1": idJugador1,
    "idJugador2": idJugador2,
    "idGanador": idGanador,
    "resultado": resultado.toJson(),
  };

  int sumarPuntoJugador(String idJugadorQueAnota) {
    if (jugador1Obj == null || jugador2Obj == null) return 0;

    Jugador anotador = (idJugadorQueAnota == idJugador1)
        ? jugador1Obj!
        : jugador2Obj!;
    Jugador rival = (idJugadorQueAnota == idJugador1)
        ? jugador2Obj!
        : jugador1Obj!;

    if (esTieBreak) {
      anotador.aniadirPunto();
      if (anotador.puntos >= 7 && (anotador.puntos - rival.puntos) >= 2) {
        return (anotador.id == idJugador1) ? 1 : 2;
      }
      return 0;
    }

    if (rival.puntos == 4) {
      rival.puntos = 3;
      return 0;
    }
    if (anotador.puntos == 4) {
      return (anotador.id == idJugador1) ? 1 : 2;
    }
    if (anotador.puntos == 3 && rival.puntos == 3) {
      anotador.puntos = 4;
      return 0;
    }
    if (anotador.puntos == 3 && rival.puntos < 3) {
      return (anotador.id == idJugador1) ? 1 : 2;
    }

    anotador.aniadirPunto();
    return 0;
  }

  void resolverJuegoGanado(String idGanadorJuego) {
    Jugador ganador = (idGanadorJuego == idJugador1)
        ? jugador1Obj!
        : jugador2Obj!;
    Jugador perdedor = (idGanadorJuego == idJugador1)
        ? jugador2Obj!
        : jugador1Obj!;

    ganador.reiniciarPuntos();
    perdedor.reiniciarPuntos();

    int setActual = ganador.setsGanados + perdedor.setsGanados;
    if (setActual >= 3) return;

    ganador.aniadirJuego(setActual);

    int juegosG = ganador.juegos[setActual];
    int juegosP = perdedor.juegos[setActual];

    if (esTieBreak) {
      esTieBreak = false;
      ganador.aniadirSet();
      _verificarGanadorPartido(ganador);
      return;
    }

    if ((juegosG == 6 && juegosP <= 4) || (juegosG == 7 && juegosP == 5)) {
      ganador.aniadirSet();
      _verificarGanadorPartido(ganador);
    } else if (juegosG == 6 && juegosP == 6) {
      esTieBreak = true;
    }

    saqueJugador1 = !saqueJugador1;
  }

  void _verificarGanadorPartido(Jugador ganador) {
    if (ganador.setsGanados == 2) {
      idGanador = ganador.id;
      estado = "finalizado";
      resultado.setsJ1 = jugador1Obj!.setsGanados;
      resultado.setsJ2 = jugador2Obj!.setsGanados;
    }
  }

  bool hayGanador() => idGanador != null;
}

class Resultado {
  int setsJ1;
  int setsJ2;
  List<String> parciales;

  Resultado({
    required this.setsJ1,
    required this.setsJ2,
    required this.parciales,
  });

  factory Resultado.fromJson(Map<String, dynamic> json) => Resultado(
    setsJ1: json["setsJ1"],
    setsJ2: json["setsJ2"],
    parciales: List<String>.from(json["parciales"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "setsJ1": setsJ1,
    "setsJ2": setsJ2,
    "parciales": List<dynamic>.from(parciales.map((x) => x)),
  };
}
