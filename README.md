# MDSComplexNumbers

A lightweight Swift framework providing **complex number support** with clean syntax, stable math functions, and a Swift-friendly API. Designed for numerical work, graphics, and fractal math on iOS, iPadOS, and macOS.

## Features

- `Complex` type with full arithmetic support
- Stable magnitude computation using `hypot`
- Human-readable formatting (`2.00 - 0.50𝒊`, `𝒊`, `-𝒊`)
- Mixed `Double` + `Complex` arithmetic
- Immutable and consistent complex rectangles (`ComplexRect`)
- Fully `@inlinable` for performance-critical code
- `Sendable`, `Equatable`, and `Hashable` support

---

## Installation

Add `MDSComplexNumbers.framework` to your Xcode project binaries, then import the module where needed:

```swift
import MDSComplexNumbers
```

---

## Functions & Examples

### Initialize / Create a Complex Number

```swift
var z = Complex()                 // 0.00
var w = Complex(2.5, -4.5)        // 2.50 - 4.50𝒊

z = Complex(1.1, 0.9)             // 1.10 + 0.90𝒊

var u = Complex(0, -1)            // -𝒊
u = Complex(0, 1)                 // 𝒊
```

---

### Complex Arithmetic

```swift
let sum = z + w                   // 3.60 - 3.60𝒊
let product = z * w               // 6.80 - 2.70𝒊
let squared = sqr(z)              // 0.40 + 1.98𝒊

print(z - w)                      // -1.40 + 5.40𝒊

let quotient = z / w              // 0.05 + 0.27𝒊

let areEqual = (z == w)           // false
let notEqual = (z != w)           // true
```

---

### Magnitude / Modulus

```swift
let m1 = modulus(z)               // 1.42126704035519
let m2 = z.magnitude              // same as modulus(z)
let m3 = z.modulusSquared         // avoids sqrt
```

Magnitude uses `hypot(real, imaginary)` for improved numerical stability.

---

### Mixed Real and Complex Arithmetic

#### `Double` as the Left Operand

```swift
let aDouble = Double.pi

print(aDouble * w)                // 7.85 - 14.14𝒊
print(aDouble + z)                // 4.24 + 0.90𝒊
print(aDouble - w)                // 0.64 + 4.50𝒊
```

---

## ComplexRect

`ComplexRect` represents a rectangular region in the complex plane.  
Corners are always normalized and internally consistent.

```swift
let r = ComplexRect(
    Complex(-2.0, 1.0),
    Complex(1.0, -1.0)
)

r.topLeft        // -2.00 + 1.00𝒊
r.bottomRight    // 1.00 - 1.00𝒊
r.bottomLeft     // -2.00 - 1.00𝒊
r.topRight       // 1.00 + 1.00𝒊

r.width          // 3.0
r.height         // 2.0
```

An optional `MutableComplexRect` is also included if mutation is required.

---

## Notes

- Division by `0 + 0𝒊` triggers a runtime precondition failure.
- Formatting is intended for **debugging and display**, not serialization.
- The API favors correctness, clarity, and performance over cleverness.

---

## License

© 2018-2026 Michael Stebel Consulting, LLC. All rights reserved.
