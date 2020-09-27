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

enum FlipState: Int {
    case
         waiting,
         flipping,
         wobbling
}


class Sprite
{
    private let size: Vector2
    private let flipSpeed: Double

    var glyphId: Int
    var pos: Vector2
    var corners: (Vector2, Vector2, Vector2, Vector2)

    private var stretchFactor: Float

    private var flipState: FlipState
    private var flipStart: Double
    private var newGlyphId: Int
    
    public var didChange: Bool
    
    init(glyphId: Int, position: Vector2, size: Vector2)
    {
        self.size = size
        self.flipSpeed = 2 + Util.randomDouble()

        self.glyphId = glyphId
        self.pos = position

        self.corners = (Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0))
        self.stretchFactor = 0.5

        self.flipState = .flipping
        self.flipStart = 0
        self.newGlyphId = 0
        
        self.didChange = false

        updateCorners()
    }
    
    func flip(to glyphId: Int, at start: Double) {
        newGlyphId = glyphId
        flipStart = start
        flipState = .flipping
    }

    func animate(t now: Double) {
        
        switch flipState {
        case .flipping:
            didChange = true
            let d = Float((now - flipStart) * flipSpeed)
            if d < 1 {
                let oldFactor = stretchFactor
                stretchFactor = d - 0.5
                if oldFactor < 0 && stretchFactor > 0 {
                    glyphId = newGlyphId
                }
                updateCorners()
            } else {
                stretchFactor = 0.5
                flipState = .wobbling // TODO: skip wobbling below a certain size
                updateCorners()
            }
        case .wobbling:
            didChange = true
            // d = 0 for a value of now that makes d = 1 in .flipping
            let d = Float((now - flipStart - 1/flipSpeed) * (flipSpeed/2))
            stretchFactor = 0.5 - abs( 0.05 * exp(-d) * sin(5*d) )
            if d > Float.pi {
                flipState = .waiting
                stretchFactor = 0.5
            }
            updateCorners()
        case .waiting:
            didChange = false
            break
        }
        
    }

    private func updateCorners() {
        
        
        let s = size * Vector2(stretchFactor, 0.5)
        corners = (
            pos + s * Vector2(+1, +1),
            pos + s * Vector2(+1, -1),
            pos + s * Vector2(-1, -1),
            pos + s * Vector2(-1, +1)
        )
    }
    
}
