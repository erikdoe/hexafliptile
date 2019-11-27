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

    let scaleMode: ScaleMode = .fill
    var sprites: [Sprite] = []

    func makeSprites(glyphs: [Glyph], height: Double) {
        // all glyphs have the same ratio, sqrt(0.75) in fact
        let aspectRatio = glyphs[0].aspectRatio;
        let width = height * Double(aspectRatio)

        sprites = []
        for yi in 1..<Int(1 / height) * 2 {
            let y = Double(yi / 2) * height
            let p = Util.gaussian(y * 4, mean: 4 / 2, variance: 0.11) // TODO: config?
            for xi in 0..<Int(1 / width) + 2 {
                if Util.randomDouble() < p {
                    let x = (Double(xi) + Double(((yi + 1) % 4) / 2) * 0.5) * width
                    let sprite = Sprite(glyphId: Util.randomInt(glyphs.count),
                                        position: Vector2(Float(x), Float(y)),
                                        size: NSMakeSize(CGFloat(width), CGFloat(height)),
                                        rotation: Float(yi % 2) * Float.pi)
                    sprites.append(sprite)
                }
            }
        }
        NSLog("Scene contains \(sprites.count) sprites")
    }

    func moveSprites(to now: Double) {
        // using a plain loop for performance reasons
        for i in 0..<sprites.count {
            Scene.move(sprite: sprites[i], to: now)
        }
    }

    static func move(sprite s: Sprite, to now: Double) {
        let t = (now/2).remainder(dividingBy: 1) + 0.5
        let p = (Double(s.pos.x) + Double(s.pos.y) / 3).remainder(dividingBy: 1) + 0.5
        let d = t-p
        if d > 0 && d < 0.5 {
            s.zRotation = Float((0.5 - d) * 2 * Double.pi)
        } else {
            s.zRotation = 0
        }

//        let newRotation = CGFloat((2 * now).remainder(dividingBy: 1))
//        if (newRotation.sign != s.zRotation.sign) && (newRotation < 0.1) && (newRotation > -0.1) {
//            s.glyphId = Util.randomInt(6)
//        }
//        s.zRotation = newRotation
    }

}
