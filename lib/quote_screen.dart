import 'package:flutter/material.dart';
import 'house.dart';
import 'room.dart';
import 'window_space.dart';
import 'floor_space.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';


class QuoteScreen extends StatefulWidget {
  final House house;

  const QuoteScreen({super.key, required this.house});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  List<Room> _rooms = [];
  Map<String, List<WindowSpace>> _windows = {};
  Map<String, List<FloorSpace>> _floors = {};
  Map<String, bool> _roomIncluded = {};
  bool _loading = true;

  static const double _labourCost = 200.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = FirebaseFirestore.instance;

    final roomsSnap = await db.collection('rooms')
        .where('houseId', isEqualTo: widget.house.id)
        .get();

    final rooms = roomsSnap.docs
        .map((d) => Room.fromJson(d.data(), d.id))
        .toList();

    final windows = <String, List<WindowSpace>>{};
    final floors = <String, List<FloorSpace>>{};
    final included = <String, bool>{};

    for (var room in rooms) {
      final wSnap = await db.collection('windows')
          .where('roomId', isEqualTo: room.id)
          .get();
      final fSnap = await db.collection('floors')
          .where('roomId', isEqualTo: room.id)
          .get();

      windows[room.id] = wSnap.docs
          .map((d) => WindowSpace.fromJson(d.data(), d.id))
          .toList();
      floors[room.id] = fSnap.docs
          .map((d) => FloorSpace.fromJson(d.data(), d.id))
          .toList();
      included[room.id] = true;
    }

    setState(() {
      _rooms = rooms;
      _windows = windows;
      _floors = floors;
      _roomIncluded = included;
      _loading = false;
    });
  }

  double _windowCost(WindowSpace w) {
    final price = w.pricePerSqm ?? 50.0;
    return (w.width / 1000) * (w.height / 1000) * price;
  }

  double _floorCost(FloorSpace f) {
    final price = f.pricePerSqm ?? 100.0;
    return (f.width / 1000) * (f.depth / 1000) * price;
  }

  double _roomTotal(String roomId) {
    final wCost = (_windows[roomId] ?? []).fold(0.0, (total, w) => total + _windowCost(w));
    final fCost = (_floors[roomId] ?? []).fold(0.0, (total, f) => total + _floorCost(f));
    final hasItems = (_windows[roomId]?.isNotEmpty ?? false) ||
        (_floors[roomId]?.isNotEmpty ?? false);
    return wCost + fCost + (hasItems ? _labourCost : 0);
  }

  double get _houseTotal {
    double total = 0;
    for (var room in _rooms) {
      if (_roomIncluded[room.id] == true) {
        total += _roomTotal(room.id);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCSV,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
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

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                final included = _roomIncluded[room.id] ?? true;
                final roomWindows = _windows[room.id] ?? [];
                final roomFloors = _floors[room.id] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: included,
                              activeColor: Colors.teal,
                              onChanged: (val) => setState(() =>
                              _roomIncluded[room.id] = val ?? true),
                            ),
                            Text(room.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const Spacer(),
                            Text(
                              '\$${_roomTotal(room.id).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                          ],
                        ),

                        if (included) ...[
                          const Divider(),
                          ...roomWindows.map((w) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(w.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${w.width.toInt()}mm × ${w.height.toInt()}mm'
                                            '${w.productName != null ? ' — ${w.productName}' : ''}'
                                            '${w.colourVariant != null ? ' (${w.colourVariant})' : ''}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text('\$${_windowCost(w).toStringAsFixed(2)}'),
                              ],
                            ),
                          )),

                          ...roomFloors.map((f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(f.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${f.width.toInt()}mm × ${f.depth.toInt()}mm'
                                            '${f.productName != null ? ' — ${f.productName}' : ''}'
                                            '${f.colourVariant != null ? ' (${f.colourVariant})' : ''}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text('\$${_floorCost(f).toStringAsFixed(2)}'),
                              ],
                            ),
                          )),

                          if (roomWindows.isEmpty && roomFloors.isEmpty)
                            const Text('No items in this room',
                                style: TextStyle(color: Colors.grey)),

                          if (roomWindows.isNotEmpty || roomFloors.isNotEmpty) ...[
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Labour',
                                    style: TextStyle(color: Colors.grey)),
                                Text('\$${_labourCost.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text('\$${_houseTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.teal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareCSV() async {
    final buffer = StringBuffer();

    buffer.writeln('House,Room,Item,Cost');

    for (var room in _rooms) {
      if (_roomIncluded[room.id] != true) continue;

      final roomWindows = _windows[room.id] ?? [];
      final roomFloors = _floors[room.id] ?? [];

      for (var w in roomWindows) {
        buffer.writeln('${widget.house.customerName},${room.name},${w.name} — ${w.productName ?? ''} (${w.colourVariant ?? ''}),\$${_windowCost(w).toStringAsFixed(2)}');
      }
      for (var f in roomFloors) {
        buffer.writeln('${widget.house.customerName},${room.name},${f.name} — ${f.productName ?? ''} (${f.colourVariant ?? ''}),\$${_floorCost(f).toStringAsFixed(2)}');
      }
      if (roomWindows.isNotEmpty || roomFloors.isNotEmpty) {
        buffer.writeln('${widget.house.customerName},${room.name},Room Total,\$${_roomTotal(room.id).toStringAsFixed(2)}');
      }
    }
    buffer.writeln('${widget.house.customerName},,,Grand Total,\$${_houseTotal.toStringAsFixed(2)}');

    await SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject: 'Quote for ${widget.house.customerName}',
      ),
    );
  }
}