import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/utils/token_storage.dart';

class TrackingService {
  TrackingService._();
  static final TrackingService instance = TrackingService._();

  WebSocketChannel? _channel;

  Future<bool> connect() async {
  final token = await TokenStorage.readToken();
  if (token == null || token.isEmpty) {
    throw Exception('Token tidak ditemukan');
  }
  final uri = Uri.parse(
    'wss://minolta-chan-database-puzzles.trycloudflare.com'
    '/api/v1/ws/driver/position?token=$token',
  );
  print('Connecting WebSocket...');
  try {
    final channel = WebSocketChannel.connect(uri);
    await channel.ready;
    _channel = channel;
    print('WebSocket CONNECTED'); 
    _channel!.stream.listen(
      (message) {
        print('WS MESSAGE: $message');
      },
      onError: (error) {
        print('WS ERROR: $error');
      },
      onDone: () {
        print('WS CLOSED');
        _channel = null;
      },
    );
    ping();
    return true;
  } catch (e) {
    _channel = null;
    return false;
  }
}

  void sendPosition({
    required double lat,
    required double lon,
    double? bearing,
    double? speed,
  }) {
    if (_channel == null) {
      print('WebSocket belum terhubung');
      return;
    }

    final data = {
      'type': 'position',
      'lat': lat,
      'lon': lon,
      'bearing': bearing,
      'speed': speed,
    };

    _channel!.sink.add(jsonEncode(data));

    print('POSITION SENT: $data');
  }

  void ping() {
    if (_channel == null) {
      print('WebSocket belum terhubung');
      return;
    }

    _channel!.sink.add(
      jsonEncode({
        'type': 'ping',
      }),
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;

    print('WebSocket disconnected');
  }
}