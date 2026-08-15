package com.example.universal_ac_remote;

import android.hardware.ConsumerIrManager;
import android.os.Bundle;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

                        case "getCarrierFrequencies":
                            ConsumerIrManager.CarrierFrequencyRange[] ranges = irService.getCarrierFrequencies();
                            List<Map<String, Integer>> rangeList = new ArrayList<>();
                            for (ConsumerIrManager.CarrierFrequencyRange range : ranges) {
                                Map<String, Integer> map = new HashMap<>();
                                map.put("min", range.getMinFrequency());
                                map.put("max", range.getMaxFrequency());
                                rangeList.add(map);
                            }
                            result.success(rangeList);
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