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

class Sprite
{
    let size: NSSize

    var glyphId: Int
    var pos: Vector2
    var rotation: Float
    var stretchFactor: CGFloat

    init(glyphId: Int, position: Vector2, size: NSSize, rotation: Float)
    {
        self.size = size

        self.glyphId = glyphId
        self.pos = position
        self.rotation = rotation
        self.stretchFactor = -0.5
    }
    
    var zRotation: Float
    {
        set(value)
        {
            let oldStretchFactor = stretchFactor
            stretchFactor = CGFloat(value / Float.pi) - 0.5
            if stretchFactor < 0 && oldStretchFactor > 0 {
                glyphId = Util.randomInt(6)
            }
        }
        get
        {
            0.0 // keep compiler happy
        }
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
    
    func move(to now: Double) {
        
    }
    
    func flip() {
        glyphId = Util.randomInt(6)
    }

}
