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
                            Integer frequency = call.argument("frequency");
                            java.util.List<Integer> pattern = call.argument("pattern");

                            if (frequency == null || pattern == null) {
                                result.error("INVALID_ARGUMENT", "Missing IR data", null);
                                return;
                            }

                            int[] patternArray = new int[pattern.size()];

                            for (int i = 0; i < pattern.size(); i++) {
                                patternArray[i] = pattern.get(i);
                            }

                            boolean success = irService.transmit(frequency, patternArray);
                            result.success(success);
                            break;

                        default:
                            result.notImplemented();
                    }
                }
        );
    }
}