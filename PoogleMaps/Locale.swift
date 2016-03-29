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
    var center: CLLocation
    var zoomLevel: Int = 13
    var snippet: String = ""
    
    init(type: LocationType, center: CLLocation) {
        self.type = type
        self.center = center
    }
    
    func getPoogles() -> [Poogle] {
        let poogles: [Poogle] = []
        
        return poogles
    }
}

enum LocationType {
    case City
    case Campus
}