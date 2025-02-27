import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ble_manager/ble_manager.dart';
import 'device_screen.dart';

final BleManager bleManager = BleManager();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<BleScanResult> _scanResults = [];
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _scanSubscription = bleManager.scanResults.listen((results) {
      setState(() {
        _scanResults.clear();
        _scanResults.addAll(results);
      });
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    bleManager.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    await bleManager.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Scanner")),
      body: ListView.builder(
        itemCount: _scanResults.length,
        itemBuilder: (context, index) {
          final device = _scanResults[index];
          return ListTile(
            title: Text(device.deviceName),
            subtitle: Text(device.deviceId),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceScreen(deviceId: device.deviceId),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        child: const Icon(Icons.search),
      ),
    );
  }
}
