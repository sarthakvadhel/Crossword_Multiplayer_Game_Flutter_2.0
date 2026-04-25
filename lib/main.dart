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

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  Future<void> _startSoloGame() async {
    await ref.read(gameProvider.notifier).startSoloPractice();
    if (!mounted) {
      return;
    }
    setState(() => _index = 1);
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
              setState(() => _index = 1);
            }
            return error;
          },
          onJoinRoom: (name, roomCode) async {
            final error = await ref
                .read(gameProvider.notifier)
                .joinMultiplayer(name, roomCode);
            if (error == null && mounted) {
              setState(() => _index = 1);
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
      body: IndexedStack(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index == 1 ? 0 : _index,
        onTap: (value) {
          // When Multiplayer tab (index 1) is tapped, open the sheet
          if (value == 1) {
            _openMultiplayerSheet();
          } else {
            setState(() => _index = value);
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
