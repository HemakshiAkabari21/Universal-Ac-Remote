import 'package:flutter/services.dart';

class IRService {
  static const MethodChannel _channel = MethodChannel('universal_ac/ir');

  static Future<bool> hasIrEmitter() async {
    final result = await _channel.invokeMethod<bool>(
      'hasIrEmitter',
    );

    return result ?? false;
  }

  static Future<bool> transmit({
    required int frequency,
    required List<int> pattern,
  }) async {
    final result = await _channel.invokeMethod<bool>(
      'transmit',
      {
        'frequency': frequency,
        'pattern': pattern,
      },
    );

    return result ?? false;
  }
}