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
import Metal

class MetalScreenSaverView : ScreenSaverView
{
    var device: MTLDevice!
    var displayLink: CVDisplayLink!

    var outputTime: Double = 0


    // init and deinit

    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        device = selectMetalDevice(preferLowPower: true) // TODO: make low power preference a user default?
        wantsLayer = true;
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    deinit
    {
        CVDisplayLinkStop(displayLink!)
    }

    private func selectMetalDevice(preferLowPower: Bool) -> MTLDevice
    {
        var device: MTLDevice?
        if !preferLowPower {
            device = MTLCreateSystemDefaultDevice()!
        } else {
            for d in MTLCopyAllDevices() {
                device = d
                NSLog("Considering device '\(d.name)'")
                if d.isLowPower && !d.isHeadless {
                    break
                }
            }
        }
        if let name = device?.name {
            NSLog("Using device '\(name)'")
        } else {
            NSLog("No or unknown device")
        }
        return device! // TODO: can we assume there will always be a device?
    }


    // deferred initialisations that require access to the window

    override func viewDidMoveToSuperview()
    {
        super.viewDidMoveToSuperview()
        if let window = superview?.window {
            layer = makeMetalLayer(window: window, device:device)
            displayLink = makeDisplayLink(window: window)
        }
    }

    private func makeMetalLayer(window: NSWindow, device: MTLDevice) -> CAMetalLayer
    {
        let metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.contentsScale = window.backingScaleFactor
        metalLayer.isOpaque = true
        return metalLayer
    }

    private func makeDisplayLink(window: NSWindow) -> CVDisplayLink
    {
        func displayLinkOutputCallback(_ displayLink: CVDisplayLink, _ nowPtr: UnsafePointer<CVTimeStamp>, _ outputTimePtr: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
            let _self: MetalScreenSaverView = unsafeBitCast(displayLinkContext, to: MetalScreenSaverView.self)
            let outputTime = outputTimePtr.pointee
            _self.outputTime = Double(outputTime.videoTime) / Double(outputTime.videoTimeScale)
            _self.animateOneFrame()
            return kCVReturnSuccess
        }

        var link: CVDisplayLink?
        let ddDictionary = Dictionary(uniqueKeysWithValues: window.screen!.deviceDescription.map {key, value in (key.rawValue, value)})
        let screensID = UInt32(ddDictionary["NSScreenNumber"] as! Int)
        CVDisplayLinkCreateWithCGDisplay(screensID, &link)
        CVDisplayLinkSetOutputCallback(link!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        return link!
    }

    
    // screen saver api

    override func startAnimation()
    {
        // we're not calling super because we need to set up our own timer for the animation
        CVDisplayLinkStart(displayLink!)
    }

    override func stopAnimation()
    {
        // we're not calling super because we didn't do it in startAnimation()
        CVDisplayLinkStop(displayLink!)
    }
    
    override var isAnimating: Bool
    {
        get { CVDisplayLinkIsRunning(displayLink!) }
    }


}

