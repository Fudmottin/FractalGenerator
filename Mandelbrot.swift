//
//  Mandelbrot.swift
//  FractalGenerator

import Foundation

struct Complex {
    var r = 0.0, i = 0.0
    static var TOLERANCE = 0.00000005
}


func + (left: Complex, right: Complex) -> Complex {
    return Complex(r: left.r + right.r, i: right.i + left.i)
}

func * (left: Complex, right: Complex) -> Complex {
    let r2 = left.r * right.r
    let i2 = left.i * right.i
    return Complex(r: r2 - i2, i: 2.0 * left.r * right.i)
}

func > (left: Complex, right: Double) -> Bool {
    // to avoid square root operator, we will square the right arg.
    let amplitude = right * right
    let sum = left.r * left.r + left.i * left.i
    return sum > amplitude
}

func == (left: Complex, right: Complex) -> Bool {
    let r = abs(left.r - right.r)
    let i = abs(left.i - right.i)
    let e = r + i
    return e < Complex.TOLERANCE
}

final class Mandelbrot {
    let iterations: Int
    let pixelWidth: Int
    let pixelHeight: Int
    let mapWidth: Double
    let mapHeight: Double
    let centerReal: Double
    let centerImaginary: Double
    let colorMultiplier: Double
    let rArray: [Double]
    let iArray: [Double]

    init(width: Int, height: Int, zoom: Double, centerX: Double, centerY: Double, iterations: Int) {
        pixelWidth = width
        pixelHeight = height
        self.iterations = iterations
        mapWidth = (3.0 / zoom) * (Double(pixelWidth) / Double(pixelHeight))
        mapHeight = 3.0 / zoom
        centerReal = Double(mapWidth) / 2.0 + centerX
        centerImaginary = Double(mapHeight) / 2.0 + centerY
        colorMultiplier = 255.0 / log(Double(iterations * 4))

        rArray = [Double](count: pixelWidth, repeatedValue: 0.0)
        iArray = [Double](count: pixelHeight, repeatedValue: 0.0)

        for i in 0 ..< pixelWidth {
            rArray[i] = Double(i) * mapWidth / Double(pixelWidth) - centerReal
        }
        for i in 0 ..< pixelHeight {
            iArray[i] = Double(i) * mapHeight / Double(pixelHeight) - centerImaginary
        }
        Complex.TOLERANCE = (rArray[1] - rArray[0]) / 10.0
   }

    func computePixel(x: Int, y: Int, cycleTest: Bool) -> (isInSet: Bool, iterations: Int) {
        let c = Complex(r: rArray[x], i: iArray[y])
        var z = c

        if cycleTest {
            var previousZ = Complex(r: 8.0, i: 8.0)
            var period = 1
            var check = 3

            for iter in 1 ... iterations {
                if z > 2.0 {
                    return (false, iter)
                }
                if z == previousZ {
                    return (true, iterations)
                }
                period++
                if period > check {
                    check = check * 2
                    period = 1
                    previousZ = z
                }
                z = z * z + c // This is the Mandelbrot Function!
            }
        } else {
            for iter in 1 ... iterations {
                if z > 2.0 {
                    return (false, iter)
                }
                z = z * z + c // This is the Mandelbrot Function!
            }
        }

        return (true, iterations)
    }

    // This would be a good method to delegate for custom color maps
    func mapToColor(i: Int) -> Color {
        let m = min(colorMultiplier * log(Double(i * 4)), 255)
        let color = Color(red: 192, green: Byte(m), blue: Byte(max(127 - Int(m), 0)), alpha: 255)
        return color
    }
}
