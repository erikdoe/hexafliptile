/*
 *  Copyright 2016-2020 Erik Doernenburg
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

    func makeSprites(glyphs: [Glyph], glyphSize: Vector2, outputSize: Vector2) {
        let outputHeight = outputSize.y / outputSize.x
        let xstep = 1.5 * glyphSize.x
        let ystep = glyphSize.y/2
        sprites = []
        for yi in 1..<Int(outputHeight / ystep) {
            let y = Double(yi) * ystep
            NSLog("y = \(y)")
            let p = Util.gaussian(y / outputHeight * 3, mean: 3 / 2, variance: 0.11) // TODO: config?
            for xi in 0..<Int(1 / xstep) + 2 {
                if Util.randomDouble() < p {
                    let x = (Double(xi) + Double(yi % 2)/2) * xstep
                    let sprite = Sprite(glyphId: Util.randomInt(glyphs.count),
                                        position: Vector2(x, y),
                                        size: Vector2(glyphSize.x, glyphSize.y))
                    sprites.append(sprite)
                }
            }
        }
        NSLog("Scene contains \(sprites.count) sprites")
    }

    func animate(t now: Double) {
        let speed = 2.0 // TODO: config?
        let interval = 5.0 // TODO: config?
        let flipPos = speed * (now.remainder(dividingBy:interval) + interval/2)
        // using a plain loop for performance reasons
        for i in 0..<sprites.count {
            let s = sprites[i]
            let d = flipPos - s.pos.x + s.pos.y/2
            if (d > 0 && d < 0.5) {
                s.flip(to: Util.randomInt(Configuration.sharedInstance.colors.count), at: now + pow(Util.randomDouble(), 40) / 3)
            }
            s.animate(t: now)
        }
    }

}
