import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/room.dart';

class DeviceProvider extends ChangeNotifier {
  final List<Device> _devices = [];
  final List<Room> _rooms = [];

  List<Device> get devices => _devices;
  List<Room> get rooms => _rooms;

  void setFromJson(Map<String, dynamic> json) {
    _devices.clear();
    _rooms.clear();

    for (var d in json['devices']) {
      _devices.add(Device.fromJson(d));
    }
    for (var r in json['rooms']) {
      _rooms.add(Room.fromJson(r));
    }
    notifyListeners();
  }

  void updateStatus(int id, bool isOn) {
    final device = _devices.firstWhere((d) => d.id == id, orElse: () => Device(id: id, name: "Unknown", type: "unknown", roomId: 0));
    device.status = isOn;
    notifyListeners();
  }
}