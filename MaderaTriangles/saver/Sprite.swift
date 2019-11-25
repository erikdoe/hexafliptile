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
    let r0: Double

    var glyphId: Int
    var pos: Vector2
    var rotation: Float
    var zRotation: CGFloat

    init(glyphId: Int, anchor: Vector2, size: NSSize, rotation: Float)
    {
        self.glyphId = glyphId
        self.size = size
        self.r0 = Util.randomDouble()

        self.pos = anchor
        self.rotation = rotation
        self.zRotation = 0
    }

    var corners: (Vector2, Vector2, Vector2, Vector2)
    {
        get
        {
            let rotationMatrix = Matrix2x2(rotation: rotation)

            let a = (pos + Vector2(Float(size.width * zRotation), Float(+size.height/2)) * rotationMatrix)
            let b = (pos + Vector2(Float(size.width * zRotation), Float(-size.height/2)) * rotationMatrix)
            let c = (pos + Vector2(Float(-size.width * zRotation), Float(-size.height/2)) * rotationMatrix)
            let d = (pos + Vector2(Float(-size.width * zRotation), Float(+size.height/2)) * rotationMatrix)

            return (a, b, c, d)
        }
    }


}
