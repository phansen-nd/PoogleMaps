//
//  DataManager.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Firebase

protocol DataManagerDelegate {
    func handleNewPlace(with place: [String:AnyObject])
}

class DataManager {
    
    let root = FIRDatabase.database().reference()
    var refHandle: FIRDatabaseHandle = 0
    var delegate: DataManagerDelegate?
    
    func saveNewPlace(with lat: Double, long: Double) {
        
        let place = Place(lat, longitude: long)
        
        root.child("places").childByAutoId().setValue(place.jsonify())
        
        // TODO: check for network and post a notice that UI won't update
        //       if there's no network, but data will be saved.
    }
    
    func setNewPlaceListener() {
        refHandle = root.child("/places").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            let data = snapshot.value as! [String:AnyObject]
            self.delegate?.handleNewPlace(with: data)
        })
    }
    
    
    
}
