class Device {
  final String name;
  final String type;
  final int id;
  final int roomId;
  bool status;

  Device({required this.name, required this.type, required this.id, required this.roomId, this.status = false});

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    name: json['name'],
    type: json['type'],
    id: json['id'],
    roomId: json['room_id'],
    status: json['status'] == 'on',
  );

  Device copyWith({bool? status}) {
    return Device(
      id: id,
      name: name,
      type: type,
      roomId: roomId,
      status: status ?? this.status,
    );
  }
}

