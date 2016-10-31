//
//  Building.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/31/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation

class Building {
    
    var lat: Double
    var long: Double
    var displayName: String
    var locale: Locale?
    
    init(_ data: [String:AnyObject], allLocales: [Locale]) {
        
        lat = data["lat"] as! Double
        long = data["long"] as! Double
        displayName = data["displayName"] as! String
        
        let localeName = data["locale"] as! String
        for possibleLocale in allLocales {
            if possibleLocale.name == localeName {
                locale = possibleLocale
                break
            }
        }
    }
    
    
}
