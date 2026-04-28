import 'dart:async';
import 'dart:convert';
import 'dart:io';

class HostedRoomInfo {
  final String host;
  final int port;
  const HostedRoomInfo({required this.host, required this.port});
  String get shareCode => '$host:$port';
}

class MultiplayerService {
  final StreamController<Map<String, dynamic>> _events =
      StreamController<Map<String, dynamic>>.broadcast();

  HttpServer? _server;
  WebSocket? _socket;

  Stream<Map<String, dynamic>> get events => _events.stream;
  bool get isConnected => _socket != null;

  /// Start hosting – opens a WebSocket server on the local network
  Future<HostedRoomInfo> startHosting({int preferredPort = 4040}) async {
    await _cleanup();
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, preferredPort);
    } on SocketException {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    }
    _server!.forEach(_handleRequest);

    final addr = await _detectLocalAddress();
    if (addr == null) {
      await _cleanup();
      throw Exception('No local network interface found.');
    }
    return HostedRoomInfo(host: addr, port: _server!.port);
  }

  /// Join a room by connecting to host:port
  Future<void> joinRoom({required String host, required int port}) async {
    await _cleanup();
    _socket = await WebSocket.connect('ws://$host:$port');
    _bindSocket(_socket!, 'host_disconnected');
  }

  Future<void> send(Map<String, dynamic> payload) async {
    final sock = _socket;
    if (sock == null || sock.readyState != WebSocket.open) {
      throw StateError('No active connection');
    }
    sock.add(jsonEncode(payload));
  }

  Future<void> reset() async => _cleanup();

  Future<void> dispose() async {
    await _cleanup();
    await _events.close();
  }

  Future<void> _handleRequest(HttpRequest req) async {
    if (!WebSocketTransformer.isUpgradeRequest(req)) {
      req.response.statusCode = HttpStatus.forbidden;
      await req.response.close();
      return;
    }
    if (_socket != null) {
      req.response.statusCode = HttpStatus.serviceUnavailable;
      await req.response.close();
      _events.add({'type': 'room_full'});
      return;
    }
    final ws = await WebSocketTransformer.upgrade(req);
    _socket = ws;
    _events.add({'type': 'peer_connected'});
    _bindSocket(ws, 'peer_disconnected');
  }

  void _bindSocket(WebSocket ws, String disconnectEvent) {
    ws.listen(
      (raw) {
        if (raw is! String) return;
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            _events.add(decoded);
          }
        } catch (_) {}
      },
      onError: (e) => _events.add({'type': 'transport_error', 'message': '$e'}),
      onDone: () {
        if (identical(_socket, ws)) {
          _socket = null;
          _events.add({'type': disconnectEvent});
        }
      },
      cancelOnError: true,
    );
  }

  Future<void> _cleanup() async {
    await _socket?.close();
    _socket = null;
    await _server?.close(force: true);
    _server = null;
  }

  Future<String?> _detectLocalAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return null;
  }
}