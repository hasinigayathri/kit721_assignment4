import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FloorSpace {
  late String id;
  String roomId;
  String name;
  double width;
  double depth;
  String? productId;
  String? productName;
  String? colourVariant;
  double? pricePerSqm;

  FloorSpace({
    required this.roomId,
    required this.name,
    required this.width,
    required this.depth,
    this.productId,
    this.productName,
    this.colourVariant,
    this.pricePerSqm,
  });

  FloorSpace.fromJson(Map<String, dynamic> json, this.id)
      : roomId = json['roomId'],
        name = json['name'],
        width = (json['width'] ?? 0).toDouble(),
        depth = (json['depth'] ?? 0).toDouble(),
        productId = json['productId'],
        productName = json['productName'],
        colourVariant = json['colourVariant'],
        pricePerSqm = json['pricePerSqm'] != null
            ? (json['pricePerSqm']).toDouble()
            : null;

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'name': name,
    'width': width,
    'depth': depth,
    'productId': productId,
    'productName': productName,
    'colourVariant': colourVariant,
    'pricePerSqm': pricePerSqm,
  };
}

class FloorSpaceModel extends ChangeNotifier {
  final List<FloorSpace> items = [];
  CollectionReference floorsCollection =
  FirebaseFirestore.instance.collection('floors');
  bool loading = false;

  FloorSpaceModel();

  Future fetch(String roomId) async {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await floorsCollection
        .where('roomId', isEqualTo: roomId)
        .get();

    for (var doc in querySnapshot.docs) {
      var floor = FloorSpace.fromJson(
          doc.data()! as Map<String, dynamic>, doc.id);
      items.add(floor);
    }

    loading = false;
    notifyListeners();
  }

  Future add(FloorSpace item) async {
    loading = true;
    notifyListeners();
    var doc = await floorsCollection.add(item.toJson());
    item.id = doc.id;
    items.add(item);
    loading = false;
    notifyListeners();
  }

  Future updateItem(String id, FloorSpace item) async {
    loading = true;
    notifyListeners();
    await floorsCollection.doc(id).set(item.toJson());
    item.id = id;
    items[items.indexWhere((f) => f.id == id)] = item;
    loading = false;
    notifyListeners();
  }

  Future delete(String id) async {
    loading = true;
    notifyListeners();
    await floorsCollection.doc(id).delete();
    items.removeWhere((f) => f.id == id);
    loading = false;
    notifyListeners();
  }
}