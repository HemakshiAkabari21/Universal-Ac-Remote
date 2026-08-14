import 'package:flutter/material.dart';
import 'package:universal_ac_remote/model/ac_unit_model.dart';
import 'package:universal_ac_remote/services/ir_service.dart';

class ACRemotePage extends StatefulWidget {
  final ACUnit ac;

  const ACRemotePage({super.key, required this.ac});

  @override
  State<ACRemotePage> createState() => _ACRemotePageState();
}

class _ACRemotePageState extends State<ACRemotePage> {

  int temperature = 24;
  bool isOn = true;
  String mode = 'Cool';
  String fanSpeed = 'Auto';
  bool swing = false;

  void increaseTemperature() {
    if (temperature < 30) {
      setState(() {temperature++;});
    }
  }

  void decreaseTemperature(){
    if (temperature > 16) {setState(() {temperature--;});}
  }

  void togglePower() {setState(() {isOn = !isOn;});}

  Future<void> testIR() async {
    final hasIR = await IRService.hasIrEmitter();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hasIR ? 'IR blaster detected!' : 'No IR blaster detected.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ac.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(widget.ac.brand, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 30),
            const Icon(Icons.ac_unit, size: 70),
            const SizedBox(height: 20),
            Text('$temperature°C', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(onPressed: decreaseTemperature, icon: const Icon(Icons.remove), iconSize: 30),
                const SizedBox(width: 30),
                IconButton.filled(onPressed: increaseTemperature, icon: const Icon(Icons.add), iconSize: 30),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
                width: double.infinity,
                child: FilledButton.icon(onPressed: togglePower, icon: Icon(isOn ? Icons.power_settings_new : Icons.power_off),
                    label: Text(isOn ? 'POWER ON' : 'POWER OFF'))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mode'),
                DropdownButton<String>(
                  value: mode,
                  items: const [
                    DropdownMenuItem(value: 'Cool', child: Text('Cool')),
                    DropdownMenuItem(value: 'Heat', child: Text('Heat')),
                    DropdownMenuItem(value: 'Dry', child: Text('Dry')),
                    DropdownMenuItem(value: 'Fan', child: Text('Fan')),
                    DropdownMenuItem(value: 'Auto', child: Text('Auto')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {mode = value;});
                  },
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fan Speed'),
                DropdownButton<String>(
                  value: fanSpeed,
                  items: const [
                    DropdownMenuItem(value: 'Auto', child: Text('Auto')),
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {fanSpeed = value;});
                  },
                ),
              ],
            ),

            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Swing'), value: swing, onChanged: (value) {setState(() {swing = value;});}),

            FilledButton.icon(onPressed: testIR, icon: const Icon(Icons.settings_remote), label: const Text('Test IR'))
          ],
        ),
      ),
    );
  }
}
