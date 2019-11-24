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
        fit,    // scale so that the square fits in the screen rectangle
        fill    // scale so that the square fills the entire screen rectangle
}

public class Scene
{
    var scaleMode: ScaleMode
    {
        get
        {
            return .fill
        }
    }

    func makeSprites(_ numSprites: Int, glyphs: [Glyph], size maximumSize: Double) -> [Sprite]
    {
        let bands = 5;

        var list: [Sprite] = []
        let xstep = 1 / Double(numSprites) * Double(bands) + 0.0002
        let ystep = maximumSize * 1.1
        let ybase = (1 - ((Double(bands) - 1) * ystep)) / 2
        for i in 0..<numSprites {
            let pos = Vector2(Float(xstep * Double(i / bands)) - 0.0001, Float(ybase + ystep * Double(i % bands)))
            let size = Float(maximumSize)
            let sprite = Sprite(glyphId: Util.randomInt(glyphs.count), anchor: pos, size: size, animation: Scene.move)
            list.append(sprite)
        }
        return list
    }

    static func move(sprite s: Sprite, to now: Double)
    {
        s.rotation = Float(now * 0.6 + Double(s.pos.x) * 8 - Double(s.pos.y) * 4)
    }

}
