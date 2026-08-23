import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'package:Swift/core/utils/token_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();
  WebSocketChannel? _channel;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _channel != null;

  Future<bool> connect() async {
    final token = await TokenStorage.readToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan');
    }
    final uri = Uri.parse(
      'wss://linking-backgrounds-processor-situation.trycloudflare.com'
      '/api/v1/ws/navigation?token=$token',
    );
    try {
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      _channel = channel;
      print('Navigation WS CONNECTED');

      _channel!.stream.listen(
        (raw) {
          print('NAV MESSAGE: $raw');
          try {
            final decoded = jsonDecode(raw) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (e) {
            print('Gagal parse pesan nav: $e');
          }
        },
        onError: (error) {
          print('Navigation WS ERROR: $error');
        },
        onDone: () {
          print('Navigation WS CLOSED');
          _channel = null;
        },
      );

      return true;
    } catch (e) {
      _channel = null;
      return false;
    }
  }
  
  void startNavigation({required int routeId, int legIndex = 0}) {
    if (_channel == null) {
      print('Navigation WS belum terhubung');
      return;
    }

    _channel!.sink.add(
      jsonEncode({
        'type': 'start_navigation',
        'route_id': routeId,
        'leg_index': legIndex,
      }),
    );
    developer.log('START_NAVIGATION sent: route_id=$routeId, leg_index=$legIndex', name: 'NavService');
  }

  void sendLocationUpdate({
    required double lat,
    required double lng,
    required double bearing,
    required double speed,
    required int currentRouteId,
  }) {
    if (_channel == null) {
      print('Navigation WS belum terhubung');
      return;
    }
    final data = {
      'type': 'location_update',
      'lat': lat,
      'lng': lng,
      'bearing': bearing,
      'speed': speed,
      'current_route_id': currentRouteId,
    };
    _channel!.sink.add(jsonEncode(data));
    print('LOCATION_UPDATE SENT: $data');
  }

  void ping(){
    if (_channel == null) {
      print ('Navigation WS belum terhubung');
      return;
    }
    _channel!.sink.add(jsonEncode({'type' : 'ping'}));
  }
  void disconnect(){
    _channel?.sink.close();
    _channel=null;
  }
}
