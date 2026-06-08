class Room {
  late String id;
  String houseId;
  String name;
  String? roomType;
  String? photoPath;

  Room({required this.houseId, required this.name, this.roomType, this.photoPath});
}