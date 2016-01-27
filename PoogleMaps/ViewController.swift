//
//  ViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 1/26/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
        var chicago = Location()
        
        let query = PFQuery(className:"Location")
        query.whereKey("name", equalTo:"Chicago")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                //print("Successfully retrieved \(objects!.count) location.")
                // Do something with the found objects
                if let objects = objects {
                    chicago = objects[0] as! Location
                    
                    let loc = chicago.location
                    let zoom = chicago.zoomLevel
                    
                    
                    let camera = GMSCameraPosition.cameraWithLatitude(loc.latitude,
                        longitude: loc.longitude, zoom: zoom)
                    let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
                    mapView.myLocationEnabled = true
                    self.view = mapView
                    
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
                    marker.title = "Chicago"
                    marker.snippet = "Machine"
                    marker.map = mapView

                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
    }

}

