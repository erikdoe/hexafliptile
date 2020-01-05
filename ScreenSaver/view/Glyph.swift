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
        var allGlyphs: [Glyph] = []
        let triangle = Glyph.makeHexagonPath()
        for c in Configuration.sharedInstance.colors {
            allGlyphs.append(Glyph(path: triangle, color: c))
        }
        return allGlyphs
    }
    
    private static func makeHexagonPath() -> NSBezierPath {
        let h = CGFloat(sqrt(0.75)) // 0.5^2 + h^2 = 1^2
        let p = NSBezierPath();
        p.lineWidth = 2 // TODO: config?
        p.move(to: NSMakePoint(0.25, 0.00))
        p.line(to: NSMakePoint(0.75, 0.00))
        p.line(to: NSMakePoint(1.00, h/2))
        p.line(to: NSMakePoint(0.75, h))
        p.line(to: NSMakePoint(0.25, h))
        p.line(to: NSMakePoint(0.00, h/2))
        p.close()
        return p
    }
    
    
    init(path: NSBezierPath, color: NSColor)
    {
        self.path = path
        self.color = color
    }

    var aspectRatio: CGFloat
    {
        get { path.bounds.width / path.bounds.height }
    }

    func makeBitmap(size: CGFloat) -> NSBitmapImageRep
    {
        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size/aspectRatio), bitsPerSample: 8,
                                        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB,
                                        bytesPerRow: Int(size)*4, bitsPerPixel:32)!

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: imageRep)

        let shrinkFactor: CGFloat = 0.1 // TODO: config?
        let scaledPath = path.copy() as! NSBezierPath
        scaledPath.transform(using: AffineTransform(scaleByX: size * (1 - shrinkFactor), byY: size * (1 - shrinkFactor)))
        scaledPath.transform(using: AffineTransform(translationByX: size * shrinkFactor/2, byY: size * shrinkFactor/2))

        color.set()
        scaledPath.fill()
        color.lighter().set()
        scaledPath.stroke()

        NSGraphicsContext.restoreGraphicsState()
        
        return imageRep
    }

}
