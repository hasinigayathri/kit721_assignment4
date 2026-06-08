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
}