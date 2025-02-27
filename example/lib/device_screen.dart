import 'package:flutter/material.dart';
import 'package:ble_manager/ble_manager.dart';
import 'package:example/service_screen.dart'; // Подключаем экран сервиса

class DeviceScreen extends StatefulWidget {
  final String deviceId;

  const DeviceScreen({super.key, required this.deviceId});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final BleManager _bleManager = BleManager();
  List<String> _services = [];

  @override
  void initState() {
    super.initState();
    _bleManager.connectToDevice(widget.deviceId);
    _bleManager.servicesStream.listen((services) {
      setState(() {
        _services = services;
      });
    });
  }

  void _navigateToService(String serviceId) async {
    var service = await _bleManager.getServiceById(widget.deviceId, serviceId);
    if (service != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceScreen(service: service),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка: сервис не найден")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Устройство: ${widget.deviceId}")),
      body: _services.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final serviceId = _services[index];
                return ListTile(
                  title: Text(serviceId),
                  onTap: () => _navigateToService(serviceId),
                );
              },
            ),
    );
  }
}
