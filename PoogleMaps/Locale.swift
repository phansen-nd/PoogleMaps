//
//  Locale.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 3/29/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation
import CoreLocation

class Locale {
    
    var type: String?
    var name: String?
    var lat: Double?
    var long: Double?
    var zoom: Float = 13.0
    var snippet: String?
    
    init(dict: NSDictionary) {
        
        self.type = dict["type"] as? String
        self.lat = dict["lat"] as? Double
        self.long = dict["lat"] as? Double
        self.zoom = dict["zoom"] as! Float
        self.name = dict["name"] as? String
        self.snippet = dict["snippet"] as? String
        
        
    }
    
    func toDict() -> NSDictionary {
        let dict: NSDictionary = ["name": name!, "zoom": zoom, "lat": lat!, "long": long!, "snippet": snippet!, "type": type!]
        
        return dict
    }
    
    func getPoogles() -> [Poogle] {
        let poogles: [Poogle] = []
        
        return poogles
    }
}