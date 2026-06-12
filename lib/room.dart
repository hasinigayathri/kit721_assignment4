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

  Future add(Room item) async {
    loading = true;
    notifyListeners();
    await roomsCollection.add(item.toJson());
    await fetch(item.houseId);
  }

  Future updateItem(String id, Room item) async {
    loading = true;
    notifyListeners();
    await roomsCollection.doc(id).set(item.toJson());
    await fetch(item.houseId);
  }

  Future delete(String id, String houseId) async {
    loading = true;
    notifyListeners();

    final db = FirebaseFirestore.instance;

    // Delete all windows for this room
    final windows = await db.collection('windows')
        .where('roomId', isEqualTo: id).get();
    for (var doc in windows.docs) {
      await doc.reference.delete();
    }

    // Delete all floors for this room
    final floors = await db.collection('floors')
        .where('roomId', isEqualTo: id).get();
    for (var doc in floors.docs) {
      await doc.reference.delete();
    }

    // Delete the room itself
    await roomsCollection.doc(id).delete();
    await fetch(houseId);
  }

  Future duplicate(Room room, String houseId) async {
    loading = true;
    notifyListeners();

    final db = FirebaseFirestore.instance;

    // Create new room
    final newRoom = Room(
      houseId: houseId,
      name: '${room.name} (Copy)',
      roomType: room.roomType,
      photoPath: room.photoPath,
    );
    final newRoomDoc = await roomsCollection.add(newRoom.toJson());

    // Copy windows
    final windows = await db.collection('windows')
        .where('roomId', isEqualTo: room.id).get();
    for (var doc in windows.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      data['roomId'] = newRoomDoc.id;
      await db.collection('windows').add(data);
    }

    // Copy floors
    final floors = await db.collection('floors')
        .where('roomId', isEqualTo: room.id).get();
    for (var doc in floors.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      data['roomId'] = newRoomDoc.id;
      await db.collection('floors').add(data);
    }

    await fetch(houseId);
  }
}