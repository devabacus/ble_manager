import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Обертка для результата сканирования BLE
class BleScanResult {
  final String deviceName;
  final String deviceId;
  final BluetoothDevice device;

  BleScanResult({
    required this.deviceName,
    required this.deviceId,
    required this.device,
  });

  /// Конвертируем `ScanResult` в `BleScanResult`
  factory BleScanResult.fromScanResult(ScanResult result) {
    return BleScanResult(
      deviceName:
          result.advertisementData.advName.isNotEmpty
              ? result.advertisementData.advName
              : "Без имени",
      deviceId: result.device.remoteId.toString(),
      device: result.device,
    );
  }
}

class BleManager {
  static final BleManager _instance = BleManager._internal();
  factory BleManager() => _instance;
  BleManager._internal();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;
  final StreamController<List<BleScanResult>> _scanResultsController =
      StreamController.broadcast();

  Future<void> requestPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  /// Теперь возвращаем `Stream<List<BleScanResult>>`, а не `ScanResult`
  Stream<List<BleScanResult>> get scanResults => _scanResultsController.stream;

  /// Начало сканирования BLE
  Future<void> startScan() async {
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      final transformedResults =
          results
              .map((scanResult) => BleScanResult.fromScanResult(scanResult))
              .toList();
      _scanResultsController.add(transformedResults);
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  /// Остановка сканирования
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
  }

  /// Подключение к BLE-устройству
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }

  /// Отключение от BLE-устройства
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    await device.disconnect();
  }

  /// Получение списка сервисов устройства
  Future<List<BluetoothService>> discoverServices(
    BluetoothDevice device,
  ) async {
    return await device.discoverServices();
  }

  /// Отписка от текущей характеристики (если есть)
  Future<void> unsubscribeFromCharacteristic(
    BluetoothCharacteristic characteristic,
  ) async {
    await characteristic.setNotifyValue(false); // Отключаем уведомления
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
  }

  Future<void> subscribeToCharacteristic(
    BluetoothCharacteristic characteristic,
  ) async {
    await unsubscribeFromCharacteristic(
      characteristic,
    ); // Передаём characteristic
    await characteristic.setNotifyValue(true);
    _characteristicSubscription = characteristic.onValueReceived.listen((
      value,
    ) {
      print("Получены данные: ${String.fromCharCodes(value)}");
    });
  }

  /// Отправка данных в характеристику
  Future<void> writeToCharacteristic(
    BluetoothCharacteristic characteristic,
    List<int> data,
  ) async {
    await characteristic.write(data, withoutResponse: false);
  }

  /// Очистка всех потоков и подписок (для предотвращения утечек памяти)
  void dispose() {
    _scanSubscription?.cancel();
    _characteristicSubscription?.cancel();
    _scanResultsController.close();
  }
}
