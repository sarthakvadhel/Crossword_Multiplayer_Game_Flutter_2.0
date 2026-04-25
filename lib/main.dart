import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/multiplayer_lobby_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/tournament_mode_screen.dart';
import 'state/game_provider.dart';

void main() {
  runApp(const ProviderScope(child: CrosswordMasterApp()));
}

class CrosswordMasterApp extends StatelessWidget {
  const CrosswordMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crossword Master',
      theme: AppTheme.light(),
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  static const int _homeIndex = 0;
  static const int _lobbyIndex = 1;
  static const int _gameIndex = 2;
  static const int _profileIndex = 3;

  int _index = _homeIndex;
  late final AnimationController _screenTransitionController;
  late final Animation<double> _screenTransition;
  double _slideDirection = 1;

  @override
  void initState() {
    super.initState();
    _screenTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1,
    );
    _screenTransition = CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _screenTransitionController.dispose();
    super.dispose();
  }

  void _animateToIndex(int value) {
    if (value == _index) {
      return;
    }
    _slideDirection = value > _index ? 1 : -1;
    setState(() => _index = value);
    _screenTransitionController.forward(from: 0);
  }

  Future<void> _startSoloGame() async {
    await ref.read(gameProvider.notifier).startSoloPractice();
    if (!mounted) {
      return;
    }
    _animateToIndex(_gameIndex);
  }

  Future<void> _openMultiplayerLobby() async {
    _animateToIndex(_lobbyIndex);
  }

  Future<void> _startTournamentMode() async {
    await ref.read(gameProvider.notifier).startSoloPractice();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TournamentModeScreen()),
    );
  }

  Future<String?> _hostMultiplayerFromLobby(String name) async {
    final error = await ref.read(gameProvider.notifier).hostMultiplayer(name);
    if (error == null && mounted) {
      _animateToIndex(_gameIndex);
    }
    return error;
  }

  Future<String?> _joinMultiplayerFromLobby(String name, String roomCode) async {
    final error =
        await ref.read(gameProvider.notifier).joinMultiplayer(name, roomCode);
    if (error == null && mounted) {
      _animateToIndex(_gameIndex);
    }
    return error;
  }

  int _bottomNavIndexForBody(int index) {
    if (index == _homeIndex || index == _gameIndex) {
      return 0;
    }
    if (index == _lobbyIndex) {
      return 1;
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _screenTransition,
        builder: (context, child) {
          final t = _screenTransition.value;
          final slideX = (1 - t) * 24 * _slideDirection;
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(slideX, 0),
              child: child,
            ),
          );
        },
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              onContinue: _startSoloGame,
              onRestart: _startSoloGame,
              onMultiplayer: _openMultiplayerLobby,
              onTournament: _startTournamentMode,
              statusText: gameState.connectionStatus,
              roomCode: gameState.sessionCode,
              isMultiplayerActive: gameState.isMultiplayer,
            ),
            MultiplayerLobbyScreen(
              gameState: gameState,
              onCreateRoom: _hostMultiplayerFromLobby,
              onJoinRoom: _joinMultiplayerFromLobby,
              onRoomConnected: () => _animateToIndex(_gameIndex),
            ),
            const GameScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndexForBody(_index),
        onTap: (value) {
          // Main / Multiplayer / Me tabs.
          if (value == 1) {
            _openMultiplayerLobby();
          } else if (value == 2) {
            _animateToIndex(_profileIndex);
          } else {
            _animateToIndex(_homeIndex);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Main',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Multiplayer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}
