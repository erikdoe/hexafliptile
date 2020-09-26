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

    var grid: Float = 0
    var nr: Int = 0
    var nq: Int = 0
    var sprites: [Sprite] = []
    var sindex: [[Int]] = [[]]

    var dir: Vector2 = Vector2(1, 0)
    var pos: Vector2 = Vector2(0, 3)
    
    func makeSprites(glyphs: [Glyph], glyphSize: Vector2, outputSize: Vector2) {
        grid = glyphSize.x / 2
        self.makeHexagonTiling(glyphs: glyphs, glyphSize: glyphSize, outputSize: outputSize)
        NSLog("Scene contains \(sprites.count) sprites")
    }

    private func firstRow(_ column: Int) -> Int {
        (column) / 2
    }

    private func hexToPixel(hex: Vector2) -> Vector2 {
        let m = Matrix2x2(3/2, 0, sqrt(3)/2, sqrt(3))
        return m * hex * grid
    }

    private func makeHexagonTiling(glyphs: [Glyph], glyphSize: Vector2, outputSize: Vector2) {
        
        // using axial coordinates; see https://www.redblobgames.com/grids/hexagons/

        nq = Int(round(outputSize.x / (0.75 * glyphSize.x))) + 1
        nr = Int(round(outputSize.y / glyphSize.y)) + 2
        sindex = Array(repeating: Array(repeating: -1, count: nr*2+1), count:nq+1)

        sprites = []

        for q in 0..<nq {
            for r in (0-firstRow(q))..<(nr-firstRow(q)) {
                let p = hexToPixel(hex: Vector2(Float(q), Float(r)))
                let sprite = Sprite(glyphId: Util.randomInt(glyphs.count), position: p, size: glyphSize)
                sindex[q][r+nr+1] = sprites.count
                sprites.append(sprite)
            }
        }
    }
    
//    func animate_new(t now: Double) {
//
//        if (pos.x >= 0) && (Int(pos.x) < nq+1) && (pos.y >= 0) && (Int(pos.y) <  nr*2+1) {
//            let idx = sindex[Int(pos.x)][Int(pos.y) + nr]
//            if (idx > -1) {
//                sprites[idx].flip(to: Util.randomInt(Configuration.sharedInstance.colors.count), at: now)
//                pos = pos + dir
//
//                for s in sprites {
//                    s.animate(t: now)
//                }
//
//                return
//
//            }
//        }
//
//
//            let r = Util.randomInt(4);
//             if (r % 2 == 0) {
//                pos = Vector2(0, Util.randomDouble(nr))
//                if (r / 2 == 0) {
//                     dir = Vector2(1, 0)
//                 } else {
//                     dir = Vector2(1, -1)
//                 }
//             } else {
//                pos = Vector2(Double(nq-1), Util.randomDouble(nr) - Double(firstRow(nq)))
//                if (r / 2 == 0) {
//                     dir = Vector2(-1, 0)
//                 } else {
//                     dir = Vector2(-1, 1)
//                 }
//            }
//
//
//    }

    
    func animate(t now: Double) {
        let speed = 2.0 // TODO: config?
        let interval = 5.0 // TODO: config?
        let flipPos = Float(speed * (now.remainder(dividingBy:interval) + interval/2))
        // using a plain loop for performance reasons
        let num = sprites.count
        var idx = 0
        while (idx < num) {
            let s = sprites[idx]
            let d = flipPos - s.pos.x + s.pos.y/2
            if (d > 0 && d < 0.5) {
                s.flip(to: Util.randomInt(Configuration.sharedInstance.colors.count), at: now)
            }
            s.animate(t: now)
            idx += 1
        }
    }
    
}
