//
//  main.swift
//  FractalGenerator
//  let mandelbrot = Mandelbrot(width: width, height: height, zoom: 1.0, centerX: 0.0, centerY: 0.0, iterations: 1000)
//  let mandelbrot = Mandelbrot(width: width, height: height, zoom: zoom, centerX: 0.74552972800463340, centerY: 0.08245763776447299, iterations: iterations)

import Foundation

func computeFractal(width: Int, height: Int, iterations: Int, zoom: Double, centerX: Double, centerY: Double) -> Bitmap {
    let bitmap = Bitmap(width: width, height: height)
    let mandelbrot = Mandelbrot(width: width, height: height, zoom: zoom, centerX: centerX, centerY: centerY, iterations: iterations)

    for y in 0 ..< height {
        threads.runOnComputationThread() {
            var row = [Byte](count: width * 4, repeatedValue: 255)
            var index = 0
            var doCycleTesting = false

            for x in 0 ..< width {
                let (isInSet, iterations) = mandelbrot.computePixel(x, y: y, cycleTest: doCycleTesting)
                var color: Color
                if isInSet {
                    color = Color(red: 0, green: 0, blue: 0, alpha: 255)
                    doCycleTesting = true
                } else {
                    doCycleTesting = false
                    color = mandelbrot.mapToColor(iterations)
                }
                row[index++] = color.red
                row[index++] = color.green
                row[index++] = color.blue
                row[index++] = color.alpha
            }
            threads.runOnSerialThread() {
                bitmap.drawRow(y, rowData: row)
            }
        }
    }

    threads.waitAll()
    return bitmap
}

func main() {
    let width = 1280
    let height = 720
    let centerX = 0.74552972800463340
    let centerY = 0.08245763776447299
    let images = 10
    let maxZoom = 1000.0
    let zoomFactor = exp(log(maxZoom) / Double(images))

    var zoom = 1.0
    var iterations = 1000
    for i in 1...images {
        let formatedNumber = String(format: "%0.6d", i)
        println("Working on image: \(i) with zoom: \(zoom) and iterations: \(iterations)")
        var bitmap = computeFractal(width, height, iterations, zoom, centerX, centerY)
        bitmap.saveImage("/Users/David/Desktop/MSet/images/aFractal\(formatedNumber).png")
        zoom *= zoomFactor
        iterations = Int(Double(iterations) * (zoomFactor + 1.0) / 2.0)
    }

    println("Done!")

    exit(0)
}

threads.runOnMainThread(main)
threads.run()
