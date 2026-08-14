import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class IRService {
  static const MethodChannel channel = MethodChannel('universal_ac/ir');

  static Future<bool> hasIrEmitter() async {
    final result = await channel.invokeMethod<bool>('hasIrEmitter');

    return result ?? false;
  }

  static Future<List<Map<String, int>>> getCarrierFrequencies() async {
    try {
      final result = await channel.invokeMethod<List<dynamic>>('getCarrierFrequencies');

      if (result == null) {
        return [];
      }
      return result.map((item) {
        final map = Map<String, dynamic>.from(item);

        return {
          'min': map['min'] as int,
          'max': map['max'] as int,
        };
      }).toList();
    } catch (e) {
      debugPrint('[IR] Failed to get carrier frequencies: $e');
      return [];
    }
  }


  static Future<bool> transmit({required int frequency, required List<int> pattern}) async {
    final result = await channel.invokeMethod<bool>('transmit',{
        'frequency': frequency,
        'pattern': pattern,
      });

    return result ?? false;
  }
}