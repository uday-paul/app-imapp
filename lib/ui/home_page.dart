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

      await tcp.connect("digilux.local", 12345, mac);
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
            final int id = json['id'];
            final bool newStatus = json['status'] == "on";

            setState(() {
              devices = List<Device>.from(devices.map((d) {
                if (d.id == id) {
                  return d.copyWith(status: newStatus);
                } else {
                  return d;
                }
              }));
            });
          }
          // Case 2: Full/partial device + room update (without explicit command)
          if (json.containsKey("devices") || json.containsKey("rooms")) {
            final newDevices = (json["devices"] as List?)?.map((d) => Device.fromJson(d)).toList() ?? [];
            final newRooms = (json["rooms"] as List?)?.map((r) => Room.fromJson(r)).toList() ?? [];

            setState(() {
              for (final dev in newDevices) {
                final index = devices.indexWhere((d) => d.id == dev.id);
                if (index == -1) {
                  devices.add(dev);
                } else {
                  devices[index] = dev;
                }
              }

              for (final room in newRooms) {
                final index = rooms.indexWhere((r) => r.id == room.id);
                if (index == -1) {
                  rooms.add(room);
                } else {
                  rooms[index] = room;
                }
              }
            });
          }
        }
      });

    } catch (e) {
      setState(() => loading = false);
      print("Error: $e");
    }
  }

  void sendCommand(Map<String, dynamic> cmd) {
    tcp.sendCommand(cmd);

    // Optional optimistic UI update
    if (cmd.containsKey("id") && cmd.containsKey("action")) {
      final int id = cmd["id"];
      final bool newStatus = cmd["action"] == "on";
      setState(() {
        final index = devices.indexWhere((d) => d.id == id);
        if (index != -1) {
          devices[index] = devices[index].copyWith(status: newStatus);
        }
      });
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
              onSend: (cmd) => sendCommand(cmd),//tcp.sendCommand(cmd),
            )).toList(),
          );
        }).toList(),
      ),
    );
  }
}