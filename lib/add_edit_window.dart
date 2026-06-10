import 'package:flutter/material.dart';
import 'product.dart';
import 'package:provider/provider.dart';
import 'window_space.dart';

class AddEditWindowScreen extends StatefulWidget {
  final String roomId;
  final WindowSpace? window;
  final Function(WindowSpace)? onSave;

  const AddEditWindowScreen({super.key, required this.roomId, this.window, this.onSave});

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
  bool get _isEdit => widget.window != null;

  bool _nameError = false;
  bool _widthError = false;
  bool _heightError = false;
  String? _constraintMessage;
  bool _constraintValid = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (_isEdit) {
      _nameController.text = widget.window!.name;
      _widthController.text = widget.window!.width.toInt().toString();
      _heightController.text = widget.window!.height.toInt().toString();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.fetchByCategory('window');
      setState(() {
        _products = products;
        _isLoadingProducts = false;
        if (_isEdit && widget.window!.productId != null) {
          _selectedProduct = _products.firstWhere(
                (p) => p.id == widget.window!.productId,
            orElse: () => _products.first,
          );
          _selectedVariant = widget.window!.colourVariant;
        }
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() => _isLoadingProducts = false);
    }
  }

  void _checkConstraints() {
    if (_selectedProduct == null) return;
    final width = double.tryParse(_widthController.text);
    final height = double.tryParse(_heightController.text);
    if (width == null || height == null) return;

    final result = _selectedProduct!.checkWindowConstraints(width, height);
    setState(() {
      _constraintValid = result.valid;
      _constraintMessage = result.message;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _save() {
    print('constraintValid: $_constraintValid, message: $_constraintMessage');

    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _widthError = _widthController.text.trim().isEmpty;
      _heightError = _heightController.text.trim().isEmpty;
    });

    if (_nameError || _widthError || _heightError) return;

    final width = double.tryParse(_widthController.text);
    final height = double.tryParse(_heightController.text);

    if (width == null || width <= 0) {
      setState(() => _widthError = true);
      return;
    }
    if (height == null || height <= 0) {
      setState(() => _heightError = true);
      return;
    }
    if (_selectedProduct != null && !_constraintValid) {
      print('Blocked by constraint');
      return;
    }

    print('Saving window...');


    var window = WindowSpace(
      roomId: widget.roomId,
      name: _nameController.text.trim(),
      width: width,
      height: height,
      productId: _selectedProduct?.id,
      productName: _selectedProduct?.name,
      colourVariant: _selectedVariant,
      pricePerSqm: _selectedProduct?.price_per_sqm,
    );

    if (_isEdit) window.id = widget.window!.id;

    if (widget.onSave != null) {
      widget.onSave!(window);
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
        title: Text(_isEdit ? 'Edit Window' : 'Add Window'),
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
              decoration: InputDecoration(
                hintText: 'Enter Window Name...',
                border: const OutlineInputBorder(),
                errorText: _nameError ? 'Name is required' : null,
              ),
              onChanged: (_) => setState(() => _nameError = false),
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
                        decoration: InputDecoration(
                          hintText: '1200',
                          border: const OutlineInputBorder(),
                          errorText: _widthError ? 'Enter valid width' : null,
                        ),
                        onChanged: (_) {
                          setState(() => _widthError = false);
                          _checkConstraints();
                        },
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
                        decoration: InputDecoration(
                          hintText: '1500',
                          border: const OutlineInputBorder(),
                          errorText: _heightError ? 'Enter valid height' : null,
                        ),
                        onChanged: (_) {
                          setState(() => _heightError = false);
                          _checkConstraints();
                        },
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
                _checkConstraints();
              },
            ),
            if (_constraintMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _constraintMessage!,
                  style: TextStyle(
                    color: _constraintValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                onPressed: _save,
                child: const Text('Save Window'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
