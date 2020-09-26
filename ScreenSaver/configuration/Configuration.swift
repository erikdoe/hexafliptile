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

class Configuration
{
    static let sharedInstance = Configuration()

    private var defaults: UserDefaults

    var paletteList: [[String]]
    var colors: [NSColor]
    var backgroundColor = NSColor(webcolor: "#000000")

    init()
    {
        paletteList = Configuration.loadPalettes()
        colors = []
        let identifier = Bundle(for: Configuration.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)! as UserDefaults
        defaults.register(defaults: [
            "tiles": 25,
            "palette": [ "#ef476f", "#ffd166", "#06d6a0", "#118ab2", "#073b4c" ]
            ])
        update()
        colors = palette.map { NSColor(webcolor: $0 as NSString) }
    }

    private static func loadPalettes() -> [[String]]
    {
        let url = Bundle(for: Configuration.self).url(forResource: "Colors", withExtension: "json")!
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonResult as! [[String]]
        } catch {
            NSLog("Error loading 'Colors.json'")
            return []
        }
    }

    var glyphSize: Float
    {
        get
        {
            1 / (1.5 * Float(tiles))
        }
    }

    var tiles: Int
    {
        set
        {
            defaults.set(newValue, forKey: "tiles")
        }
        get
        {
            defaults.integer(forKey: "tiles")
        }
    }

    var palette: [String]
    {
        set
        {
            defaults.set(newValue, forKey: "palette")
            colors = newValue.map { NSColor(webcolor: $0 as NSString) }
            update()
        }
        get
        {
            defaults.array(forKey: "palette") as! [String]
        }
    }

    private func update()
    {
        defaults.synchronize()
    }

    
}

