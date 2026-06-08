class Product {
  final int id;
  final String name;
  final String description;
  final double price_per_sqm;
  final String? image_url;
  final String category;
  final List<String> colour_variants;
  final double? min_width;
  final double? max_width;
  final double? min_height;
  final double? max_height;
  final int? max_panels;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price_per_sqm,
    this.image_url,
    required this.category,
    required this.colour_variants,
    this.min_width,
    this.max_width,
    this.min_height,
    this.max_height,
    this.max_panels,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> variants = [];
    if (json['colour_variants'] != null) {
      variants = List<String>.from(json['colour_variants']);
    }
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price_per_sqm: (json['price_per_sqm'] ?? 0).toDouble(),
      image_url: json['image_url'],
      category: json['category'] ?? '',
      colour_variants: variants,
      min_width: json['min_width'] != null ? (json['min_width']).toDouble() : null,
      max_width: json['max_width'] != null ? (json['max_width']).toDouble() : null,
      min_height: json['min_height'] != null ? (json['min_height']).toDouble() : null,
      max_height: json['max_height'] != null ? (json['max_height']).toDouble() : null,
      max_panels: json['max_panels'],
    );
  }
}