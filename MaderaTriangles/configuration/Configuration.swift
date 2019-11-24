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

class Configuration
{
    static let sharedInstance = Configuration()

    let numSprites = 700
    let glyphSize = 0.08
    let outlineColor = NSColor(webcolor: "#CCCCCC")
    let backgroundColor = NSColor(webcolor: "#000000")


    var defaults: UserDefaults

    
    init()
    {
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)! as UserDefaults
        defaults.register(defaults: [:])
        update()
    }
    

    private func update()
    {
        defaults.synchronize()
    }

    
    var wave: Scene
    {
        get
        {
            return Scene()
        }
    }

}

