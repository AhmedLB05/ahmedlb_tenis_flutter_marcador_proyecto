import 'dart:convert';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/jugador_model.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/partido_model.dart';
import 'package:http/http.dart';

class ApiService {
  final String _url =
      'https://backend-tenis-ahmedlb-production.up.railway.app/api/v1';

  Future<List<Partido>> getPartidos() async {
    List<Partido> partidos = [];
    Uri uri = Uri.parse('$_url/partidos');
    Response response = await get(uri);

    if (response.statusCode != 200) return partidos;

    partidos = partidoListFromJson(response.body);

    for (var partido in partidos) {
      Jugador? jugador1 = await getJugadorById(partido.idJugador1);
      if (jugador1 != null) {
        partido.jugador1Obj = jugador1;
      }

      Jugador? jugador2 = await getJugadorById(partido.idJugador2);
      if (jugador2 != null) {
        partido.jugador2Obj = jugador2;
      }
    }

    return partidos;
  }

  Future<Jugador?> getJugadorById(String id) async {
    Uri uri = Uri.parse('$_url/jugadores/$id');
    Response response = await get(uri);

    if (response.statusCode != 200) return null;

    final jsonBody = jsonDecode(response.body);
    return Jugador.fromJson(jsonBody['data']);
  }

  Future<bool> finalizarPartido(Partido partido) async {
    Uri uri = Uri.parse('$_url/partidos/${partido.id}');
    String body = partidoToJson(partido);

    Response response = await patch(
      uri,
      body: body,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) return false;

    return true;
  }

  Future<bool> createPartido(Partido partido) async {
    Uri uri = Uri.parse('$_url/partidos');
    String body = partidoToJson(partido);

    try {
      Response response = await post(
        uri,
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Jugador>> getAllJugadores() async {
    Uri uri = Uri.parse('$_url/jugadores');
    try {
      Response response = await get(uri);
      if (response.statusCode == 200) {
        return jugadorListFromJson(response.body);
      }
    } catch (e) {}
    return [];
  }

  Future<Partido?> getPartidoById(String id) async {
    Uri uri = Uri.parse('$_url/partidos/$id');
    try {
      Response response = await get(uri);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        Partido partido = Partido.fromJson(jsonBody['data']);

        partido.jugador1Obj = await getJugadorById(partido.idJugador1);
        partido.jugador2Obj = await getJugadorById(partido.idJugador2);

        return partido;
      }
    } catch (e) {}
    return null;
  }
}
