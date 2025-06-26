import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/tcp_client.dart';
import '../providers/device_provider.dart';
import '../models/device.dart';
import '../models/room.dart';
import 'widgets/device_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device> devices = [];
  List<Room> rooms = [];
  bool loading = true;
  late TcpClient tcp;

  @override
  void initState() {
    super.initState();
    tcp = TcpClient();
    initConnection();
  }

  Future<void> initConnection() async {
    try {
      final mac = "54:32:04:01:03:78"; //await ApiService.fetchMacAddress();
      if (mac == null) throw Exception("MAC fetch failed");

      await tcp.connect("server.digilux.co.in", 12345, mac);
      final json = await tcp.getDeviceInfo();

      setState(() {
        devices = (json['devices'] as List).map((d) => Device.fromJson(d)).toList();
        rooms = (json['rooms'] as List).map((r) => Room.fromJson(r)).toList();
        loading = false;
      });

      tcp.responses.listen((data) {
        final line = data.trim();
        print("Update from server: $line");
        // TODO: parse and update device state
        if (line.startsWith("{")) {
          final json = Map<String, dynamic>.from(jsonDecode(line));
          if (json.containsKey("id") && json.containsKey("status")) {
            // provider.updateStatus(json['id'], json['status'] == "on");
          }
        }
      });

    } catch (e) {
      setState(() => loading = false);
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    tcp.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text("Smart Control")),
      body: ListView(
        children: rooms.map((room) {
          final roomDevices = devices.where((d) => d.roomId == room.id).toList();
          return ExpansionTile(
            title: Text(room.name),
            children: roomDevices.map((device) => DeviceWidget(
              device: device,
              onSend: (cmd) => tcp.sendCommand(cmd),
            )).toList(),
          );
        }).toList(),
      ),
    );
  }
}