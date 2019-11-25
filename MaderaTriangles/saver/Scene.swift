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


enum ScaleMode: Int {
    case        // the scene is rendered as a square
         fit,   // - scale so that the square fits in the screen rectangle
         fill   // - scale so that the square fills the entire screen rectangle
}

public class Scene {

    var sprites: [Sprite] = []

    var scaleMode: ScaleMode {
        get {
            .fill
        }
    }

    func makeSprites(glyphs: [Glyph], height: Double) -> [Sprite] {
        // all glyphs have the same ratio, sqrt(0.75) in fact
        let aspectRatio = glyphs[0].aspectRatio;
        let size = NSMakeSize(CGFloat(height) * aspectRatio, CGFloat(height))
        let xstep = height * Double(aspectRatio)
        let ystep = height

        var list: [Sprite] = []
        for yi in 0..<Int(1 / ystep) * 2 {
            let yp = Double(yi / 2) * ystep
            let p = Util.gaussian(yp * 4, mean: 4 / 2, variance: 0.11)
            for xi in 0..<Int(1 / xstep) + 2 {
                if Util.randomDouble() < p {
                    let xp = (Double(xi) + (((yi + 1) % 4) > 1 ? 0.5 : 0.0)) * xstep
                    let pos = Vector2(Float(xp), Float(yp))
                    let rot = Float(yi % 2) * Float.pi
                    list.append(Sprite(glyphId: Util.randomInt(glyphs.count), anchor: pos, size: size, rotation: rot))
                }
            }
        }
        sprites = list
        NSLog("Scene contains \(sprites.count) sprites")
        return list
    }

    func moveSprites(to now: Double) {
        for i in 0..<sprites.count { // using a plain loop for performance reasons
            Scene.move(sprite: sprites[i], to: now)
        }
    }

    static func move(sprite s: Sprite, to now: Double) {
        let a = floor(s.pos.x * 10)
        let b = floor(Float(now.remainder(dividingBy: 10)) + 5)
        if a != b {
            return
        }

        let newRotation = CGFloat((2 * now).remainder(dividingBy: 1))
        if (newRotation.sign != s.zRotation.sign) && (newRotation < 0.1) && (newRotation > -0.1) {
            s.glyphId = Util.randomInt(6)
        }
        s.zRotation = newRotation
    }

}
