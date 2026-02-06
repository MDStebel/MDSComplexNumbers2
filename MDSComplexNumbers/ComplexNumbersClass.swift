//
//  ComplexNumbers.swift
//  MDSComplexNumbers
//
//  Created by Michael Stebel on 5/17/18.
//  Updated by Michael on 2/5/2026.
//
//  Notes:
//  - Fixes description sign bug for imaginary values in (-1, 0).
//  - Uses hypot() for stable magnitude.
//  - Removes redundant global == (synthesized Equatable).
//  - Makes ComplexRect consistent by deriving corners (immutable by default).
//  - Provides optional mutable rect variant when mutation is required.
//

import Foundation

// MARK: - Complex

public struct Complex: Equatable, Hashable, CustomStringConvertible, Sendable {

    public var real: Double
    public var imaginary: Double

    @inlinable
    public init() {
        self.real = 0
        self.imaginary = 0
    }

    @inlinable
    public init(_ real: Double, _ imaginary: Double) {
        self.real = real
        self.imaginary = imaginary
    }

    // Common constants
    public static let zero = Complex(0, 0)
    public static let i    = Complex(0, 1)

    // Magnitude / modulus
    @inlinable public var modulusSquared: Double { real * real + imaginary * imaginary }

    /// Stable magnitude (avoids overflow/underflow better than sqrt(x*x + y*y))
    @inlinable public var modulus: Double { hypot(real, imaginary) }

    @inlinable public var magnitude: Double { modulus }

    // Convenience
    @inlinable public var conjugate: Complex { Complex(real, -imaginary) }

    @inlinable public func squared() -> Complex { self * self }

    // MARK: CustomStringConvertible

    /// Human-readable form with 2 decimals and a calligraphic i.
    /// Examples:
    ///  - 2.00
    ///  - 𝒊
    ///  - -𝒊
    ///  - 2.00 + 𝒊
    ///  - 2.00 - 0.50𝒊   ✅ correct sign for (-1, 0)
    public var description: String {
        let r = String(format: "%.2f", real)
        let magI = String(format: "%.2f", Swift.abs(imaginary))

        // Purely real
        if imaginary == 0 { return r }

        // Purely imaginary
        if real == 0 {
            switch imaginary {
            case 1:  return "𝒊"
            case -1: return "-𝒊"
            default:
                return imaginary < 0 ? "-\(magI)𝒊" : "\(magI)𝒊"
            }
        }

        // General case
        switch imaginary {
        case 1:
            return "\(r) + 𝒊"
        case -1:
            return "\(r) - 𝒊"
        default:
            return imaginary < 0 ? "\(r) - \(magI)𝒊" : "\(r) + \(magI)𝒊"
        }
    }
}

// MARK: - Operators (Complex)

public extension Complex {

    // Addition / subtraction
    @inlinable static func + (lhs: Complex, rhs: Complex) -> Complex {
        Complex(lhs.real + rhs.real, lhs.imaginary + rhs.imaginary)
    }

    @inlinable static func - (lhs: Complex, rhs: Complex) -> Complex {
        Complex(lhs.real - rhs.real, lhs.imaginary - rhs.imaginary)
    }

    @inlinable static prefix func - (z: Complex) -> Complex {
        Complex(-z.real, -z.imaginary)
    }

    // Multiplication
    @inlinable static func * (lhs: Complex, rhs: Complex) -> Complex {
        // (a+bi)(c+di) = (ac - bd) + (ad + bc)i
        Complex(
            lhs.real * rhs.real - lhs.imaginary * rhs.imaginary,
            lhs.real * rhs.imaginary + rhs.real * lhs.imaginary
        )
    }

    // Division
    @inlinable static func / (lhs: Complex, rhs: Complex) -> Complex {
        let denom = rhs.real * rhs.real + rhs.imaginary * rhs.imaginary
        precondition(denom != 0, "Division by zero complex number")
        return Complex(
            (lhs.real * rhs.real + lhs.imaginary * rhs.imaginary) / denom,
            (lhs.imaginary * rhs.real - lhs.real * rhs.imaginary) / denom
        )
    }

    // Mixed with Double (left-sided only; add right-sided if you want symmetry)
    @inlinable static func + (lhs: Double, rhs: Complex) -> Complex {
        Complex(lhs + rhs.real, rhs.imaginary)
    }

    @inlinable static func - (lhs: Double, rhs: Complex) -> Complex {
        Complex(lhs - rhs.real, -rhs.imaginary)
    }

    @inlinable static func * (lhs: Double, rhs: Complex) -> Complex {
        Complex(lhs * rhs.real, lhs * rhs.imaginary)
    }

    @inlinable static func / (lhs: Double, rhs: Complex) -> Complex {
        // lhs / (a+bi) = lhs*(a-bi)/(a^2+b^2)
        let denom = rhs.real * rhs.real + rhs.imaginary * rhs.imaginary
        precondition(denom != 0, "Division by zero complex number")
        return Complex((lhs * rhs.real) / denom, (-lhs * rhs.imaginary) / denom)
    }
}

// MARK: - Free functions (for compatibility with your my old call sites)

@inlinable public func abs(_ z: Complex) -> Double { z.modulus }
@inlinable public func modulusSquared(_ z: Complex) -> Double { z.modulusSquared }
@inlinable public func modulus(_ z: Complex) -> Double { z.modulus }
@inlinable public func sqr(_ z: Complex) -> Complex { z.squared() }

// MARK: - ComplexRect (immutable, always consistent)

public struct ComplexRect: Equatable, Hashable, CustomStringConvertible, Sendable {

    public let topLeft: Complex
    public let bottomRight: Complex

    /// Derived corners (always consistent)
    @inlinable public var bottomLeft: Complex { Complex(topLeft.real, bottomRight.imaginary) }
    @inlinable public var topRight: Complex { Complex(bottomRight.real, topLeft.imaginary) }

    /// Create a rectangle from any two complex points; corners are normalized so that:
    /// - topLeft has min real, max imaginary
    /// - bottomRight has max real, min imaginary
    @inlinable
    public init(_ c1: Complex, _ c2: Complex) {
        let tlr = min(c1.real, c2.real)
        let tli = max(c1.imaginary, c2.imaginary)
        let brr = max(c1.real, c2.real)
        let bri = min(c1.imaginary, c2.imaginary)

        self.topLeft = Complex(tlr, tli)
        self.bottomRight = Complex(brr, bri)
    }

    @inlinable public var width: Double { bottomRight.real - topLeft.real }
    @inlinable public var height: Double { topLeft.imaginary - bottomRight.imaginary }

    public var description: String {
        "tl:\(topLeft), br:\(bottomRight), bl:\(bottomLeft), tr:\(topRight)"
    }
}

// MARK: - Optional: Mutable rect variant (if we really need to mutate the corners)

public struct MutableComplexRect: Equatable, Hashable, CustomStringConvertible, Sendable {

    public var topLeft: Complex { didSet { normalize() } }
    public var bottomRight: Complex { didSet { normalize() } }

    @inlinable public var bottomLeft: Complex { Complex(topLeft.real, bottomRight.imaginary) }
    @inlinable public var topRight: Complex { Complex(bottomRight.real, topLeft.imaginary) }

    @inlinable
    public init(_ c1: Complex, _ c2: Complex) {
        self.topLeft = c1
        self.bottomRight = c2
        normalize()
    }

    @inlinable
    mutating func normalize() {
        let tlr = min(topLeft.real, bottomRight.real)
        let tli = max(topLeft.imaginary, bottomRight.imaginary)
        let brr = max(topLeft.real, bottomRight.real)
        let bri = min(topLeft.imaginary, bottomRight.imaginary)
        topLeft = Complex(tlr, tli)
        bottomRight = Complex(brr, bri)
    }

    @inlinable public var width: Double { bottomRight.real - topLeft.real }
    @inlinable public var height: Double { topLeft.imaginary - bottomRight.imaginary }

    public var description: String {
        "tl:\(topLeft), br:\(bottomRight), bl:\(bottomLeft), tr:\(topRight)"
    }
}
