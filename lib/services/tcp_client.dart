import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class TcpClient {
  late Socket _socket;
  late Stream<String> _lines;

  final _lineTransformer =
  StreamTransformer<Uint8List, String>.fromBind((stream) =>
      stream.map((bytes) => utf8.decode(bytes)).transform(const LineSplitter()));

  Future<void> connect(String host, int port, String mac) async {
    _socket = await Socket.connect(host, port);

    // Create a reusable line stream from the socket
    _lines = _socket.transform(_lineTransformer).asBroadcastStream();

    // Read and discard the welcome message
    await _lines.first;

    _socket.write('CONNECT $mac\n');
    await _socket.flush();

    final response = await _lines.first;
    if (!response.contains("CONNECTED")) {
      throw Exception("Connection failed: $response");
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    _socket.write(jsonEncode({"command": "get_info"}) + "\n");
    await _socket.flush();

    final jsonString = await _lines.first;
    return jsonDecode(jsonString);
  }

  void sendCommand(Map<String, dynamic> command) {
    _socket.write(jsonEncode(command) + "\n");
    _socket.flush();
  }

  Stream<String> get responses => _lines;

  void close() {
    _socket.destroy();
  }
}
