//
//  Testimonial.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 3/29/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation

class Testimonial {
    
    var creator: User
    var subject: Poogle
    var attributes: [String]
    var rating: Float
    var comment: String = ""
    
    init (creator: User, subject: Poogle, attributes: [String], rating: Float) {
        self.creator = creator
        self.subject = subject
        self.attributes = attributes
        self.rating = rating
    }
}