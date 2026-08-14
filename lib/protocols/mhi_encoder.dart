import 'package:universal_ac_remote/model/ac_state.dart';

/// Mitsubishi Heavy "ZM-S" 152-bit protocol — alternate candidate if ZJ-S
/// (88-bit) gets no response. Structure verified against
/// IRremoteESP8266's ir_MitsubishiHeavy.{h,cpp} (RLA502A700B / SRKxxZM-S).
class MHIEncoder152 {
  static const int hdrMark = 3140;
  static const int hdrSpace = 1630;
  static const int bitMark = 370;
  static const int oneSpace = 420;
  static const int zeroSpace = 1220;
  static const int messageGap = 100000;
  static const int carrierFrequency = 38000;

  static const int minTemp = 17;
  static const int maxTemp = 31;

  static const List<int> zmsSig = [0xAD, 0x51, 0x3C, 0xE5, 0x1A];

  static const Map<ACMode, int> _modeMap = {
    ACMode.auto: 0,
    ACMode.cool: 1,
    ACMode.dry: 2,
    ACMode.fan: 3,
    ACMode.heat: 4,
  };

  // Sequential here, unlike the 88-bit variant.
  static const Map<ACFanSpeed, int> fanMap = {
    ACFanSpeed.auto: 0x0,
    ACFanSpeed.low: 0x1,
    ACFanSpeed.medium: 0x2,
    ACFanSpeed.high: 0x3,
  };

  static ({int frequency, List<int> pattern}) encode({required int temperature, required ACMode mode, required ACFanSpeed fan, ACState? state,
  }) {
    final t = temperature.clamp(minTemp, maxTemp) - minTemp; // 4 bits
    final modeVal = _modeMap[mode] ?? 0;
    final fanVal = fanMap[fan] ?? 0;
    final power = state?.power ?? true;
    const swingV = 0; // 3-bit field, Off=6/Auto=0 per header — left at Auto
    const swingH = 0;
    const night = 0;
    const silent = 0;
    const clean = 0;
    const filter = 0;

    final bytes = List<int>.filled(19, 0)..setRange(0, 5, zmsSig);

    // Byte 5: b0-2 Mode, b3 Power, b4 unused, b5 Clean, b6 Filter, b7 unused
    bytes[5] = (modeVal & 0x7) | ((power ? 1 : 0) << 3) | ((clean & 1) << 5) | ((filter & 1) << 6);
    bytes[6] = (~bytes[5]) & 0xFF;

    // Byte 7: b0-3 Temp
    bytes[7] = t & 0xF;
    bytes[8] = (~bytes[7]) & 0xFF;

    // Byte 9: b0-3 Fan
    bytes[9] = fanVal & 0xF;
    bytes[10] = (~bytes[9]) & 0xFF;

    // Byte 11: b1 Three, b4 D, b5-7 SwingV
    bytes[11] = ((swingV & 0x7) << 5);
    bytes[12] = (~bytes[11]) & 0xFF;

    // Byte 13: b0-3 SwingH
    bytes[13] = swingH & 0xF;
    bytes[14] = (~bytes[13]) & 0xFF;

    // Byte 15: b6 Night, b7 Silent
    bytes[15] = ((night & 1) << 6) | ((silent & 1) << 7);
    bytes[16] = (~bytes[15]) & 0xFF;

    // Byte 17 is a fixed reserved value per the library's stateReset (0x80).
    bytes[17] = 0x80;
    bytes[18] = (~bytes[17]) & 0xFF;

    final pattern = <int>[hdrMark, hdrSpace];
    for (final byte in bytes) {
      for (int i = 0; i < 8; i++) {
        pattern.add(bitMark);
        pattern.add(((byte >> i) & 1) == 1 ? oneSpace : zeroSpace);
      }
    }
    pattern.add(bitMark);
    pattern.add(messageGap);

    return (frequency: carrierFrequency, pattern: pattern);
  }
}