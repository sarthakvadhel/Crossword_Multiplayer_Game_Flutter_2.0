import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/multiplayer_setup_sheet.dart';
import 'presentation/screens/profile_screen.dart';
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
  int _index = 0;
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
    _animateToIndex(1);
  }

  Future<void> _openMultiplayerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MultiplayerSetupSheet(
          onHostRoom: (name) async {
            final error =
                await ref.read(gameProvider.notifier).hostMultiplayer(name);
            if (error == null && mounted) {
              _animateToIndex(1);
            }
            return error;
          },
          onJoinRoom: (name, roomCode) async {
            final error = await ref
                .read(gameProvider.notifier)
                .joinMultiplayer(name, roomCode);
            if (error == null && mounted) {
              _animateToIndex(1);
            }
            return error;
          },
        );
      },
    );
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
              onMultiplayer: _openMultiplayerSheet,
              statusText: gameState.connectionStatus,
              roomCode: gameState.sessionCode,
              isMultiplayerActive: gameState.isMultiplayer,
            ),
            const GameScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index == 1 ? 0 : _index,
        onTap: (value) {
          // When Multiplayer tab (index 1) is tapped, open the sheet
          if (value == 1) {
            _openMultiplayerSheet();
          } else {
            _animateToIndex(value);
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
