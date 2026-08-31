import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sectio_aurea/screens/cadastro.dart';
import 'package:sectio_aurea/screens/home.dart';
import 'package:sectio_aurea/screens/login.dart';
import 'package:sectio_aurea/screens/pag_inicial.dart';
import 'package:sectio_aurea/screens/teste.dart';
import 'package:sectio_aurea/screens/timers/pomodoro_screen.dart';
import 'package:sectio_aurea/screens/timers/countdown_screen.dart';
import 'package:sectio_aurea/screens/timers/stopwatch_screen.dart';
import 'package:sectio_aurea/screens/create/tasks_screen.dart';
import 'package:sectio_aurea/screens/create/add_task_screen.dart';
import 'package:sectio_aurea/screens/create/notes_screen.dart';
import 'package:sectio_aurea/screens/create/add_note_screen.dart';
import 'package:sectio_aurea/screens/create/subjects_screen.dart';
import 'package:sectio_aurea/screens/create/schedule_screen.dart';
import 'package:sectio_aurea/screens/create/calendar_screen.dart';
import 'package:sectio_aurea/screens/tabs/revisao_tab.dart';
import 'package:sectio_aurea/screens/metodos_estudo_screen.dart';
import 'package:sectio_aurea/screens/metodo_detalhe_screen.dart';
import 'package:sectio_aurea/screens/create/cornell_note_screen.dart';
import 'package:sectio_aurea/screens/podcast_instrucional_screen.dart';
import 'package:sectio_aurea/screens/grupos_estudo_screen.dart';
import 'package:sectio_aurea/screens/tools/feynman_podcast_screen.dart';
import 'package:sectio_aurea/screens/tools/leitura_savoring_screen.dart';
import 'package:sectio_aurea/screens/tools/video_library_screen.dart';
import 'package:sectio_aurea/screens/tools/grupos_estudo_hub_screen.dart';
import 'package:sectio_aurea/screens/tools/mapa_mental_screen.dart';
import 'package:sectio_aurea/screens/tools/diagrama_fluxo_screen.dart';
import 'package:sectio_aurea/screens/tools/simulado_config_screen.dart';
import 'package:sectio_aurea/models/nota.dart';
import 'package:sectio_aurea/data/metodos_data.dart';

Map<String, dynamic> _extractUser(dynamic extra) {
  if (extra is Map<String, dynamic>) {
    if (extra.containsKey("user") && extra["user"] is Map<String, dynamic>) {
      return extra["user"] as Map<String, dynamic>;
    }
    return extra;
  }
  return const {};
}

dynamic _extractParam(dynamic extra, String key) {
  if (extra is Map<String, dynamic>) {
    return extra[key];
  }
  return null;
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'inicio_landing',
      builder: (context, state) => const PagInicial(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/cadastro',
      name: 'cadastro',
      builder: (context, state) => const Cadastro(),
    ),
    GoRoute(
      path: '/teste',
      name: 'teste',
      builder: (context, state) {
        return Teste(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        return Home(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/timers/pomodoro',
      name: 'pomodoro',
      builder: (context, state) {
        return PomodoroScreen(
          u: _extractUser(state.extra),
          materia: (_extractParam(state.extra, "materia")?.toString()) ?? "",
        );
      },
    ),
    GoRoute(
      path: '/timers/countdown',
      name: 'countdown',
      builder: (context, state) {
        return CountdownScreen(
          u: _extractUser(state.extra),
          materia: (_extractParam(state.extra, "materia")?.toString()) ?? "",
        );
      },
    ),
    GoRoute(
      path: '/timers/stopwatch',
      name: 'stopwatch',
      builder: (context, state) {
        return StopwatchScreen(
          u: _extractUser(state.extra),
          materia: (_extractParam(state.extra, "materia")?.toString()) ?? "",
        );
      },
    ),
    GoRoute(
      path: '/create/tasks',
      name: 'tasks',
      builder: (context, state) {
        return TasksScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/create/tasks/add',
      name: 'add_task',
      builder: (context, state) {
        return AddTaskScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/create/notes',
      name: 'notes',
      builder: (context, state) {
        return NotesScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/create/notes/add',
      name: 'add_note',
      builder: (context, state) {
        return AddNoteScreen(
          u: _extractUser(state.extra),
          editNote: _extractParam(state.extra, "note") as Nota?,
        );
      },
    ),
    GoRoute(
      path: '/create/subjects',
      name: 'subjects',
      builder: (context, state) {
        return SubjectsScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/create/schedule',
      name: 'schedule',
      builder: (context, state) {
        return ScheduleScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/create/calendar',
      name: 'calendar',
      builder: (context, state) {
        return CalendarScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/metodos',
      name: 'metodos',
      builder: (context, state) {
        return MetodosEstudoScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/metodos/detalhe',
      name: 'metodo_detalhe',
      builder: (context, state) {
        final u = _extractUser(state.extra);
        final metodo = _extractParam(state.extra, "metodo") as MetodoEstudo;
        final inteligencia = _extractParam(state.extra, "inteligencia") as InteligenicaInfo;
        return MetodoDetalheScreen(
          u: u,
          metodo: metodo,
          inteligencia: inteligencia,
        );
      },
    ),
    GoRoute(
      path: '/create/cornell',
      name: 'cornell_note',
      builder: (context, state) {
        return CornellNoteScreen(
          u: _extractUser(state.extra),
          editNote: _extractParam(state.extra, "editNote") as Nota?,
        );
      },
    ),
    GoRoute(
      path: '/podcast-instrucional',
      name: 'podcast_instrucional',
      builder: (context, state) {
        return PodcastInstrucionalScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/grupos-estudo',
      name: 'grupos_estudo',
      builder: (context, state) {
        return GruposEstudoScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/feynman-podcast',
      name: 'feynman_podcast',
      builder: (context, state) {
        final u = _extractUser(state.extra);
        final title = (_extractParam(state.extra, "title") ?? "Técnica Feynman").toString();
        final color = _extractParam(state.extra, "color") as Color? ?? const Color(0xFFff5f00);
        return FeynmanPodcastScreen(
          u: u,
          title: title,
          themeColor: color,
        );
      },
    ),
    GoRoute(
      path: '/leitura-savoring',
      name: 'leitura_savoring',
      builder: (context, state) {
        return LeituraSavoringScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/video-library',
      name: 'video_library',
      builder: (context, state) {
        return VideoLibraryScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/grupos-estudo-hub',
      name: 'grupos_estudo_hub',
      builder: (context, state) {
        return GruposEstudoHubScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/mapa-mental',
      name: 'mapa_mental',
      builder: (context, state) {
        return MapaMentalScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/diagrama-fluxo',
      name: 'diagrama_fluxo',
      builder: (context, state) {
        return DiagramaFluxoScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/simulado-config',
      name: 'simulado_config',
      builder: (context, state) {
        return SimuladoConfigScreen(u: _extractUser(state.extra));
      },
    ),
    GoRoute(
      path: '/flashcards-revisao',
      name: 'flashcards_revisao',
      builder: (context, state) {
        final u = _extractUser(state.extra);
        Color themeColor = const Color(0xFFff5f00);
        String? hex = u["clas_inteli"];
        if (hex != null && hex.isNotEmpty) {
          try {
            themeColor = Color(int.parse(hex));
          } catch (_) {}
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Flashcards & Revisão Espaçada",
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: RevisaoTab(u: u),
        );
      },
    ),
  ],
);
