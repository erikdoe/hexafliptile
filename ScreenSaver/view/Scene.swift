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


public class Scene {

    var sprites: [Sprite] = []

    func makeSprites(glyphs: [Glyph], size: Double) {
        // all glyphs have the same ratio
        let aspectRatio = Double(glyphs[0].aspectRatio)
        self.makeHexagonTiling(glyphs: glyphs, width: size, height: size/aspectRatio)
        NSLog("Scene contains \(sprites.count) sprites")
    }

    private func makeHexagonTiling(glyphs: [Glyph], width: Double, height: Double) {
        let xstep = 1.5 * width
        let ystep = sqrt(0.1875) * width
        sprites = []
        for yi in 1..<Int(1 / ystep) {
            let y = Double(yi) * ystep
            let p = Util.gaussian(y * 4, mean: 4 / 2, variance: 0.11) // TODO: config?
            for xi in 0..<Int(1 / xstep) + 2 {
                if Util.randomDouble() < p {
                    let x = (Double(xi) + Double(yi % 2)/2) * xstep
                    let sprite = Sprite(glyphId: Util.randomInt(glyphs.count),
                                        position: Vector2(Float(x), Float(y)),
                                        size: NSMakeSize(CGFloat(width), CGFloat(height)))
                    sprites.append(sprite)
                }
            }
        }
    }

    func animate(t now: Double) {
        let speed = 2.0 // TODO: config?
        let interval = 4.0 // TODO: config?
        let flipPos = speed * (now.remainder(dividingBy:interval) + interval/2)
        // using a plain loop for performance reasons
        for i in 0..<sprites.count {
            let s = sprites[i]
            let d = Float(flipPos) - s.pos.x + s.pos.y/2
            if (d > 0 && d < 0.5) {
                s.flip(to: Util.randomInt(Configuration.sharedInstance.colors.count))
            }
            s.animate(t: now)
        }
    }

}
