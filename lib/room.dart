import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
class RoomModel extends ChangeNotifier {
  final List<Room> items = [];
  CollectionReference roomsCollection =
  FirebaseFirestore.instance.collection('rooms');
  bool loading = false;

  RoomModel();

  Future fetch(String houseId) async {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await roomsCollection
        .where('houseId', isEqualTo: houseId)
        .get();

    for (var doc in querySnapshot.docs) {
      var room = Room.fromJson(
          doc.data()! as Map<String, dynamic>, doc.id);
      items.add(room);
    }

    loading = false;
    notifyListeners();
  }
}