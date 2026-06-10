import 'package:flutter/material.dart';
import 'product.dart';
import 'floor_space.dart';

class AddEditFloorScreen extends StatefulWidget {
  final String roomId;
  final FloorSpace? floor;
  final Function(FloorSpace)? onSave;

  const AddEditFloorScreen({
    super.key,
    required this.roomId,
    this.floor,
    this.onSave,
  });

  @override
  State<AddEditFloorScreen> createState() => _AddEditFloorScreenState();
}

class _AddEditFloorScreenState extends State<AddEditFloorScreen> {
  final _nameController = TextEditingController();
  final _widthController = TextEditingController();
  final _depthController = TextEditingController();

  List<Product> _products = [];
  Product? _selectedProduct;
  String? _selectedVariant;
  bool _isLoadingProducts = true;

  bool _nameError = false;
  bool _widthError = false;
  bool _depthError = false;

  bool get _isEdit => widget.floor != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (_isEdit) {
      _nameController.text = widget.floor!.name;
      _widthController.text = widget.floor!.width.toInt().toString();
      _depthController.text = widget.floor!.depth.toInt().toString();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.fetchByCategory('floor');
      setState(() {
        _products = products;
        _isLoadingProducts = false;
        if (_isEdit && widget.floor!.productId != null) {
          _selectedProduct = _products.firstWhere(
                (p) => p.id == widget.floor!.productId,
            orElse: () => _products.first,
          );
          _selectedVariant = widget.floor!.colourVariant;
        }
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _widthError = _widthController.text.trim().isEmpty;
      _depthError = _depthController.text.trim().isEmpty;
    });

    if (_nameError || _widthError || _depthError) return;

    final width = double.tryParse(_widthController.text);
    final depth = double.tryParse(_depthController.text);

    if (width == null || width <= 0) {
      setState(() => _widthError = true);
      return;
    }
    if (depth == null || depth <= 0) {
      setState(() => _depthError = true);
      return;
    }

    var floor = FloorSpace(
      roomId: widget.roomId,
      name: _nameController.text.trim(),
      width: width,
      depth: depth,
      productId: _selectedProduct?.id,
      productName: _selectedProduct?.name,
      colourVariant: _selectedVariant,
      pricePerSqm: _selectedProduct?.price_per_sqm,
    );

    if (_isEdit) floor.id = widget.floor!.id;

    if (widget.onSave != null) {
      widget.onSave!(floor);
    }
    Navigator.pop(context);
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
        title: Text(_isEdit ? 'Edit Floor Space' : 'Add Floor Space'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Floor Space Name *'),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter Floor Space Name...',
                border: const OutlineInputBorder(),
                errorText: _nameError ? 'Name is required' : null,
              ),
              onChanged: (_) => setState(() => _nameError = false),
            ),
            const SizedBox(height: 16),

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
                        decoration: InputDecoration(
                          hintText: '3000',
                          border: const OutlineInputBorder(),
                          errorText: _widthError ? 'Enter valid width' : null,
                        ),
                        onChanged: (_) => setState(() => _widthError = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Depth (mm) *'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _depthController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '4000',
                          border: const OutlineInputBorder(),
                          errorText: _depthError ? 'Enter valid depth' : null,
                        ),
                        onChanged: (_) => setState(() => _depthError = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                  _selectedVariant =
                  val?.colour_variants.isNotEmpty == true
                      ? val!.colour_variants.first
                      : null;
                });
              },
            ),

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

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Floor Space'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}