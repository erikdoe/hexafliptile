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

import ScreenSaver


@objc(HexafliptileView)
class HexafliptileView: MetalScreenSaverView
{    
    var glyphs: [Glyph]!
    var scene: Scene!

    var renderer: Renderer!
    var statistics: Statistics!


    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func resize(withOldSuperviewSize oldSuperviewSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSuperviewSize)
        updateSizeAndTextures(glyphSize: Configuration.sharedInstance.glyphSize)
    }


    // configuration

    override var hasConfigureSheet: Bool
    {
        return true
    }

    override var configureSheet: NSWindow?
    {
        let controller = ConfigureSheetController.sharedInstance
        controller.loadConfiguration()
        return controller.window
    }


    // start and stop
    
    override func startAnimation()
    {
        let configuration = Configuration.sharedInstance

        glyphs = Glyph.makeAllGlyphs()

        scene = Scene()
        updateSprites(glyphSize: configuration.glyphSize)

        renderer = Renderer(device: device, numTextures: glyphs.count, numQuads: scene.sprites.count)
        renderer.backgroundColor = configuration.backgroundColor.toMTLClearColor()
        updateSizeAndTextures(glyphSize: configuration.glyphSize)

        statistics = Statistics()

        super.startAnimation()
    }

    override func stopAnimation()
    {
        super.stopAnimation()

        renderer = nil
        scene = nil
        statistics = nil
    }


    private func updateSprites(glyphSize: Double) {
        let aspectRatio = Double(glyphs[0].aspectRatio)
        let divisor = max(bounds.size.width, bounds.size.height)
        scene.makeSprites(glyphs: glyphs,
                          glyphSize: Vector2(glyphSize, glyphSize/aspectRatio),
                          outputSize: Vector2(Double(bounds.size.width / divisor), Double(bounds.size.height / divisor)))
    }

    private func updateSizeAndTextures(glyphSize: Double)
    {
        let divisor = max(bounds.size.width, bounds.size.height)
        renderer.setOutputSize(NSMakeSize(bounds.size.width / divisor * 2, bounds.size.height / divisor * 2))
        let widthInPixel = floor(bounds.width) * CGFloat(glyphSize)
        let hidpiFactor = window!.backingScaleFactor

        for (i, g) in glyphs.enumerated() {
            let bitmap = g.makeBitmap(size: widthInPixel * hidpiFactor)
            renderer.setTexture(image: bitmap, at: i)
        }
    }

    
    // animation

    override func animateOneFrame()
    {
        scene.animate(t: outputTime)
        drawFrame()
//        DispatchQueue.main.async() {
//            self.needsDisplay = true
//        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        drawFrame()
    }

    private func drawFrame()
    {
        statistics.viewWillStartRenderingFrame()

        renderer.beginUpdatingQuads()
        let divisor = max(bounds.size.width, bounds.size.height)
        let offset = Vector2(Double(bounds.size.width / divisor / 2 ), Double(bounds.size.height / divisor / 2))
        for (idx, sprite) in scene.sprites.enumerated() {
            let (a, b, c, d) = sprite.corners
            renderer.updateQuad((a + offset, b + offset, c + offset, d + offset), textureId: sprite.glyphId, at:idx)
        }
        renderer.finishUpdatingQuads()

         let metalLayer = layer as! CAMetalLayer
         if let drawable = metalLayer.nextDrawable() { // TODO: can this really happen?
             renderer.renderFrame(drawable: drawable)
         }

         statistics.viewDidFinishRenderingFrame()
    }
    


}

