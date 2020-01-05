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
         starting,
         flipping,
         wobbling,
         finished
}


class Sprite
{
    private let size: NSSize
    private let flipSpeed: Double

    var glyphId: Int
    var pos: Vector2

    private var stretchFactor: CGFloat
    private var flipState: FlipState
    private var flipStart: Double
    private var newGlyphId: Int
    
    init(glyphId: Int, position: Vector2, size: NSSize)
    {
        self.size = size
        self.flipSpeed = Util.randomDouble() * 2 + 2

        self.glyphId = glyphId
        self.pos = position

        self.stretchFactor = -0.5
        self.flipState = .finished
        self.flipStart = 0
        self.newGlyphId = 0
    }

    var corners: (Vector2, Vector2, Vector2, Vector2)
    {
        get
        {
            let a = pos + Vector2(Float(+size.width * stretchFactor), Float(+size.height * 0.5))
            let b = pos + Vector2(Float(+size.width * stretchFactor), Float(-size.height * 0.5))
            let c = pos + Vector2(Float(-size.width * stretchFactor), Float(-size.height * 0.5))
            let d = pos + Vector2(Float(-size.width * stretchFactor), Float(+size.height * 0.5))

            return (a, b, c, d)
        }
    }
    
    func flip(to newGlyphId: Int) {
        if flipState == .finished {
            flipState = .starting
            self.newGlyphId = newGlyphId
        } 
    }

    func animate(t now: Double) {

        switch flipState {
        case .starting:
            if Util.randomDouble() < 0.2 { // TODO: config?
                flipStart = now
                flipState = .flipping
            }
        case .flipping:
            let d = (now - flipStart) * flipSpeed
            if d < 1 {
                let oldFactor = stretchFactor
                stretchFactor = CGFloat(d - 0.5)
                if oldFactor < 0 && stretchFactor > 0 {
                    glyphId = newGlyphId
                }
            } else {
                flipState = .wobbling
            }
        case .wobbling:
            // d = 0 for a value of now that makes d = 1 in .flipping
            let d = (now - flipStart - 1/flipSpeed) * (flipSpeed/2)
            stretchFactor = 0.5 - CGFloat(abs( 0.05 * exp(-d) * sin(5*d) ))
            if d > Double.pi {
                flipState = .finished
            }
        case .finished:
            stretchFactor = 0.5
        }
        
    }
    
}
