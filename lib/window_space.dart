class WindowSpace {
  late String id;
  String roomId;
  String name;
  double width;
  double height;
  String? productId;
  String? productName;
  String? colourVariant;
  double? pricePerSqm;

  WindowSpace({
    required this.roomId,
    required this.name,
    required this.width,
    required this.height,
    this.productId,
    this.productName,
    this.colourVariant,
    this.pricePerSqm,
  });

  WindowSpace.fromJson(Map<String, dynamic> json, this.id)
      : roomId = json['roomId'],
        name = json['name'],
        width = (json['width'] ?? 0).toDouble(),
        height = (json['height'] ?? 0).toDouble(),
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
    'height': height,
    'productId': productId,
    'productName': productName,
    'colourVariant': colourVariant,
    'pricePerSqm': pricePerSqm,
  };
}