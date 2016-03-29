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
    var creator: User
    var location: CLLocation
    var credit: Int = 0
    var rating: Float = 3.0
    var owner: User
    var image: UIImage
    var locale: Locale
    var gender: GenderType
    
    init (name: String, user: User, location: CLLocation, image: UIImage, locale: Locale, gender: GenderType) {
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
}



enum GenderType {
    case Men
    case Women
    case Unisex
}