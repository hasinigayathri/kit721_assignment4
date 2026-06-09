import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'room.dart';
import 'window_space.dart';
import 'floor_space.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WindowSpaceModel>(context, listen: false)
        .fetch(widget.room.id);
    Provider.of<FloorSpaceModel>(context, listen: false)
        .fetch(widget.room.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
      ),
      body: Column(
        children: [
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
                                      fontSize: 16)),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('+ Add'),
                              ),
                            ],
                          ),
                          windowModel.items.isEmpty
                              ? const Padding(
                            padding:
                            EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                                child: Text('No windows added',
                                    style: TextStyle(
                                        color: Colors.grey))),
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.edit_outlined),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () {},
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
                                      fontSize: 16)),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('+ Add'),
                              ),
                            ],
                          ),
                          floorModel.items.isEmpty
                              ? const Padding(
                            padding:
                            EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                                child: Text('No floor spaces added',
                                    style: TextStyle(
                                        color: Colors.grey))),
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.edit_outlined),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () {},
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