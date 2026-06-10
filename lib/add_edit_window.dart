import 'package:flutter/material.dart';
import 'product.dart';

class AddEditWindowScreen extends StatefulWidget {
  final String roomId;

  const AddEditWindowScreen({super.key, required this.roomId});

  @override
  State<AddEditWindowScreen> createState() => _AddEditWindowScreenState();
}

class _AddEditWindowScreenState extends State<AddEditWindowScreen> {

  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  List<Product> _products = [];
  Product? _selectedProduct;
  String? _selectedVariant;
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.fetchByCategory('window');
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
      print('Loaded ${_products.length} products');
    } catch (e) {
      print('Error loading products: $e');
      setState(() => _isLoadingProducts = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Colors.white)),
        ),
        title: const Text('Add Window'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Window Name
            const Text('Window Name *'),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter Window Name...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Width and Height row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Width (mm) *'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _widthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '1200',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Height (mm) *'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '1500',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 16),

            // Product section
            const Text('Product',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            _isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Product>(
              value: _selectedProduct,
              hint: const Text('Select a product (optional)'),
              decoration: const InputDecoration(
                  border: OutlineInputBorder()),
              items: _products
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.name),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedProduct = val;
                  _selectedVariant = val?.colour_variants.isNotEmpty == true
                      ? val!.colour_variants.first
                      : null;
                });
              },
            ),
            // Product details
            if (_selectedProduct != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${_selectedProduct!.price_per_sqm.toStringAsFixed(1)}/m²'),
                      const SizedBox(height: 4),
                      Text('Description: ${_selectedProduct!.description}'),
                      if (_selectedProduct!.image_url != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            _selectedProduct!.image_url!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Colour variant dropdown
              const SizedBox(height: 12),
              if (_selectedProduct!.colour_variants.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedVariant,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder()),
                  items: _selectedProduct!.colour_variants
                      .map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedVariant = val),
                ),
            ],

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save Window'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}