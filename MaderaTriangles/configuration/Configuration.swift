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

    let glyphSize = 0.05
    let backgroundColor = NSColor(webcolor: "#AAAAAA")
    let colors = [
        NSColor(webcolor: "#c85c6c"),
        NSColor(webcolor: "#fe7567"),
        NSColor(webcolor: "#fcc96c"),
        NSColor(webcolor: "#548ecb"),
        NSColor(webcolor: "#315b8b")
    ]

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

    
}

