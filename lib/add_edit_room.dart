import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'room.dart';

class AddEditRoomScreen extends StatefulWidget {
  final String houseId;

  const AddEditRoomScreen({super.key, required this.houseId});

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  bool _nameError = false;

  void _save() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
    });

    if (_nameError) return;

    var room = Room(
      houseId: widget.houseId,
      name: _nameController.text.trim(),
      roomType: _typeController.text.trim().isNotEmpty
          ? _typeController.text.trim()
          : null,
    );

    Provider.of<RoomModel>(context, listen: false).add(room);
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
        title: const Text('Add Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Details section
            const Text('Room Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            // Room Name
            const Text('Room Name *'),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter Room Name...',
                border: const OutlineInputBorder(),
                errorText: _nameError ? 'Room name is required' : null,
              ),
              onChanged: (_) => setState(() => _nameError = false),
            ),
            const SizedBox(height: 16),

            // Room Type
            const Text('Room Type (Optional)'),
            const SizedBox(height: 4),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                hintText: 'e.g. Bedroom, Lounge',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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