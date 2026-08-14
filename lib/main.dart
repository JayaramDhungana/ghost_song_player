import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'blocs/player/player_bloc.dart';
import 'services/audio_service.dart';
import 'views/player_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final audioService = AudioService();

  runApp(GhostPlayerApp(audioService: audioService));
}

class GhostPlayerApp extends StatelessWidget {
  final AudioService audioService;

  const GhostPlayerApp({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerBloc(audioService: audioService),
      child: MaterialApp.router(
        title: 'GhostPlayer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/player',
  routes: [
    GoRoute(
      path: '/player',
      name: 'player',
      builder: (context, state) => const PlayerView(),
    ),
  ],
);

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.expand());
  }
}

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Admin')));
  }
}
