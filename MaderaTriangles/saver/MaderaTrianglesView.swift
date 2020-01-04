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

import ScreenSaver


@objc(MaderaTrianglesView)
class MaderaTrianglesView: MetalScreenSaverView
{
    var glyphs: [Glyph]!
    var scene: Scene!

    var renderer: Renderer!
    var statistics: Statistics!


    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        glyphs = Glyph.makeAllGlyphs()
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
        scene.makeSprites(glyphs: glyphs, height: glyphSize)
    }

    private func updateSizeAndTextures(glyphSize: Double)
    {
        let divisor = max(bounds.size.width, bounds.size.height)
        renderer.setOutputSize(NSMakeSize(bounds.size.width / divisor, bounds.size.height / divisor))

        let widthInPixel = floor(min(bounds.width, bounds.height) * CGFloat(glyphSize))
        let hidpiFactor = (window!.backingScaleFactor)

        for (i, g) in glyphs.enumerated() {
            let bitmap = g.makeBitmap(size: NSMakeSize(widthInPixel * hidpiFactor, widthInPixel * hidpiFactor / g.aspectRatio))
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

         let sprites = scene.sprites //.sorted(by: { $0.glyphId > $1.glyphId })
         updateQuadsForSprites(sprites)

         let metalLayer = layer as! CAMetalLayer
         if let drawable = metalLayer.nextDrawable() { // TODO: can this really happen?
             renderer.renderFrame(drawable: drawable)
         }

         statistics.viewDidFinishRenderingFrame()
    }
    
    
    private func updateQuadsForSprites(_ sprites: [Sprite])
    {
        renderer.beginUpdatingQuads()

        let divisor = max(bounds.size.width, bounds.size.height)
        let offset = Vector2(Float((bounds.size.width/divisor - 1) / 2), Float((bounds.size.height/divisor - 1) / 2))

        for i in 0..<sprites.count {
            let (a, b, c, d) = sprites[i].corners
            renderer.updateQuad((a + offset, b + offset, c + offset, d + offset), textureId: sprites[i].glyphId, at:i)
        }

        renderer.finishUpdatingQuads()
    }

}

