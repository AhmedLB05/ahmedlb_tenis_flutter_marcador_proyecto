import 'dart:convert';

List<Jugador> jugadorListFromJson(String str) => List<Jugador>.from(
  json.decode(str)["jugadores"].map((x) => Jugador.fromJson(x)),
);

String jugadorToJson(Jugador data) => json.encode(data.toJson());

class Jugador {
  final String id;
  final String nombre;
  final String foto;
  final int ranking;
  final String pais;

  int puntos = 0;
  List<int> juegos = [0, 0, 0];
  int setsGanados = 0;

  Jugador({
    required this.id,
    required this.nombre,
    required this.foto,
    required this.ranking,
    required this.pais,
  });

  factory Jugador.fromJson(Map<String, dynamic> json) => Jugador(
    id: json["id"],
    nombre: json["nombre"],
    foto: json["foto"],
    ranking: json["ranking"],
    pais: json["pais"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "foto": foto,
    "ranking": ranking,
    "pais": pais,
  };

  void aniadirPunto() {
    puntos++;
  }

  void reiniciarPuntos() {
    puntos = 0;
  }

  void aniadirJuego(int setIndex) {
    if (setIndex < 3) {
      juegos[setIndex]++;
    }
  }

  void aniadirSet() {
    setsGanados++;
  }

  @override
  String toString() => 'Jugador: $nombre';
}
