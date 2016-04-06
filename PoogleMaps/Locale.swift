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
    
    var type: LocationType
    var name: String = ""
    var center: CLLocationCoordinate2D
    var zoomLevel: Float = 13.0
    var snippet: String = ""
    
    init(type: LocationType, center: CLLocationCoordinate2D, zoom: Float, name: String, snippet: String) {
        self.type = type
        self.center = center
        self.zoomLevel = zoom
        self.name = name
        self.snippet = snippet
    }
    
    func getPoogles() -> [Poogle] {
        let poogles: [Poogle] = []
        
        return poogles
    }
    
    func toDict() -> NSDictionary {
        let dict: NSDictionary = ["name": name]
        
        return dict
    }
}

enum LocationType {
    case City
    case Campus
}