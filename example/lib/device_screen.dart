// import 'package:ble_learn/service_screen.dart';
import 'package:example/service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({super.key, required this.device});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService> _services = [];

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    await widget.device.connect();
    print("Подключен к ${widget.device.remoteId}");

    _services = await widget.device.discoverServices();
    setState(() {});
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Устройство: ${widget.device.remoteId}")),
      body:
          _services.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return ListTile(
                    title: Text(service.uuid.toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceScreen(service: service),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
