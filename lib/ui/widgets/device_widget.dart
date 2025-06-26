import 'package:flutter/material.dart';
import '../../models/device.dart';

typedef CommandSender = void Function(Map<String, dynamic> command);

class DeviceWidget extends StatelessWidget {
  final Device device;
  final CommandSender onSend;

  const DeviceWidget({super.key, required this.device, required this.onSend});

  @override
  Widget build(BuildContext context) {
    switch (device.type.toLowerCase()) {
      case 'light':
      case 'switch':
        return _SwitchDevice(device: device, onSend: onSend);
      case 'fan':
        return _FanDevice(device: device, onSend: onSend);
      case 'blind':
        return _BlindDevice(device: device, onSend: onSend);
      case 'door':
        return _DoorDevice(device: device, onSend: onSend);
      default:
        return ListTile(title: Text('${device.name} (Unknown type: ${device.type})'));
    }
  }
}

class _SwitchDevice extends StatefulWidget {
  final Device device;
  final CommandSender onSend;

  const _SwitchDevice({required this.device, required this.onSend});

  @override
  State<_SwitchDevice> createState() => _SwitchDeviceState();
}

class _SwitchDeviceState extends State<_SwitchDevice> {
  bool state = false;

  void toggleSwitch(bool value) {
    widget.onSend({
      "command": "toggle",
      "id": widget.device.id,
      "state": value ? "on" : "off"
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.device.name),
      value: widget.device.status,
      onChanged: toggleSwitch,
    );
  }
}

class _FanDevice extends StatefulWidget {
  final Device device;
  final CommandSender onSend;

  const _FanDevice({required this.device, required this.onSend});

  @override
  State<_FanDevice> createState() => _FanDeviceState();
}

class _FanDeviceState extends State<_FanDevice> {
  double speed = 0.0;

  void onChanged(double value) {
    setState(() => speed = value);
    widget.onSend({
      "command": "set_speed",
      "id": widget.device.id,
      "speed": speed.toInt()
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.device.name),
      subtitle: Slider(
        value: speed,
        min: 0,
        max: 5,
        divisions: 5,
        label: 'Speed ${speed.toInt()}',
        onChanged: onChanged,
      ),
    );
  }
}

class _BlindDevice extends StatefulWidget {
  final Device device;
  final CommandSender onSend;

  const _BlindDevice({required this.device, required this.onSend});

  @override
  State<_BlindDevice> createState() => _BlindDeviceState();
}

class _BlindDeviceState extends State<_BlindDevice> {
  double position = 0.0;

  void onChanged(double value) {
    setState(() => position = value);
    widget.onSend({
      "command": "set_position",
      "id": widget.device.id,
      "position": position
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.device.name),
      subtitle: Slider(
        value: position,
        min: 0,
        max: 100,
        divisions: 10,
        label: '${position.toInt()}%',
        onChanged: onChanged,
      ),
    );
  }
}

class _DoorDevice extends StatefulWidget {
  final Device device;
  final CommandSender onSend;

  const _DoorDevice({required this.device, required this.onSend});

  @override
  State<_DoorDevice> createState() => _DoorDeviceState();
}

class _DoorDeviceState extends State<_DoorDevice> {
  bool open = false;

  void toggle(bool value) {
    setState(() => open = value);
    widget.onSend({
      "command": "set_door",
      "id": widget.device.id,
      "state": open ? "open" : "close"
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.device.name),
      value: open,
      onChanged: toggle,
    );
  }
}
