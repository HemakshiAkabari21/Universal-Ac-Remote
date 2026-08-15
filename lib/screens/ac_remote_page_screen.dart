import 'package:flutter/material.dart';
import 'package:universal_ac_remote/model/ac_state.dart';
import 'package:universal_ac_remote/protocols/mhi_encoder.dart';
import 'package:universal_ac_remote/services/ir_service.dart';

class ACRemotePage extends StatefulWidget {
  final String acName;
  final String brand;

  const ACRemotePage({super.key, required this.acName, required this.brand});

  @override
  State<ACRemotePage> createState() => _ACRemotePageState();
}

class _ACRemotePageState extends State<ACRemotePage> {
  ACState ac = const ACState();
  bool sending = false;

  @override
  void initState() {
    // TODO: implement initState
    checkIR();
    super.initState();
  }


  // POWER

  Future<void> togglePower() async {
    setState(() {
      ac = ac.copyWith(
        power: !ac.power,
      );
    });

    await sendCurrentState();
  }

  // TEMPERATURE

  Future<void> increaseTemperature() async {
    if (ac.temperature >= 30) {
      debugPrint('[AC] Temperature already at maximum: ${ac.temperature}°C');
      return;
    }
    setState(() { ac = ac.copyWith(temperature: ac.temperature + 1); });
    await sendCurrentState();
  }

  Future<void> decreaseTemperature() async {
    if (ac.temperature <= 17) { // matches MHI's real hardware floor
      debugPrint('[AC] Temperature already at minimum: ${ac.temperature}°C');
      return;
    }
    setState(() { ac = ac.copyWith(temperature: ac.temperature - 1); });
    await sendCurrentState();
  }

 /* Future<void> decreaseTemperature() async {
    if (ac.temperature <= 16) {
      debugPrint('[AC] Temperature already at minimum: ''${ac.temperature}°C');
      return;
    }
    final oldTemperature = ac.temperature;
    final newTemperature = oldTemperature - 1;
    debugPrint('[AC] Temperature decrease requested: ''$oldTemperature°C → $newTemperature°C');
    setState(() {
      ac = ac.copyWith(temperature: newTemperature);
    });
    await sendTemperatureCommand(newTemperature);
  }*/

  Future<void> checkIR() async {
    debugPrint('[IR] Checking Redmi IR emitter...');
    final available = await IRService.hasIrEmitter();
    if (!available) {
      debugPrint('[IR] Redmi IR emitter: NOT AVAILABLE');
      debugPrint('[AC] Controller status: NOT READY');
      return;
    }
    debugPrint('[IR] Redmi IR emitter: AVAILABLE');
    try {
      final ranges = await IRService.getCarrierFrequencies();
      if (ranges.isEmpty) {
        debugPrint('[IR] No carrier frequency information returned');
      } else {
        for (final range in ranges) {
          debugPrint('[IR] Carrier: ''${range['min']} Hz - ''${range['max']} Hz');
        }
      }
      debugPrint('[AC] Controller status: READY');
    } catch (e) {
      debugPrint('[IR] Carrier frequency check FAILED: $e');
      debugPrint('[AC] Controller status: NOT READY');
    }
  }

  Future<void> sendTemperatureCommand(int temperature) async {
    debugPrint('========================================');

    debugPrint('[AC] Office AC command');
    debugPrint('[AC] Brand: ${widget.brand}');
    debugPrint('[AC] Remote: RKX502A009');
    debugPrint('[AC] Target temperature: $temperature°C');

    // This will become the real verified encoder.
    final command = MHIEncoder152.encode(temperature: temperature, mode: ac.mode ?? ACMode.cool, fan: ac.fanSpeed ?? ACFanSpeed.auto, state: ac);

    debugPrint('[IR] Carrier: ${command.frequency} Hz',);

    debugPrint('[IR] Pattern length: ${command.pattern.length}',);

    debugPrint('[IR] Transmitting...');

    final success = await IRService.transmit(pattern: command.pattern, frequency: command.frequency);

    if (success) {
      debugPrint('[IR] Transmission completed');
      debugPrint('[AC] Command status: SENT',);
      debugPrint('[AC] AC acknowledgement: NOT AVAILABLE');
    } else {
      debugPrint('[IR] Transmission FAILED');
    }

    debugPrint('========================================');
  }


  // MODE

  Future<void> changeMode(ACMode mode) async {
    setState(() {ac = ac.copyWith(mode: mode);});
    await sendCurrentState();
  }

  // FAN

  Future<void> changeFanSpeed(ACFanSpeed speed,) async {
    setState(() {
      ac = ac.copyWith(fanSpeed: speed);
    });
    await sendCurrentState();
  }

  // SWING

  Future<void> toggleSwing() async {
    setState(() {ac = ac.copyWith(swing: !ac.swing);});
    await sendCurrentState();
  }

  // 3D AUTO

  Future<void> toggle3DAuto() async {
    setState(() {ac = ac.copyWith(threeDAuto: !ac.threeDAuto);});
    await sendCurrentState();
  }

  // ECO

  Future<void> toggleEco() async {
    setState(() {ac = ac.copyWith(eco: !ac.eco);});
    await sendCurrentState();
  }

  // HIGH POWER

  Future<void> toggleHighPower() async {
    setState(() {ac = ac.copyWith(highPower: !ac.highPower);});
    await sendCurrentState();
  }

  // SEND CURRENT AC STATE

  Future<void> sendCurrentState() async {
    if (sending) return;

    setState(() { sending = true; });

    try {
      debugPrint('========================================');
      debugPrint('AC STATE: power=${ac.power}, temperature=${ac.temperature}, mode=${ac.mode}, '
          'fan=${ac.fanSpeed}, swing=${ac.swing}, 3D=${ac.threeDAuto}, eco=${ac.eco}, highPower=${ac.highPower}');

      final command = MHIEncoder152.encode(
        temperature: ac.temperature,
        mode: ac.mode,
        fan: ac.fanSpeed,
        state: ac,
      );

      debugPrint('[IR] Carrier: ${command.frequency} Hz, pattern length: ${command.pattern.length}');
      debugPrint('[IR] Transmitting...');

      final success = await IRService.transmit(pattern: command.pattern, frequency: command.frequency);

      debugPrint(success ? '[IR] Transmission completed' : '[IR] Transmission FAILED');
      debugPrint('========================================');
    } finally {
      if (mounted) setState(() { sending = false; });
    }
  }

  // HELPERS

  String modeName(ACMode mode) {
    switch (mode) {
      case ACMode.auto:
        return 'AUTO';

      case ACMode.cool:
        return 'COOL';

      case ACMode.dry:
        return 'DRY';

      case ACMode.fan:
        return 'FAN';

      case ACMode.heat:
        return 'HEAT';
    }
  }

  String fanName(ACFanSpeed speed) {
    switch (speed) {
      case ACFanSpeed.auto:
        return 'AUTO';

      case ACFanSpeed.low:
        return 'LOW';

      case ACFanSpeed.medium:
        return 'MEDIUM';

      case ACFanSpeed.high:
        return 'HIGH';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.acName), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(widget.brand, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),

              // POWER

              Align(alignment: Alignment.centerRight, child: IconButton.filled(onPressed: togglePower,
                  icon: Icon(Icons.power_settings_new), style: IconButton.styleFrom(minimumSize: const Size(56, 56)))),
              const SizedBox(height: 10),

              // TEMPERATURE

              Text('${ac.temperature}°C', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(ac.power ? modeName(ac.mode) : 'OFF', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  roundButton(icon: Icons.remove, onPressed: ac.power ? decreaseTemperature : null),
                  const SizedBox(width: 40),
                  roundButton(icon: Icons.add, onPressed: ac.power ? increaseTemperature : null),
                ],
              ),
              const SizedBox(height: 32),

              // MODE

              sectionTitle('MODE'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  modeButton('AUTO', ACMode.auto),
                  modeButton('COOL', ACMode.cool),
                  modeButton('DRY', ACMode.dry),
                  modeButton('FAN', ACMode.fan),
                  modeButton('HEAT', ACMode.heat),
                ],
              ),
              const SizedBox(height: 28),

              // FAN

              sectionTitle('FAN SPEED'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  fanButton('AUTO', ACFanSpeed.auto),
                  fanButton('LOW', ACFanSpeed.low),
                  fanButton('MED', ACFanSpeed.medium),
                  fanButton('HIGH', ACFanSpeed.high),
                ],
              ),
              const SizedBox(height: 28),

              // OPTIONS

              sectionTitle('OPTIONS'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(secondary: const Icon(Icons.swap_vert), title: const Text('Air Swing'), value: ac.swing,
                        onChanged: ac.power ? (_) => toggleSwing() : null),
                    const Divider(height: 1),
                    SwitchListTile(secondary: const Icon(Icons.air), title: const Text('3D AUTO'), value: ac.threeDAuto,
                        onChanged: ac.power ? (_) => toggle3DAuto() : null),
                    const Divider(height: 1),
                    SwitchListTile(secondary: const Icon(Icons.eco), title: const Text('ECONO'),
                        value: ac.eco, onChanged: ac.power ? (_) => toggleEco() : null),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.bolt),
                      title: const Text('HI POWER'),
                      value: ac.highPower,
                      onChanged: ac.power ? (_) => toggleHighPower() : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CONNECTION STATUS

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.settings_remote),
                      const SizedBox(width: 12),
                      Expanded(child: Text(sending ? 'Sending...' : 'IR remote ready')),
                      if (sending)
                        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET

  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget roundButton({required IconData icon, required VoidCallback? onPressed}) {
    return SizedBox(width: 70, height: 70, child: IconButton.filled(onPressed: onPressed, icon: Icon(icon, size: 32)));
  }

  Widget modeButton(String text, ACMode mode) {
    final selected = ac.mode == mode;

    return FilledButton(
      onPressed: ac.power ? () => changeMode(mode) : null,
      style: FilledButton.styleFrom(
        backgroundColor: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(text),
    );
  }

  Widget fanButton(String text, ACFanSpeed speed) {
    final selected = ac.fanSpeed == speed;
    return ChoiceChip(label: Text(text), selected: selected,onSelected: ac.power ? (_) => changeFanSpeed(speed) : null);
  }
}