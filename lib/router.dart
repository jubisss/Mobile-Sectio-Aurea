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
        final user = state.extra as Map<String, dynamic>;
        return Teste(u: user);
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return Home(u: user);
      },
    ),
    GoRoute(
      path: '/timers/pomodoro',
      name: 'pomodoro',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        return PomodoroScreen(u: params["user"], materia: params["materia"]);
      },
    ),
    GoRoute(
      path: '/timers/countdown',
      name: 'countdown',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        return CountdownScreen(u: params["user"], materia: params["materia"]);
      },
    ),
    GoRoute(
      path: '/timers/stopwatch',
      name: 'stopwatch',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        return StopwatchScreen(u: params["user"], materia: params["materia"]);
      },
    ),
    GoRoute(
      path: '/create/tasks',
      name: 'tasks',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return TasksScreen(u: user);
      },
    ),
    GoRoute(
      path: '/create/tasks/add',
      name: 'add_task',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return AddTaskScreen(u: user);
      },
    ),
    GoRoute(
      path: '/create/notes',
      name: 'notes',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return NotesScreen(u: user);
      },
    ),
    GoRoute(
      path: '/create/notes/add',
      name: 'add_note',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        return AddNoteScreen(u: params["user"], editNote: params["note"]);
      },
    ),
    GoRoute(
      path: '/create/subjects',
      name: 'subjects',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return SubjectsScreen(u: user);
      },
    ),
    GoRoute(
      path: '/create/schedule',
      name: 'schedule',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return ScheduleScreen(u: user);
      },
    ),
    GoRoute(
      path: '/create/calendar',
      name: 'calendar',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return CalendarScreen(u: user);
      },
    ),
  ],
);
