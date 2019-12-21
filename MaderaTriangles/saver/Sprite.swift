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

enum FlipState: Int {
    case
         starting,
         flipping,
         wobbling,
         finished
}


class Sprite
{
    let size: NSSize
    var flipSpeed: Double

    var glyphId: Int
    var pos: Vector2
    var rotation: Float
    var stretchFactor: CGFloat
    var flipState: FlipState
    var flipStart: Double
    
    init(glyphId: Int, position: Vector2, size: NSSize, rotation: Float)
    {
        self.size = size
        self.flipSpeed = 1 / (Util.randomDouble() + 2)

        self.glyphId = glyphId
        self.pos = position
        self.rotation = rotation

        self.stretchFactor = -0.5
        self.flipState = .finished
        self.flipStart = 0
    }

    var corners: (Vector2, Vector2, Vector2, Vector2)
    {
        get
        {
            let rotationMatrix = Matrix2x2(rotation: rotation)

            let a = pos + Vector2(Float(+size.width * stretchFactor), Float(+size.height * 0.5)) * rotationMatrix
            let b = pos + Vector2(Float(+size.width * stretchFactor), Float(-size.height * 0.5)) * rotationMatrix
            let c = pos + Vector2(Float(-size.width * stretchFactor), Float(-size.height * 0.5)) * rotationMatrix
            let d = pos + Vector2(Float(-size.width * stretchFactor), Float(+size.height * 0.5)) * rotationMatrix

            return (a, b, c, d)
        }
    }
    
    func flip() {
        flipState = .starting
    }

    func move(to now: Double) {

        switch flipState {
        case .starting:
            if Util.randomDouble() < 0.2 {
                flipStart = now
                flipState = .flipping
            }
        case .flipping:
            let d = (now - flipStart) / flipSpeed
            if d < 1 {
                let oldFactor = stretchFactor
                stretchFactor = CGFloat(d - 0.5)
                if oldFactor < 0 && stretchFactor > 0 {
                    glyphId = Util.randomInt(5) // TODO: this needs to be glyphs.count
                }
            } else {
                flipState = .wobbling
            }
        case .wobbling:
            let d = now - flipStart - flipSpeed
            let f = CGFloat( 0.02 * (2.82 - log(5*d+1)) * sin(10*d) )
            stretchFactor = 0.5 - abs(f)
            if d > Double.pi {
                flipState = .finished
            }
        case .finished:
            stretchFactor = 0.5
        }
        
    }
    
}
