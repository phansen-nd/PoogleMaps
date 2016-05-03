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
    var rating: Float = 0.0
    var owner: String?
    var smallImage: String?
    var largeImage: String?
    var locale: String?
    var gender: String?
    
    init (name: String, creator: String, lat: Double, long: Double, owner: String, smallImage: String, largeImage: String, locale: String, gender: String, rating: Float) {
        self.name = name
        self.creator = creator
        self.lat = lat
        self.long = long
        self.owner = owner
        self.smallImage = smallImage
        self.largeImage = largeImage
        self.locale = locale
        self.gender = gender
        self.rating = rating
    }
    
    init (dict: NSDictionary) {
        
        self.name = dict["name"] as? String
        self.lat = dict["lat"] as? Double
        self.long = dict["long"] as? Double
        self.smallImage = dict["smallImage"] as? String
        self.largeImage = dict["largeImage"] as? String
        self.locale = dict["locale"] as? String
        self.gender = dict["gender"] as? String
        self.creator = dict["creator"] as? String
        self.owner = dict["owner"] as? String
        self.credit = dict["credit"] as! Int
        self.rating = dict["rating"] as! Float
    }
    
    func toDict() -> NSDictionary {
        let dict: NSDictionary = ["name": name!, "credit": credit, "rating": rating, "lat": lat!, "long": long!, "locale": locale!, "smallImage":smallImage!, "largeImage": largeImage!, "creator": creator!, "owner": owner!, "gender": gender!]
        
        return dict
    }
    
    func getTestimonials() -> [Testimonial] {
        let testimonials: [Testimonial] = []
        
        return testimonials
    }
}