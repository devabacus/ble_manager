import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleScanResult {
  final String deviceName;
  final String deviceId;

  BleScanResult({required this.deviceName, required this.deviceId});
}

class BleManager {
  static final BleManager _instance = BleManager._internal();
  factory BleManager() => _instance;
  BleManager._internal();

  final StreamController<List<BleScanResult>> _scanResultsController =
      StreamController.broadcast();
  final StreamController<List<String>> _servicesController =
      StreamController.broadcast();

  Stream<List<BleScanResult>> get scanResults => _scanResultsController.stream;
  Stream<List<String>> get servicesStream => _servicesController.stream;

  Future<void> requestPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }


Future<BluetoothService?> getServiceById(String deviceId, String serviceId) async {
  var device = BluetoothDevice.fromId(deviceId);
  var services = await device.discoverServices();
  try {
    return services.firstWhere(
      (service) => service.uuid.toString() == serviceId,
    );
  } catch (e) {
    return null; // Безопасное возвращение null
  }
}


  Future<void> startScan() async {
    FlutterBluePlus.scanResults.listen((results) {
      final transformedResults = results
          .map((r) => BleScanResult(
                deviceName: r.advertisementData.advName.isNotEmpty
                    ? r.advertisementData.advName
                    : "Без имени Bdfy",
                deviceId: r.device.remoteId.toString(),
              ))
          .toList();
      _scanResultsController.add(transformedResults);
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

Future<void> connectToDevice(String deviceId) async {
    var device = BluetoothDevice.fromId(deviceId); // Исправлено!
    await device.connect();
    var services = await device.discoverServices();
    _servicesController.add(services.map((s) => s.uuid.toString()).toList());
}
  void dispose() {
    _scanResultsController.close();
    _servicesController.close();
  }
}
