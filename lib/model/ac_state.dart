enum ACMode { auto, cool, dry, fan, heat}

enum ACFanSpeed { auto, low, medium, high}

class ACState {
  final bool power;
  final int temperature;
  final ACMode mode;
  final ACFanSpeed fanSpeed;
  final bool swing;
  final bool threeDAuto;
  final bool eco;
  final bool highPower;

  const ACState({
    this.power = false,
    this.temperature = 24,
    this.mode = ACMode.cool,
    this.fanSpeed = ACFanSpeed.auto,
    this.swing = false,
    this.threeDAuto = false,
    this.eco = false,
    this.highPower = false,
  });

  ACState copyWith({bool? power, int? temperature, ACMode? mode, ACFanSpeed? fanSpeed, bool? swing, bool? threeDAuto, bool? eco, bool? highPower}) {
    return ACState(
      power: power ?? this.power,
      temperature: temperature ?? this.temperature,
      mode: mode ?? this.mode,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      swing: swing ?? this.swing,
      threeDAuto: threeDAuto ?? this.threeDAuto,
      eco: eco ?? this.eco,
      highPower: highPower ?? this.highPower,
    );
  }
}
