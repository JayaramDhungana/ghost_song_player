import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';

import 'package:just_audio_background/just_audio_background.dart';
import 'blocs/player/player_bloc.dart';
import 'services/audio_service.dart';
import 'views/player_view.dart';
import 'views/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize media_kit for Windows/Linux — must be called before any AudioPlayer is created.
  if (!kIsWeb) {
    JustAudioMediaKit.ensureInitialized(
      android: false,
      iOS: false,
      macOS: false,
      windows: true,
      linux: true,
    );
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }

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
        title: 'JD Media Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashView(),
    ),
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
