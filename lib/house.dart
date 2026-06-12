import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  late String id;
  String customerName;
  String address;
  String suburb;
  String? phone;


  House({required this.customerName, required this.address, required this.suburb, this.phone});

  House.fromJson(Map<String, dynamic> json, this.id)
      : customerName = json['customerName'],
        address = json['address'],
        suburb = json['suburb'] ?? '',
        phone = json['phone'];



  Map<String, dynamic> toJson() => {
    'customerName': customerName,
    'address': address,
    'suburb': suburb,
    'phone': phone,
  };

}
class HouseModel extends ChangeNotifier {
  final List<House> items = [];
  CollectionReference housesCollection =
  FirebaseFirestore.instance.collection('houses');
  bool loading = false;

  HouseModel() {
    fetch();
  }

  Future fetch() async {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot =
    await housesCollection.orderBy('customerName').get();

    for (var doc in querySnapshot.docs) {
      var house = House.fromJson(
          doc.data()! as Map<String, dynamic>, doc.id);
      items.add(house);
    }

    loading = false;
    notifyListeners();
  }

  Future add(House item) async {
    loading = true;
    notifyListeners();
    await housesCollection.add(item.toJson());
    await fetch();
  }

  Future updateItem(String id, House item) async {
    loading = true;
    notifyListeners();
    await housesCollection.doc(id).set(item.toJson());
    await fetch();
  }

  Future delete(String id) async {
    loading = true;
    notifyListeners();

    final db = FirebaseFirestore.instance;

    // Delete all windows and floors for each room
    final rooms = await db.collection('rooms')
        .where('houseId', isEqualTo: id).get();
    for (var roomDoc in rooms.docs) {
      final windows = await db.collection('windows')
          .where('roomId', isEqualTo: roomDoc.id).get();
      for (var doc in windows.docs) {
        await doc.reference.delete();
      }
      final floors = await db.collection('floors')
          .where('roomId', isEqualTo: roomDoc.id).get();
      for (var doc in floors.docs) {
        await doc.reference.delete();
      }
      await roomDoc.reference.delete();
    }

    // Delete the house itself
    await housesCollection.doc(id).delete();
    await fetch();
  }
}