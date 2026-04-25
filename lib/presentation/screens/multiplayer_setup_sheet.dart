import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class MultiplayerSetupSheet extends StatefulWidget {
  const MultiplayerSetupSheet({
    super.key,
    required this.onHostRoom,
    required this.onJoinRoom,
  });

  final Future<String?> Function(String name) onHostRoom;
  final Future<String?> Function(String name, String roomCode) onJoinRoom;

  @override
  State<MultiplayerSetupSheet> createState() => _MultiplayerSetupSheetState();
}

class _MultiplayerSetupSheetState extends State<MultiplayerSetupSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _roomController;

  bool _busy = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _roomController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _hostRoom() async {
    setState(() {
      _busy = true;
      _errorText = null;
    });

    final error = await widget.onHostRoom(_nameController.text);
    if (!mounted) {
      return;
    }
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _busy = false;
      _errorText = error;
    });
  }

  Future<void> _joinRoom() async {
    setState(() {
      _busy = true;
      _errorText = null;
    });

    final error = await widget.onJoinRoom(
      _nameController.text,
      _roomController.text,
    );
    if (!mounted) {
      return;
    }
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _busy = false;
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, bottomInset + 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'LAN Multiplayer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Both players need to be on the same Wi-Fi. The host shares a room code like 192.168.1.12:4040.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Player name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Host room code',
                  hintText: '192.168.1.12:4040',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _busy ? null : _hostRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: Text(_busy ? 'Working...' : 'Host Room'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy ? null : _joinRoom,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: const Text('Join Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
