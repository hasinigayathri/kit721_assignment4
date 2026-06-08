class Room {
  late String id;
  String houseId;
  String name;
  String? roomType;
  String? photoPath;

  Room({required this.houseId, required this.name, this.roomType, this.photoPath});

  Room.fromJson(Map<String, dynamic> json, this.id)
      : houseId = json['houseId'],
        name = json['name'],
        roomType = json['roomType'],
        photoPath = json['photoPath'];

  Map<String, dynamic> toJson() => {
    'houseId': houseId,
    'name': name,
    'roomType': roomType,
    'photoPath': photoPath,
  };
}