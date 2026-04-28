import 'dart:async';
import 'dart:convert';
import 'dart:io';

class LeaderboardPlayer {
  const LeaderboardPlayer({
    required this.id,
    required this.name,
    required this.score,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final int score;
  final String? avatarUrl;
}

class HostedRoomInfo {
  const HostedRoomInfo({
    required this.host,
    required this.port,
  });

  final String host;
  final int port;

  String get shareCode => '$host:$port';
}

class LocalMultiplayerService {
  final StreamController<Map<String, dynamic>> _messagesController =
      StreamController<Map<String, dynamic>>.broadcast();

  HttpServer? _server;
  WebSocket? _socket;

  Stream<Map<String, dynamic>> get messages => _messagesController.stream;

  Future<List<LeaderboardPlayer>> fetchLeaderboard({
    required String currentPlayerId,
    required String currentPlayerName,
    required int currentPlayerScore,
    String? currentPlayerAvatarUrl,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final players = <LeaderboardPlayer>[
      LeaderboardPlayer(
        id: currentPlayerId,
        name: currentPlayerName.trim().isEmpty ? 'You' : currentPlayerName,
        score: currentPlayerScore,
        avatarUrl: currentPlayerAvatarUrl,
      ),
      const LeaderboardPlayer(
        id: 'remote-1',
        name: 'Lexi',
        score: 95,
      ),
      const LeaderboardPlayer(
        id: 'remote-2',
        name: 'Arjun',
        score: 88,
      ),
      const LeaderboardPlayer(
        id: 'remote-3',
        name: 'Mina',
        score: 82,
      ),
      const LeaderboardPlayer(
        id: 'remote-4',
        name: 'Zoe',
        score: 76,
      ),
    ];
    players.sort((a, b) => b.score.compareTo(a.score));
    return List<LeaderboardPlayer>.unmodifiable(players);
  }

  Future<HostedRoomInfo> startHosting({int preferredPort = 4040}) async {
    await reset();

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, preferredPort);
    } on SocketException {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    }

    unawaited(_server!.forEach(_handleRequest));

    final address = await _findUsableAddress();
    if (address == null) {
      await reset();
      throw StateError('No usable local network address was found.');
    }

    return HostedRoomInfo(host: address, port: _server!.port);
  }

  Future<void> joinRoom({
    required String host,
    required int port,
  }) async {
    await reset();
    _socket = await WebSocket.connect('ws://$host:$port');
    _bindSocket(_socket!, disconnectEventType: 'host_disconnected');
  }

  Future<void> sendMessage(Map<String, dynamic> payload) async {
    final socket = _socket;
    if (socket == null) {
      throw StateError('No active multiplayer socket is connected.');
    }
    socket.add(jsonEncode(payload));
  }

  Future<void> reset() async {
    await _socket?.close();
    _socket = null;
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> dispose() async {
    await reset();
    await _messagesController.close();
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      return;
    }

    if (_socket != null) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
      await request.response.close();
      _messagesController.add({'type': 'room_full'});
      return;
    }

    final socket = await WebSocketTransformer.upgrade(request);
    _socket = socket;
    _messagesController.add({'type': 'peer_connected'});
    _bindSocket(socket, disconnectEventType: 'peer_disconnected');
  }

  void _bindSocket(
    WebSocket socket, {
    required String disconnectEventType,
  }) {
    socket.listen(
      (dynamic rawMessage) {
        if (rawMessage is! String) {
          return;
        }
        try {
          final decoded = jsonDecode(rawMessage);
          if (decoded is Map<String, dynamic>) {
            _messagesController.add(decoded);
            return;
          }
          _messagesController.add({
            'type': 'transport_error',
            'message':
                'Expected Map<String, dynamic> but received ${decoded.runtimeType}.',
          });
        } on FormatException {
          _messagesController.add({
            'type': 'transport_error',
            'message':
                'Received invalid JSON from peer (${rawMessage.length} chars).',
          });
        }
      },
      onError: (Object error) {
        _messagesController.add({
          'type': 'transport_error',
          'message': error.toString(),
        });
      },
      onDone: () {
        if (!identical(_socket, socket)) {
          return;
        }
        _socket = null;
        _messagesController.add({'type': disconnectEventType});
      },
      cancelOnError: true,
    );
  }

  Future<String?> _findUsableAddress() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback) {
          return address.address;
        }
      }
    }

    return null;
  }
}
