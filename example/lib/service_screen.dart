import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ServiceScreen extends StatefulWidget {
  final BluetoothService service;

  const ServiceScreen({super.key, required this.service});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  List<BluetoothCharacteristic> _characteristics = [];
  BluetoothCharacteristic? _selectedCharacteristic;
  String _receivedData = "Нет данных";

  @override
  void initState() {
    super.initState();
    _loadCharacteristics();
  }

  Future<void> _loadCharacteristics() async {
    setState(() {
      _characteristics = widget.service.characteristics;
    });
  }

  Future<void> _subscribeToCharacteristic(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.onValueReceived.listen((value) {
      setState(() {
        _receivedData = String.fromCharCodes(value);
      });
    });

    setState(() {
      _selectedCharacteristic = characteristic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Сервис: ${widget.service.uuid}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _characteristics.length,
              itemBuilder: (context, index) {
                final characteristic = _characteristics[index];
                return ListTile(
                  title: Text("Характеристика: ${characteristic.uuid}"),
                  onTap: () => _subscribeToCharacteristic(characteristic),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Полученные данные: $_receivedData",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
