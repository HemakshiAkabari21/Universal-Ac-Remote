package com.example.universal_ac_remote

import android.content.Context
import android.hardware.ConsumerIrManager

class IrService(private val context: Context) {

    private val irManager = context.getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

    fun hasIrEmitter(): Boolean {
        return irManager?.hasIrEmitter() == true
    }

    fun getCarrierFrequencies(): Array<ConsumerIrManager.CarrierFrequencyRange> {
        return irManager?.carrierFrequencies ?: emptyArray()
    }

    fun transmit(frequency: Int, pattern: IntArray): Boolean {

        if (irManager == null) { return false }

        if (!irManager.hasIrEmitter()) { return false }

        irManager.transmit(frequency, pattern)
        return true
    }
}