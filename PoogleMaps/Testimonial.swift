//
//  Testimonial.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 3/29/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation

class Testimonial {
    
    var creator: String
    var title: String
    var subject: String
    var attributes: [String:Float]
    var rating: Float
    var comment: String = ""
    
    init (creator: String, title: String, subject: String, attributes: [String:Float], rating: Float, comment: String) {
        self.creator = creator
        self.title = title
        self.subject = subject
        self.attributes = attributes
        self.rating = rating
        self.comment = comment
    }
    
    func toDict() -> NSDictionary {
        let dict = ["creator": creator, "title": title, "subject": subject, "attribtues": attributes, "rating": rating, "comment": comment]
        
        return dict
    }
}