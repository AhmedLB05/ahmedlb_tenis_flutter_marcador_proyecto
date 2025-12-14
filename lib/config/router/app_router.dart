import 'package:go_router/go_router.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/screens/home_screen.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/screens/crea_nuevo_partido_screen.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/screens/partido_screen.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/models/partido_model.dart';
import 'package:ahmedlb_tenis_flutter_marcador_proyecto/screens/resultado_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create',
      name: CreaNuevoPartidoScreen.name,
      builder: (context, state) => const CreaNuevoPartidoScreen(),
    ),
    GoRoute(
      path: '/partido',
      name: PartidoScreen.name,
      builder: (context, state) {
        final partido = state.extra as Partido;
        return PartidoScreen(partido: partido);
      },
    ),
    GoRoute(
      path: '/resultado',
      name: ResultadoScreen.name,
      builder: (context, state) {
        final partido = state.extra as Partido;
        return ResultadoScreen(partido: partido);
      },
    ),
  ],
);
