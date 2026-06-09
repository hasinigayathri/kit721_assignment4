import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'house.dart';

class AddEditHouseScreen extends StatefulWidget {
  const AddEditHouseScreen({super.key});

  @override
  State<AddEditHouseScreen> createState() => _AddEditHouseScreenState();
}

class _AddEditHouseScreenState extends State<AddEditHouseScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _suburbController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _nameError = false;
  bool _addressError = false;
  bool _suburbError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _suburbController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _addressError = _addressController.text.trim().isEmpty;
      _suburbError = _suburbController.text.trim().isEmpty;
    });

    if (_nameError || _addressError || _suburbError) return;

    var house = House(
      customerName: _nameController.text.trim(),
      address: '${_addressController.text.trim()}, ${_suburbController.text.trim()}',
    );

    Provider.of<HouseModel>(context, listen: false).add(house);
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
              style: TextStyle(color: Colors.blue)),
        ),
        title: const Text('Add House'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Details section
            const Text('Customer Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Name : *'),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter Customer Name...',
                border: const OutlineInputBorder(),
                errorText: _nameError ? 'Name is required' : null,
              ),
              onChanged: (_) => setState(() => _nameError = false),
            ),
            const SizedBox(height: 16),

            // Location section
            const Text('Location',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Address : *'),
            const SizedBox(height: 4),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter Address',
                border: const OutlineInputBorder(),
                errorText: _addressError ? 'Address is required' : null,
              ),
              onChanged: (_) => setState(() => _addressError = false),
            ),
            const SizedBox(height: 12),
            const Text('Suburb : *'),
            const SizedBox(height: 4),
            TextField(
              controller: _suburbController,
              decoration: InputDecoration(
                hintText: 'Search Suburb',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.search),
                errorText: _suburbError ? 'Suburb is required' : null,
              ),
              onChanged: (_) => setState(() => _suburbError = false),
            ),
            const SizedBox(height: 16),

            // Contact section
            const Text('Contact (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Phone:'),
            const SizedBox(height: 4),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '04XXXXXXXX',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                  onPressed: _save,
                child: const Text('Save & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}