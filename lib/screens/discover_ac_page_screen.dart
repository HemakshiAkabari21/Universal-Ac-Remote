import 'dart:async';

import 'package:flutter/material.dart';
import 'package:universal_ac_remote/model/discover_ac_model.dart';

class DiscoverACPage extends StatefulWidget {
  const DiscoverACPage({super.key});

  @override
  State<DiscoverACPage> createState() => _DiscoverACPageState();
}

class _DiscoverACPageState extends State<DiscoverACPage> {
  final List<DiscoveredAC> discoveredDevices = [];
  bool isScanning = false;
  Timer? scanTimer;

  @override
  void initState() {
    super.initState();
    startDiscovery();
  }

  @override
  void dispose() {
    scanTimer?.cancel();
    super.dispose();
  }

  void startDiscovery() {
    scanTimer?.cancel();

    setState(() {
      isScanning = true;
      discoveredDevices.clear();
    });

    final fakeDevices = [
      DiscoveredAC(id: 'esp32_001', deviceName: 'Living Room AC', brand: 'Samsung', signalStrength: 92, estimatedDistance: 2.1),
      DiscoveredAC(id: 'esp32_002', deviceName: 'Bedroom AC', brand: 'LG', signalStrength: 73, estimatedDistance: 5.8),
      DiscoveredAC(id: 'esp32_003', deviceName: 'Kitchen AC', brand: 'Daikin', signalStrength: 51, estimatedDistance: 9.4),
    ];

    int index = 0;

    scanTimer = Timer.periodic(
      const Duration(milliseconds: 800), (timer) {
        if (index >= fakeDevices.length) {
          timer.cancel();
          if (mounted) {
            setState(() {isScanning = false;});
          }
          return;
        }
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          discoveredDevices.add(fakeDevices[index]);
          discoveredDevices.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
        });
        index++;
      },
    );
  }

  void selectDevice(DiscoveredAC device) {
    Navigator.pop(context, device);
  }

  String signalText(int signal) {
    if (signal >= 80) {
      return 'Excellent';
    }

    if (signal >= 60) {
      return 'Good';
    }

    if (signal >= 40) {
      return 'Fair';
    }

    return 'Weak';
  }

  IconData signalIcon(int signal) {
    if (signal >= 80) {
      return Icons.signal_cellular_4_bar;
    }

    if (signal >= 60) {
      return Icons.network_cell;
    }

    if (signal >= 40) {
      return Icons.signal_cellular_alt_2_bar;
    }

    return Icons.signal_cellular_alt_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover ACs'),
        actions: [
          IconButton(onPressed: isScanning ? null : startDiscovery, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isScanning)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.check_circle),
                const SizedBox(width: 12),
                Expanded(child: Text(isScanning ? 'Searching for nearby AC controllers...' : '${discoveredDevices.length} AC controller(s) found')),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: discoveredDevices.isEmpty
                ? Center(child: isScanning
                  ? const Text('Looking for ACs...')
                  : const Text('No AC controllers found.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: discoveredDevices.length,
              itemBuilder: (context, index) {
                final device = discoveredDevices[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(radius: 26, child: Icon(Icons.ac_unit)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(device.deviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                  const SizedBox(height: 4),
                                  Text(device.brand),
                                ],
                              ),
                            ),
                            Icon(signalIcon(device.signalStrength)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.signal_cellular_alt, size: 18),
                            const SizedBox(width: 6),
                            Text('${signalText(device.signalStrength)} ''(${device.signalStrength}%)'),
                            const Spacer(),
                            const Icon(Icons.social_distance, size: 18),
                            const SizedBox(width: 6),
                            Text('~${device.estimatedDistance} m'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {selectDevice(device);},
                            child: const Text('Select AC'))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
