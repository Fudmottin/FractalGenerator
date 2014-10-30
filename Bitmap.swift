//
//  Bitmap.swift
//  FractalGenerator
//
//  A bitmap class to manage pixel level drawing using CGImage

import Foundation
import QuartzCore

struct Color {
    var red: Byte
    var green: Byte
    var blue: Byte
    var alpha: Byte
}

final class Bitmap {
    var width: Int
    var height: Int
    var bytesPerRow: Int
    var data = [Byte]()

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        bytesPerRow = width * 4
        data = [Byte](count: Int(width * height * 4), repeatedValue: 255)
    }

    func createBitmapContext () -> CGContext! {
        return CGBitmapContextCreateWithData(UnsafeMutablePointer<Void>(data),
            UInt(width),
            UInt(height),
            8,
            UInt(4 * width),
            CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB),
            CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue),
            nil, nil)
    }

    func drawRow(rowNumber: Int, rowData: [Byte]) {
        var index = rowNumber * bytesPerRow
        for b in rowData {
            data[index++] = b
        }
    }

    func drawPixel(x: Int, y: Int, c: Color) {
        let offset = y * bytesPerRow + x * 4
        data[offset] = c.red
        data[offset + 1] = c.green
        data[offset + 2] = c.blue
        data[offset + 3] = c.alpha
    }

    func readPixel(x: Int, y: Int) -> Color {
        let offset = y * bytesPerRow + x * 4
        return Color(red: data[offset], green: data[offset + 1],
            blue: data[offset + 2], alpha: data[offset + 3])

    }

    func createImage() -> CGImage! {
        return CGBitmapContextCreateImage(createBitmapContext())
    }

    func saveImage(path: String) {
        let image = createImage()
        let options: [String:AnyObject] = [kCGImagePropertyOrientation : 1, // top left
            kCGImagePropertyHasAlpha : true,
            kCGImageDestinationLossyCompressionQuality : 1.0] // maximum quality
        let url = NSURL.fileURLWithPath(path, isDirectory: false)
        let file = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil)
        CGImageDestinationAddImage(file, image, options)
        CGImageDestinationFinalize(file)
    }

}