//
//  Poogle.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 2/3/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation
import Parse

class Poogle: PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Poogle"
    }
    
    @NSManaged var name: String
    @NSManaged var location: PFGeoPoint
    @NSManaged var credit: Float
    @NSManaged var rating: Float
    @NSManaged var creator: PFUser
    
}