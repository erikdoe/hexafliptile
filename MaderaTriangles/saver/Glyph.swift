/*
 *  Copyright 2016 Erik Doernenburg
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

import Cocoa

class Glyph
{
    private let path: NSBezierPath
    private let color: NSColor?

    class func makeAllGlyphs() -> [Glyph]
    {
        var allGlyphs: [Glyph] = []
        let triangle = Glyph.makeTrianglePath()
        for c in Configuration.sharedInstance.colors {
            allGlyphs.append(Glyph(path: triangle, color: c))
        }
        allGlyphs.append(Glyph(path: triangle, color: nil)) // TODO: config?
        return allGlyphs
    }
    
    private static func makeTrianglePath() -> NSBezierPath {
        let p = NSBezierPath();
        p.lineWidth = 4 // TODO: config?
        p.move(to: NSMakePoint(0, 0))
        p.line(to: NSMakePoint(1, 0))
        p.line(to: NSMakePoint(0.5, CGFloat(sqrt(0.75)))) // 0.5^2 + h^2 = 1^2
        p.close()
        return p
    }
    
    
    init(path: NSBezierPath, color: NSColor?)
    {
        self.path = path
        self.color = color
    }

    var aspectRatio: CGFloat
    {
        get { path.bounds.width / path.bounds.height }
    }

    func makeBitmap(size: NSSize) -> NSBitmapImageRep
    {
        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8,
                                        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB,
                                        bytesPerRow: Int(size.width)*4, bitsPerPixel:32)!

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: imageRep)

        let shrinkFactor: CGFloat = 0.16 // TODO: config?
        let scaledPath = path.copy() as! NSBezierPath
        // we must scale both dimensions with the same factor, otherwise the shape would get distorted
        scaledPath.transform(using: AffineTransform(scaleByX: size.width * (1 - shrinkFactor), byY: size.width * (1 - shrinkFactor)))
        scaledPath.transform(using: AffineTransform(translationByX: size.width * shrinkFactor/2, byY: size.width * shrinkFactor/2))
        // we're moving the triangle down by a tiny amount to account for different rendering of line at bottom and pointy angle at top
        scaledPath.transform(using: AffineTransform(translationByX: 0, byY: -0.04 * size.height))

        if let color = color {
            color.set()
            scaledPath.fill()
            color.lighter().set()
            scaledPath.stroke()
        }

//        var p = NSBezierPath()
//        p.move(to: NSMakePoint(0, 0))
//        p.line(to: NSMakePoint(0, 1))
//        p.line(to: NSMakePoint(1, 1))
//        p.close()
//        p.lineWidth = 5
//        p.transform(using: AffineTransform(scaleByX: size.width, byY: size.width))
//        NSColor.green.set()
//        p.stroke()
//
//        p = NSBezierPath()
//        p.move(to: NSMakePoint(0, 0))
//        p.line(to: NSMakePoint(1, 1))
//        p.line(to: NSMakePoint(1, 0))
//        p.close()
//        p.lineWidth = 3
//        p.transform(using: AffineTransform(scaleByX: size.width, byY: size.width))
//        NSColor.blue.set()
//        p.stroke()

        NSGraphicsContext.restoreGraphicsState()
        
        return imageRep
    }

}
