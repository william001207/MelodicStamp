//
//  ArithmaticAlgorithms.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/30.
//

import Foundation

func lerp<Value>(_ a: Value, _ b: Value, factor t: Double) -> Value where Value: BinaryFloatingPoint {
    let t = min(max(t, 0), 1)
    return a + (b - a) * Value(t)
}

/// Generates a bell curve value for a given x, mean, standard deviation, and amplitude.
/// It's worth noting that the integral of this bell curve is not 1, instead, the max value of this bell curve is always 1.
/// - Parameters:
///   - x: The x-value at which to evaluate the bell curve.
///   - mean: The mean (center) of the bell curve.
///   - standardDeviation: The standard deviation (width) of the bell curve. Higher values result in a wider curve.
///   - amplitude: The peak (height) of the bell curve.
/// - Returns: The y-value of the bell curve at the given x.
func bellCurve<Value>(
    _ value: Value,
    mean: Value = .zero,
    standardDeviation: Value = 1,
    amplitude: Value = 1
) -> Value where Value: BinaryFloatingPoint {
    let exponent = -pow(Double(value - mean), 2) / (2 * pow(Double(standardDeviation), 2))
    return amplitude * Value(exp(exponent))
}

/// Sigmoid-like function that bends the input curve around 0.5.
/// - Parameters:
///   - x: The input value, expected to be in the range [0, 1].
///   - curvature: A parameter to control the curvature. Higher values create a sharper bend.
/// - Returns: The transformed output in the range [0, 1].
func bentSigmoid<Value>(
    _ value: Value,
    curvature: Value = 7.5
) -> Value where Value: BinaryFloatingPoint {
    guard curvature != 0 else { return value }
    guard value >= -1, value <= 1 else { return value }

    return value >= 0
        ? Value(1 / (1 + exp(Double(-curvature * (value - 0.5)))))
        : -bentSigmoid(-value)
}
