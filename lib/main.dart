import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_event_bus.dart';
import 'features/cinema/controller/cinema_bloc.dart';
import 'features/cinema/data/data_sources/cinema_repository.dart';
import 'features/cinema/view/cinema_page.dart';
import 'features/dashboard/controller/dashboard_bloc.dart';
import 'features/dashboard/data/data_sources/movie_repository.dart';
import 'features/dashboard/view/dashboard.dart';
import 'features/reminder/controller/reminder_bloc.dart';
import 'features/reminder/data/data_sources/reminder_repository.dart';
import 'features/reminder/view/reminder_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final reminderRepository = ReminderRepository(await SharedPreferences.getInstance());
  await reminderRepository.init();
  runApp(App(reminderRepository: reminderRepository));
}

class App extends StatelessWidget {
  const App({super.key, required this.reminderRepository});

  final ReminderRepository reminderRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => MovieRepository()),
        RepositoryProvider(create: (_) => CinemaRepository()),
        RepositoryProvider.value(value: reminderRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                DashboardBloc(context.read<MovieRepository>())..add(const DashboardStarted()),
          ),
          BlocProvider(
            lazy: false,
            create: (context) =>
                CinemaBloc(context.read<CinemaRepository>())..add(const CinemaStarted()),
          ),
          BlocProvider(
            create: (context) =>
                ReminderBloc(context.read<ReminderRepository>())..add(const ReminderStarted()),
          ),
        ],
        child: MaterialApp(
          title: 'StarCine',
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  late final StreamSubscription<ShowCinemaEvent> _cinemaSubscription;
  late final StreamSubscription<MessageEvent> _messageSubscription;

  @override
  void initState() {
    super.initState();
    _cinemaSubscription = eventBus.on<ShowCinemaEvent>().listen((_) {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      setState(() => _index = 1);
    });
    _messageSubscription = eventBus.on<MessageEvent>().listen((event) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(event.message)));
    });
  }

  @override
  void dispose() {
    _cinemaSubscription.cancel();
    _messageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [DashboardPage(), CinemaPage(), ReminderPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.movie_outlined), label: 'Movies'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), label: 'Cinemas'),
          NavigationDestination(icon: Icon(Icons.alarm), label: 'Reminders'),
        ],
      ),
    );
  }
}
