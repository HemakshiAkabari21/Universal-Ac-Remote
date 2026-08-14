import 'package:flutter/material.dart';
import 'package:universal_ac_remote/model/ac_unit_model.dart';
import 'package:universal_ac_remote/model/discover_ac_model.dart';
import 'package:universal_ac_remote/screens/ac_remote_page_screen.dart';
import 'discover_ac_page_screen.dart';

class AcListPage extends StatefulWidget {
  const AcListPage({super.key});

  @override
  State<AcListPage> createState() => _AcListPageState();
}

class _AcListPageState extends State<AcListPage> {

  final List<ACUnit> acUnits = [
    ACUnit(id: 'office_ac_001', name: 'Office AC', brand: 'Mitsubishi Heavy Industries', room: 'Office'),
    ACUnit(name: 'Bedroom AC', brand: 'LG', room: 'Bedroom', id: 'ac_002'),
  ];

  void openRemote(ACUnit ac) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ACRemotePage( acName: ac.name, brand: ac.brand,)));
  }

  Future<void> openDiscovery() async {
    final DiscoveredAC? discoveredAC = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => const DiscoverACPage()));

    if (discoveredAC == null) {
      return;
    }

    addDiscoveredAC(discoveredAC);
  }

  void addDiscoveredAC(DiscoveredAC discoveredAC) {
    final alreadyExists = acUnits.any((ac) => ac.id == discoveredAC.id);

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This AC is already added.')));
      return;
    }

    final newAC = ACUnit(id: discoveredAC.id, name: discoveredAC.deviceName, brand: discoveredAC.brand, room: 'Not assigned');

    setState(() {acUnits.add(newAC);});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${discoveredAC.deviceName} added successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My ACs')),
      floatingActionButton: FloatingActionButton.extended(onPressed: openDiscovery, icon: const Icon(Icons.add), label: const Text('Add AC')),
      body: acUnits.isEmpty ? const Center(child: Text('No ACs added yet'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acUnits.length,
        itemBuilder: (context, index) {
          final ac = acUnits[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(child: Icon(Icons.ac_unit)),
              title: Text(ac.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${ac.brand} • ${ac.room}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => openRemote(ac),
            ),
          );
        },
      ),
    );
  }
}
