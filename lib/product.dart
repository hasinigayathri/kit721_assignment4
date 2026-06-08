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
}