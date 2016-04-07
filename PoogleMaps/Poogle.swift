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
    
    var name: String?
    var creator: String?
    var lat: Double?
    var long: Double?
    var credit: Int = 0
    var rating: Float = 3.0
    var owner: String?
    var image: String?
    var locale: String?
    var gender: String?
    
    init (name: String, creator: String, lat: Double, long: Double, owner: String, image: String, locale: String, gender: String) {
        self.name = name
        self.creator = creator
        self.lat = lat
        self.long = long
        self.owner = owner
        self.image = image
        self.locale = locale
        self.gender = gender
    }
    
    init (dict: NSDictionary) {
        
        self.name = dict["name"] as? String
        self.lat = dict["lat"] as? Double
        self.long = dict["long"] as? Double
        self.image = dict["image"] as? String
        self.locale = dict["locale"] as? String
        self.gender = dict["gender"] as? String
        self.creator = dict["creator"] as? String
        self.owner = dict["owner"] as? String
        self.credit = dict["credit"] as! Int
        self.rating = dict["rating"] as! Float
    }
    
    func toDict() -> NSDictionary {
        let dict: NSDictionary = ["name": name!, "credit": credit, "rating": rating, "lat": lat!, "long": long!, "locale": locale!, "image":image!, "creator": creator!, "owner": owner!, "gender": gender!]
        
        return dict
    }
    
    func getTestimonials() -> [Testimonial] {
        let testimonials: [Testimonial] = []
        
        return testimonials
    }
}