//
//  FFTHelper.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/26.
//

import Accelerate
import Foundation

enum FFTHelper {
    static func perform(_ data: [Float]) async -> [Float] {
        let log2n = vDSP_Length(log2(Float(data.count)))
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!

        var real = data
        return real.withUnsafeMutableBufferPointer { realPointer in
            var imaginary: [Float] = .init(repeating: 0.0, count: data.count)
            return imaginary.withUnsafeMutableBufferPointer { imaginaryPointer in
                var complexBuffer = DSPSplitComplex(realp: realPointer.baseAddress!, imagp: imaginaryPointer.baseAddress!)

                vDSP_fft_zip(fftSetup, &complexBuffer, 1, log2n, FFTDirection(FFT_FORWARD))

                var magnitudes: [Float] = .init(repeating: 0.0, count: data.count / 2)
                vDSP_zvmags(&complexBuffer, 1, &magnitudes, 1, vDSP_Length(magnitudes.count))

                var normalizedMagnitudes: [Float] = .init(repeating: 0.0, count: magnitudes.count)
                vDSP_vdbcon(magnitudes, 1, [1.0], &normalizedMagnitudes, 1, vDSP_Length(magnitudes.count), 1)

                vDSP_destroy_fftsetup(fftSetup)
                return normalizedMagnitudes
            }
        }
    }
}
