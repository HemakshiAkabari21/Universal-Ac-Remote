package com.example.universal_ac_remote;

import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "universal_ac/ir";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {

                    IrService irService = new IrService(this);

                    switch (call.method) {
                        case "hasIrEmitter":
                            result.success(irService.hasIrEmitter());
                            break;

                        case "transmit":
                            int frequency = call.argument("frequency");
                            java.util.List<Integer> list = call.argument("pattern");
                            int[] pattern = new int[list.size()];
                            for (int i = 0; i < list.size(); i++) {
                                pattern[i] = list.get(i);
                            }
                            boolean success = irService.transmit(frequency, pattern);
                            result.success(success);
                            break;

                        default:
                            result.notImplemented();
                    }
                }
        );
    }
}