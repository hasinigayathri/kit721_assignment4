import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'house.dart';
import 'add_edit_house.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HouseModel(),
      child: MaterialApp(
        title: 'Interior Quoter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true,
        ),
        home: const HouseListScreen(),
      ),
    );
  }
}

class HouseListScreen extends StatefulWidget {
  const HouseListScreen({super.key});

  @override
  State<HouseListScreen> createState() => _HouseListScreenState();
}

class _HouseListScreenState extends State<HouseListScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HouseModel>(
      builder: buildScaffold,
    );
  }

  Scaffold buildScaffold(BuildContext context, HouseModel houseModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interior Quoter'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const AddEditHouseScreen(),
          ));
        },
      ),
      body: houseModel.loading
          ? const Center(child: CircularProgressIndicator())
          : houseModel.items.isEmpty
          ? const Center(child: Text('No projects yet'))
          : ListView.builder(
        itemCount: houseModel.items.length,
        itemBuilder: (context, index) {
          var house = houseModel.items[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(house.customerName),
              subtitle: Text(house.address),
            ),
          );
        },
      ),
    );
  }
}