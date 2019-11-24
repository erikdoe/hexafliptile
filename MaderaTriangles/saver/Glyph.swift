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
    private let color: NSColor

    class func makeAllGlyphs() -> [Glyph]
    {
        let colors = [
            NSColor(webcolor: "#c85c6c"),
            NSColor(webcolor: "#fe7567"),
            NSColor(webcolor: "#fcc96c"),
            NSColor(webcolor: "#548ecb"),
            NSColor(webcolor: "#315b8b")
        ]

        let p = NSBezierPath();
        p.move(to: NSMakePoint(0, 0))
        p.line(to: NSMakePoint(1, 0))
        p.line(to: NSMakePoint(0.5, CGFloat(sqrt(0.75)))) // 0.5^2 + h^2 = 1^2
        p.close()
        p.lineWidth = 3

        var allGlyphs: [Glyph] = []
        for c in colors {
//            p.normalize()
            allGlyphs.append(Glyph(path: p, color: c))
        }
        
        return allGlyphs
    }
    
    init(path: NSBezierPath, color: NSColor)
    {
        self.path = path
        self.color = color
    }

    func makeBitmap(size: NSSize) -> NSBitmapImageRep
    {
        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.calibratedRGB, bytesPerRow: Int(size.width)*4, bitsPerPixel:32)!

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: imageRep)

        let safety: CGFloat = 0.06
        let scaledPath = path.copy() as! NSBezierPath
        scaledPath.transform(using: AffineTransform(scaleByX: size.width * (1 - 2 * safety), byY: size.height * (1 - 2 * safety)))
        scaledPath.transform(using: AffineTransform(translationByX: size.width * safety, byY: size.height * safety))
        
        color.set()
        scaledPath.fill()

        Configuration.sharedInstance.outlineColor.set()
        scaledPath.stroke()

        NSGraphicsContext.restoreGraphicsState()
        
        return imageRep
    }

}
