//
//  Poogle.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 3/29/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Poogle {
    
    var name: String
    var creator: User = User()
    var location: CLLocationCoordinate2D
    var credit: Int = 0
    var rating: Float = 3.0
    var owner: User = User()
    var image: UIImage
    var locale: Locale
    var gender: GenderType
    
    init (name: String, location: CLLocationCoordinate2D, image: UIImage, locale: Locale, gender: GenderType) {
        self.name = name
        self.location = location
        self.image = image
        self.locale = locale
        self.gender = gender
    }
    
    init (name: String, user: User, location: CLLocationCoordinate2D, image: UIImage, locale: Locale, gender: GenderType) {
        self.name = name
        self.creator = user
        self.location = location
        self.owner = user
        self.image = image
        self.locale = locale
        self.gender = gender
    }
    
    func getTestimonials() -> [Testimonial] {
        let testimonials: [Testimonial] = []
        
        return testimonials
    }
    
    func toDict() -> NSDictionary {
        let dict: NSDictionary = ["name": name, "credit": credit, "rating": rating]
        
        return dict
    }
}



enum GenderType {
    case Men
    case Women
    case Mixed
}