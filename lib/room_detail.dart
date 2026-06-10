import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'room.dart';
import 'window_space.dart';
import 'floor_space.dart';
import 'add_edit_window.dart';
import 'dart:io';
import 'add_edit_floor.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WindowSpaceModel()),
        ChangeNotifierProvider(create: (_) => FloorSpaceModel()),
      ],
      child: _RoomDetailContent(room: widget.room),
    );
  }
}

class _RoomDetailContent extends StatefulWidget {
  final Room room;

  const _RoomDetailContent({required this.room});

  @override
  State<_RoomDetailContent> createState() => _RoomDetailContentState();
}

class _RoomDetailContentState extends State<_RoomDetailContent> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<WindowSpaceModel>(context, listen: false)
          .fetch(widget.room.id);
      Provider.of<FloorSpaceModel>(context, listen: false)
          .fetch(widget.room.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
      ),
      body: Column(
        children: [
          // Room photo
          if (widget.room.photoPath != null)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.file(
                File(widget.room.photoPath!),
                fit: BoxFit.cover,
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Windows section
                  Consumer<WindowSpaceModel>(
                    builder: (context, windowModel, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Windows [${windowModel.items.length}]',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final windowModel = Provider.of<WindowSpaceModel>(context, listen: false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditWindowScreen(
                                        roomId: widget.room.id,
                                        onSave: (window) {
                                          windowModel.add(window);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('+ Add'),
                              ),
                            ],
                          ),
                          windowModel.items.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12),
                            child: Center(
                              child: Text('No windows added',
                                  style: TextStyle(
                                      color: Colors.grey)),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: windowModel.items.length,
                            itemBuilder: (context, index) {
                              var window =
                              windowModel.items[index];
                              return Card(
                                child: ListTile(
                                  title: Text(window.name),
                                  subtitle: Text(
                                      '${window.width.toInt()}mm x ${window.height.toInt()}mm'),
                                  trailing: Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.edit_outlined),
                                        onPressed: () {
                                          final windowModel = Provider.of<WindowSpaceModel>(context, listen: false);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddEditWindowScreen(
                                                roomId: widget.room.id,
                                                window: window,
                                                onSave: (updatedWindow) {
                                                  windowModel.updateItem(updatedWindow.id, updatedWindow);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Delete Window'),
                                              content: Text('Delete "${window.name}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Provider.of<WindowSpaceModel>(context, listen: false)
                                                        .delete(window.id);
                                                  },
                                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Floor Spaces section
                  Consumer<FloorSpaceModel>(
                    builder: (context, floorModel, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Floor Spaces [${floorModel.items.length}]',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final floorModel = Provider.of<FloorSpaceModel>(context, listen: false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditFloorScreen(
                                        roomId: widget.room.id,
                                        onSave: (floor) {
                                          floorModel.add(floor);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('+ Add'),
                              ),
                            ],
                          ),
                          floorModel.items.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12),
                            child: Center(
                              child: Text('No floor spaces added',
                                  style: TextStyle(
                                      color: Colors.grey)),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: floorModel.items.length,
                            itemBuilder: (context, index) {
                              var floor = floorModel.items[index];
                              return Card(
                                child: ListTile(
                                  title: Text(floor.name),
                                  subtitle: Text(
                                      '${floor.width.toInt()}mm x ${floor.depth.toInt()}mm'),
                                  trailing: Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.edit_outlined),
                                        onPressed: () {
                                          final floorModel = Provider.of<FloorSpaceModel>(context, listen: false);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddEditFloorScreen(
                                                roomId: widget.room.id,
                                                floor: floor,
                                                onSave: (updatedFloor) {
                                                  floorModel.updateItem(updatedFloor.id, updatedFloor);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Delete Floor Space'),
                                              content: Text('Delete "${floor.name}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Provider.of<FloorSpaceModel>(context, listen: false)
                                                        .delete(floor.id);
                                                  },
                                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Generate Quote button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Generate Quote'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}