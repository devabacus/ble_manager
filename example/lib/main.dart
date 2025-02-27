import 'dart:async';
import 'dart:developer';
// import 'package:ble_learn/device_screen.dart';
import 'package:example/device_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ble_manager/ble_manager.dart';

final BleManager bleManager = BleManager();

void main() {
  // FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

  // FlutterBluePlus.logs.listen((log) {
  //   debugPrint("FBP Log: $log");
  // });

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
    _requestPermissions();

    _scanSubscription = bleManager.scanResults.listen((results) {
      setState(() {
        _scanResults.clear();
        _scanResults.addAll(results);
      });
    }, onError: (e) => log("Ошибка сканирования: $e"));
  }

  Future<void> _requestPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  Future<void> _startScan() async {
    await bleManager.startScan();
  }

@override
void dispose() {
  _scanSubscription?.cancel();
  bleManager.dispose(); // Теперь очищаем всё
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Scanner")),
      body: ListView.builder(
        itemCount: _scanResults.length,
        itemBuilder: (context, index) {
          final deviceId = _scanResults[index].deviceId;
          final name = _scanResults[index].deviceName;
          final device = _scanResults[index].device;
          return ListTile(
            title: Text(name.isNotEmpty ? name : "Без имени"),
            subtitle: Text(deviceId),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceScreen(device: device),
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
