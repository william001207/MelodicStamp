//
//  FFTHelper.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/26.
//

import Accelerate
import Foundation

enum FFTHelper {
    static func perform(_ data: [Float], sampleRate: Float, minFrequency: Float = 80, maxFrequency: Float = 2000) async -> [Float] {
        
        let monoData = data.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }

        let log2n = vDSP_Length(log2(Float(monoData.count)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2)) else {
            fatalError("Failed to create FFT setup.")
        }

        // Apply the Hann window
        var window = [Float](repeating: 0.0, count: monoData.count)
        vDSP_hann_window(&window, vDSP_Length(monoData.count), Int32(vDSP_HANN_NORM))
        var windowedData = [Float](repeating: 0.0, count: monoData.count)
        vDSP_vmul(monoData, 1, window, 1, &windowedData, 1, vDSP_Length(monoData.count))

        return windowedData.withUnsafeMutableBufferPointer { realPointer in
            var imaginary: [Float] = .init(repeating: 0.0, count: monoData.count)
            return imaginary.withUnsafeMutableBufferPointer { imaginaryPointer in
                var complexBuffer = DSPSplitComplex(realp: realPointer.baseAddress!, imagp: imaginaryPointer.baseAddress!)

                // Execute FFT
                vDSP_fft_zip(fftSetup, &complexBuffer, 1, log2n, FFTDirection(FFT_FORWARD))

                // Calculated amplitude
                var magnitudes: [Float] = .init(repeating: 0.0, count: monoData.count / 2)
                vDSP_zvmags(&complexBuffer, 1, &magnitudes, 1, vDSP_Length(magnitudes.count))

                // Normalized to decibels
                var normalizedMagnitudes: [Float] = .init(repeating: 0.0, count: magnitudes.count)
                vDSP_vdbcon(magnitudes, 1, [1.0], &normalizedMagnitudes, 1, vDSP_Length(magnitudes.count), 1)

                // Frequency resolution
                let frequencyResolution = sampleRate / Float(monoData.count)

                // Find the index for the desired frequency range
                let minIndex = max(Int(minFrequency / frequencyResolution), 0)
                let maxIndex = min(Int(maxFrequency / frequencyResolution), normalizedMagnitudes.count - 1)

                // Extract desired range
                let filteredMagnitudes = Array(normalizedMagnitudes[minIndex...maxIndex])

                vDSP_destroy_fftsetup(fftSetup)
                return filteredMagnitudes
            }
        }
    }
}
