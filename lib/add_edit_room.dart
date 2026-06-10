import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'room.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditRoomScreen extends StatefulWidget {
  final String houseId;
  final Room? room;

  const AddEditRoomScreen({super.key, required this.houseId, this.room});

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {

  bool get _isEdit => widget.room != null;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.room!.name;
      _typeController.text = widget.room!.roomType ?? '';
      _photoPath = widget.room!.photoPath;
    }
  }

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
      photoPath: _photoPath,
    );

    if (_isEdit) {
      room.id = widget.room!.id;
      Provider.of<RoomModel>(context, listen: false)
          .updateItem(room.id, room);
    } else {
      Provider.of<RoomModel>(context, listen: false).add(room);
    }

    Navigator.pop(context);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
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
        title: Text(_isEdit ? 'Edit Room' : 'Add Room'),
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

            const SizedBox(height: 16),

// Room Photo section
            const Text('Room Photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickPhoto,
              child: _photoPath != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_photoPath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Add Room Photo'),
                ),
              ),
            ),

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