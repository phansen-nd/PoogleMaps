//
//  Place.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Firebase
import Darwin

class Place {
    
    // Static lists.
    let firstWords = ["Poop", "Poo", "Crap", "Dook", "Doodle", "Shite"]
    let secondWords = ["Zone", "Pad", "Place", "Spot", "Corner"]
    
    // Member variables.
    var name: String
    
    init() {
        
        // Create a random name with our words and a number between 1-100.
        let num = Int(arc4random_uniform(100) + 1)
        let i1 = Int(arc4random_uniform(6))
        let i2 = Int(arc4random_uniform(5))
        name = "\(firstWords[i1])\(secondWords[i2])\(num)"
        
        
    }
    
}
