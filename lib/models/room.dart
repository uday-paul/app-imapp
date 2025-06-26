class Room {
  final String name;
  final int id;

  Room({required this.name, required this.id});

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    name: json['name'],
    id: json['id'],
  );
}