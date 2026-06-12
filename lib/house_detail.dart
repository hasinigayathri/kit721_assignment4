import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'house.dart';
import 'room.dart';
import 'add_edit_room.dart';
import 'room_detail.dart';
import 'quote_screen.dart';

class HouseDetailScreen extends StatefulWidget {
  final House house;

  const HouseDetailScreen({super.key, required this.house});

  @override
  State<HouseDetailScreen> createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends State<HouseDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<RoomModel>(context, listen: false)
            .fetch(widget.house.id));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomModel>(
      builder: buildScaffold,
    );
  }

  Scaffold buildScaffold(BuildContext context, RoomModel roomModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.house.customerName),
      ),
      body: Column(
        children: [
          // House info
          Container(
            width: double.infinity,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.house.customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${widget.house.address}, ${widget.house.suburb}'),
              ],
            ),
          ),

          // Rooms header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rooms',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AddEditRoomScreen(
                          houseId: widget.house.id),
                    ));
                  },
                  child: const Text('+ Add Room'),
                ),
              ],
            ),
          ),
          if (roomModel.items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                '💡 Long press any room to duplicate it',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),

          // Room list or empty state
          Expanded(
            child: roomModel.loading
                ? const Center(child: CircularProgressIndicator())
                : roomModel.items.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/empty_room.jpeg',
                    height: 100,
                    color: Colors.white,
                    colorBlendMode: BlendMode.multiply,
                  ),
                  const SizedBox(height: 16),
                  const Text('No rooms added yet',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text(
                      "Tap '+ Add Room' to add your first room",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: roomModel.items.length,
              itemBuilder: (context, index) {
                var room = roomModel.items[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          RoomDetailScreen(room: room, house: widget.house),
                    ));
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Duplicate Room'),
                        content: Text("A copy of '${room.name}' will be created with all its windows and floor spaces."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Provider.of<RoomModel>(context, listen: false)
                                  .duplicate(room, widget.house.id);
                            },
                            child: const Text('Duplicate'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: room.name.contains('(Copy)') ? const Color(0xFFE0F2F1) : null,
                    child: ListTile(
                      title: Text(
                        room.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: room.name.contains('(Copy)') ? Colors.teal : null,
                        ),
                      ),
                      subtitle: Text(room.roomType ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddEditRoomScreen(
                                          houseId: widget.house.id,
                                          room: room,
                                        ),
                                  ));
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text(
                                      'Delete Room'),
                                  content: Text(
                                      'Are you sure you want to delete "${room.name}"? This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(
                                              context),
                                      child: const Text(
                                          'Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Provider.of<RoomModel>(
                                            context,
                                            listen: false)
                                            .delete(room.id,
                                            widget.house.id);
                                      },
                                      style:
                                      TextButton.styleFrom(
                                          foregroundColor:
                                          Colors.red),
                                      child: const Text(
                                          'Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Generate Quote button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: roomModel.items.isEmpty ? null : () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => QuoteScreen(house: widget.house),
                  ));
                },
                child: const Text('Generate Quote'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}