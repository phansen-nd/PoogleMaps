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

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addScreenView: UIView!
     
    let locationManager = CLLocationManager()
    let addScreenHeight: CGFloat = 200.0
    let checkPlusMargin: CGFloat = 5.0
    var plusButtonOffset: CGFloat = 0.0
    var addScreenUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        
        // Make buttons circles
        plusButton.clipsToBounds = true
        plusButton.layer.cornerRadius = plusButton.frame.width/2.0
        checkButton.clipsToBounds = true
        checkButton.layer.cornerRadius = checkButton.frame.width/2.0
        
        // Calculate plus button offset
        plusButtonOffset = UIScreen.mainScreen().bounds.height - plusButton.frame.origin.y
        
//
//        var chicago = Location()
//        
//        let query = PFQuery(className:"Location")
//        query.whereKey("name", equalTo:"Chicago")
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                // The find succeeded.
//                //print("Successfully retrieved \(objects!.count) location.")
//                // Do something with the found objects
//                if let objects = objects {
//                    chicago = objects[0] as! Location
//                    
//                    let loc = chicago.location
//                    let zoom = chicago.zoomLevel
//                    
//                    
//                    let camera = GMSCameraPosition.cameraWithLatitude(loc.latitude,
//                        longitude: loc.longitude, zoom: zoom)
//                    self.mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
//                    self.mapView.myLocationEnabled = true
//
//                    
//                    let marker = GMSMarker()
//                    marker.position = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
//                    marker.title = "Chicago"
//                    marker.snippet = "Machine"
//                    marker.map = self.mapView
//                    
//
//                }
//            } else {
//                // Log details of the failure
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
        
        
    }
    
    @IBAction func plusButtonTouched(sender: AnyObject) {
    
        if !addScreenUp {
            UIView.animateWithDuration(0.5, animations: {
                self.plusButton.center.y -= self.plusButtonOffset
                self.plusButton.transform = CGAffineTransformMakeRotation(5*3.14 / -4.0)
                self.checkButton.center.y -= self.plusButtonOffset
                self.addScreenView.transform = CGAffineTransformMakeTranslation(0.0, -self.addScreenHeight)
                
                }, completion: { finished in
                    
                    self.checkButton.transform = CGAffineTransformMakeRotation(3.14)
                    
                    UIView.animateWithDuration(0.3, animations: {
                    
                        self.checkButton.center.x -= (self.checkPlusMargin + self.plusButton.bounds.width)
                        self.checkButton.transform = CGAffineTransformMakeRotation(0.0)
                        
                        }, completion: { finished in
                                self.checkButton.enabled = false
                    })
                    
            })
            addScreenUp = true
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.checkButton.transform = CGAffineTransformMakeRotation(3.14)
                self.checkButton.center.x += (self.checkPlusMargin + self.plusButton.bounds.width)
                }, completion: {finished in
            
                    UIView.animateWithDuration(0.5, animations: {
                        self.plusButton.transform = CGAffineTransformMakeRotation(0.0)
                        self.plusButton.center.y += self.plusButtonOffset
                        self.checkButton.center.y += self.plusButtonOffset
                        self.addScreenView.transform = CGAffineTransformMakeTranslation(0.0, self.addScreenHeight)
                    })
            })
            
            
            addScreenUp = false
        }
        
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        // Get address from coordinate
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                self.locationLabel.text = lines.joinWithSeparator("\n")
            
            }
        }
    }
    
    

}

// CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    // Called when user authorizes or deauthorizes app to use location
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // If it's positive authorization:
        if status == .AuthorizedWhenInUse {
            
            // Start udpating
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    // Once location manager starts receiving locations
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            // Update the camera to user's location
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // Then stop updating after initial location grab
            locationManager.stopUpdatingLocation()
        }
        
    }
}

// GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
        // Reverse geocodes the center of the screen
        // Could switch position.target to a custom location based on crosshairs or something
        reverseGeocodeCoordinate(position.target)
    }
    
}