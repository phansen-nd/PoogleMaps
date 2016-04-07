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
    var image: UIImage?
    var locale: String?
    var gender: String?
    
    init (dict: NSDictionary) {
        
        self.name = dict["name"] as? String
        self.lat = dict["lat"] as? Double
        self.long = dict["long"] as? Double
        self.image = decodedImage(dict["image"] as! String)
        self.locale = dict["locale"] as? String
        self.gender = dict["gender"] as? String
        self.creator = dict["creator"] as? String
        self.owner = dict["owner"] as? String
        self.credit = dict["credit"] as! Int
        self.rating = dict["rating"] as! Float
    }
    
    func toDict() -> NSDictionary {
        let dict: NSDictionary = ["name": name!, "credit": credit, "rating": rating, "lat": lat!, "long": long!, "locale": locale!, "image":encodedImage(self.image!), "creator": creator!, "owner": owner!, "gender": gender!]
        
        return dict
    }
    
    func getTestimonials() -> [Testimonial] {
        let testimonials: [Testimonial] = []
        
        return testimonials
    }
}

func encodedImage (image: UIImage) -> String {
    
    let imageData: NSData = UIImageJPEGRepresentation(image, 0.7)!
    let str = imageData.base64EncodedStringWithOptions([.Encoding64CharacterLineLength])
    return str
}

func decodedImage (str: String) -> UIImage {
    let decodedData = NSData(base64EncodedString: str, options: .IgnoreUnknownCharacters)
    
    let decodedImage = UIImage(data: decodedData!)
    
    return decodedImage!
}