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
}