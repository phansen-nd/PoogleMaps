//
//  DataManager.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Firebase
import CoreLocation

protocol DataManagerDelegate {
    func handleNewPlace(with place: Place)
    func handleNewBuilding(with building: Building)
}

class DataManager {
    
    let root = FIRDatabase.database().reference()
    var refHandle: FIRDatabaseHandle = 0
    var delegate: DataManagerDelegate?
    let maxProximity: Double = 10.0 // Meters.
    
    var validLocales: [Locale] = []
    var allLocales: [Locale] = []
    
    init() {
        // Download locale info.
        root.child("/locales/").observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let locale = enumerator.nextObject() as? FIRDataSnapshot {
                let newLocale = Locale(locale.value as! [String:AnyObject])
                print("\(newLocale.name) is \(newLocale.valid ? "" : "not ")valid")
                if newLocale.valid {
                    self.validLocales.append(newLocale)
                }
                self.allLocales.append(newLocale)
            }
        })
    }
    
    func saveNewPlace(with lat: Double, long: Double) {
        
        let place = Place(lat, longitude: long)
        
        root.child("places").childByAutoId().setValue(place.jsonify())
        
        // TODO: check for network and post a notice that UI won't update
        //       if there's no network, but data will be saved.
    }
    
    func setNewPlaceListener() {
        refHandle = root.child("/places").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            let data = snapshot.value as! [String:AnyObject]
            let place = Place(data)
            self.delegate?.handleNewPlace(with: place)
        })
    }
    
    // TODO: check for closest/current locale and only download buildings where locale==locale.
    func setNewBuildingListener() {
        refHandle = root.child("/buildings").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            let data = snapshot.value as! [String:AnyObject]
            let building = Building(data, allLocales: self.allLocales)
            self.delegate?.handleNewBuilding(with: building)
        })
    }
    
    // Check if user is within acceptable range of where they're trying to create a Place.
    func inProximityGeofence(with userLocation: CLLocation, targetLocation: CLLocation) -> Bool {
        
        print("Distance from target: \(userLocation.distance(from: targetLocation))")
        if userLocation.distance(from: targetLocation) > maxProximity {
            return false
        }
        return true
    }
    
    // Check if user is within acceptable range of where they're trying to create a Place.
    func inLocalesGeofence(with targetLocation: CLLocation) -> Bool {
        
        // Print locale we fit in.
        for loc in validLocales {
            print("Distance from \(loc.name) is \(loc.center.distance(from: targetLocation)/1000)km.")
            if (loc.center.distance(from: targetLocation) + 0) < loc.radius {
                print("We're in \(loc.name)!")
                return true
            }
        }
        return false
    }
    
}
