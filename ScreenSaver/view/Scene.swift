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

    let dpos: [Position] = [Position(+1, -1), Position(0, -1), Position(-1, 0),
                            Position(-1, +1), Position(0, +1), Position(+1, 0)]

    var width: Float = 0
    var nr: Int = 0
    var nq: Int = 0
    var sprites: [Sprite] = []
    var sindex: [[Int]] = [[]]

    var lastFlip: Double = 0
    var color: Int = 0
    var pos: Position = Position(0, 0)
    var dir: Int = 0
    var steps: Int = 0
    
    init() {
        restart()
    }
    
    private func setIndex(_ idx: Int, q: Int, r: Int) {
        sindex[q][r + nr] = idx
    }
    
    private func getIndex(position p: Position) -> Int {
        sindex[p.q][p.r + nr]
    }

    private func firstRow(_ q: Int) -> Int {
        -q/2
    }

    private func isValid(position: Position) -> Bool {
        pos.q >= 0 && pos.q < nq && pos.r >= firstRow(pos.q)  && pos.r < firstRow(pos.q) + nr
    }
    
    private func randomPosition() -> Position {
        let q = Util.randomInt(nq)
        let r = Util.randomInt(nr) + firstRow(q)
        return Position(q, r)
    }

    private func hexToPixel(_ hex: Position) -> Vector2 {
        let m = Matrix2x2(3/2, 0, sqrt(3)/2, sqrt(3))
        return m * hex.asVector2() * width
    }
    

    func makeSprites(glyphs: [Glyph], glyphSize: Vector2, outputSize: Vector2) {
        width = glyphSize.x / 2
        self.makeHexagonTiling(glyphs: glyphs, glyphSize: glyphSize, outputSize: outputSize)
        NSLog("Scene contains \(sprites.count) sprites")
    }

    private func makeHexagonTiling(glyphs: [Glyph], glyphSize: Vector2, outputSize: Vector2) {
        
        // using axial coordinates; see https://www.redblobgames.com/grids/hexagons/

        nq = Int(round(outputSize.x / (0.75 * glyphSize.x))) + 1
        nr = Int(round(outputSize.y / glyphSize.y)) + 2
        sindex = Array(repeating: Array(repeating: -1, count: nr*2+1), count:nq+1)

        sprites = []

        for q in 0..<nq {
            for r in (firstRow(q))..<(nr+firstRow(q)) {
                let p = hexToPixel(Position(q, r))
                let sprite = Sprite(glyphId: Util.randomInt(glyphs.count), position: p, size: glyphSize)
                setIndex(sprites.count, q: q, r: r)
                sprites.append(sprite)
            }
        }
    }
    
    func restart() {
        color = Util.randomInt(Configuration.sharedInstance.colors.count)
        pos = randomPosition()
        dir = Util.randomInt(dpos.count)
        steps = Util.randomInt(3) + 3
    }
    
    func turn () {
        dir = (dir + (Util.randomInt(2) * 2 - 1) + 6) % 6
        steps = Util.randomInt(3) + 2
    }
    
    
    func animate(t now: Double) {
        let speed = 1.0/60.0 * 5 // TODO: make dependent on size 1..10
        if now - lastFlip > speed {
//            NSLog("( \(pos.q), \(pos.r) ), firstRow = \(firstRow(pos.q))")

            let s = sprites[getIndex(position: pos)]
            s.flip(to: color, at: now)

            pos = pos + dpos[dir]
            if !isValid(position: pos) {
                restart()
            }

            steps -= 1
            if steps == 0 {
                turn()
            }
            
            lastFlip = now
        }
        // using a plain loop for performance reasons
        let num = sprites.count
        var idx = 0
        while (idx < num) {
            let s = sprites[idx]
            s.animate(t: now)
            idx += 1
        }

    }
    
    
    func animate_wave(t now: Double) {
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



public struct Position
{
    public var q: Int
    public var r: Int
}

extension Position
{
    public init(_ q: Int, _ r: Int) {
        self.init(q: q, r: r)
    }

    public static func +(lhs: Position, rhs: Position) -> Position {
        Position(lhs.q + rhs.q, lhs.r + rhs.r)
    }

    public func asVector2() -> Vector2 {
        Vector2(Float(self.q), Float(self.r))
    }
}
