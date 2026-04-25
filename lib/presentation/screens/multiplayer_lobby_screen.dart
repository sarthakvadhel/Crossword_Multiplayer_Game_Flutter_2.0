import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/game_state_model.dart';
import '../widgets/lobby_header.dart';
import '../widgets/player_tile.dart';
import '../widgets/room_tile.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({
    super.key,
    required this.gameState,
    required this.onCreateRoom,
    required this.onJoinRoom,
    required this.onRoomConnected,
  });

  final GameStateModel gameState;
  final Future<String?> Function(String name) onCreateRoom;
  final Future<String?> Function(String name, String roomCode) onJoinRoom;
  final VoidCallback onRoomConnected;

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _roomCodeController;
  bool _busy = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final currentName = widget.gameState.player.name == 'Waiting for opponent'
        ? ''
        : widget.gameState.player.name;
    _nameController = TextEditingController(text: currentName);
    _roomCodeController =
        TextEditingController(text: widget.gameState.sessionCode ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() {
      _busy = true;
      _errorText = null;
    });
    final error = await widget.onCreateRoom(_nameController.text);
    if (!mounted) {
      return;
    }
    if (error == null) {
      widget.onRoomConnected();
      return;
    }
    setState(() {
      _busy = false;
      _errorText = error;
    });
  }

  Future<void> _joinRoom([String? presetRoomCode]) async {
    setState(() {
      _busy = true;
      _errorText = null;
    });
    final room = presetRoomCode ?? _roomCodeController.text;
    final error = await widget.onJoinRoom(_nameController.text, room);
    if (!mounted) {
      return;
    }
    if (error == null) {
      widget.onRoomConnected();
      return;
    }
    setState(() {
      _busy = false;
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final localReady = state.player.name != 'Waiting for opponent';
    final opponentReady = state.hasOpponent;
    final roomId = state.sessionCode;
    final players = <({String name, bool ready, bool local})>[
      (name: state.player.name, ready: localReady, local: true),
      (name: state.opponent.name, ready: opponentReady, local: false),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LobbyHeader(
              statusText: state.connectionStatus,
              roomId: roomId,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Player name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomCodeController,
              decoration: const InputDecoration(
                labelText: 'Room ID',
                hintText: '192.168.1.12:4040',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _createRoom,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.primary,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(_busy ? 'Working...' : 'Create Room'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : () => _joinRoom(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Join Room'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Available Players',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...players.map(
              (player) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PlayerTile(
                  name: player.name,
                  isReady: player.ready,
                  isLocal: player.local,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Active Rooms',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            if (roomId != null)
              RoomTile(
                roomId: roomId,
                isJoinable: !_busy,
                onJoin: () => _joinRoom(roomId),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: const Text(
                  'No active rooms yet. Create one to start.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
