//
//  Locale.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/30/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation
import CoreLocation

class Locale {
    
    var valid: Bool
    var center: CLLocation
    var name: String
    var snippet: String
    var type: LocaleType
    var zoomLevel: Int
    var radius: Double
    
    
    init(_ data: [String:AnyObject]) {
        
        valid = ((data["valid"] as! Int) == 1) ? true : false
        name = data["name"] as! String
        snippet = data["snippet"] as! String
        zoomLevel = data["zoomLevel"] as! Int
        radius = data["radius"] as! Double
        center = CLLocation(latitude: data["lat"] as! Double, longitude: data["long"] as! Double)
        
        var checkType = LocaleType.Unknown
        switch data["type"] as! String {
        case "City":
            checkType = LocaleType.City
            break
        case "Campus":
            checkType = LocaleType.Campus
            break
        default:
            print("Type of locale was unrecognized")
        }
        
        type = checkType
    }
    
    enum LocaleType {
        case City
        case Campus
        case Unknown
    }
}
