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