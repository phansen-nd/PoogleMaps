//
//  User.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 3/29/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Firebase

class User {
    
    var uid: String
    var displayName: String
    var firstName: String
    var name: String
    var email: String
    var photoURL: String
    var dateJoined: String
    var profilePhoto: UIImage?
    
    init(withData data: [String:String], andUID uid: String) {
        //let data = snapshot.value as! [String:String]

        self.uid = uid
        self.displayName = data["displayName"]!
        self.firstName = data["firstName"]!
        self.name = data["name"]!
        self.email = data["email"]!
        self.photoURL = data["photoURL"]!
        self.dateJoined = data["dateJoined"]!
    }
    
    init(withSnapshot snapshot: FIRDataSnapshot, andUID uid: String) {
        let data = snapshot.value as! [String:String]
        
        self.uid = uid
        self.displayName = data["displayName"]!
        self.firstName = data["firstName"]!
        self.name = data["name"]!
        self.email = data["email"]!
        self.photoURL = data["photoURL"]!
        self.dateJoined = data["dateJoined"]!
    }
    
    // Download profile image in background and display.

}
