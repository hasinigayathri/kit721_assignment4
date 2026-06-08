import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  late String id;
  String customerName;
  String address;

  House({required this.customerName, required this.address});

  House.fromJson(Map<String, dynamic> json, this.id)
      : customerName = json['customerName'],
        address = json['address'];

  Map<String, dynamic> toJson() => {
    'customerName': customerName,
    'address': address,
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
}