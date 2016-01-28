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
    @IBOutlet weak var plusButtonBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkButtonTrailingSpaceConstraint: NSLayoutConstraint!
     
    let locationManager = CLLocationManager()
    var addScreenHeight: CGFloat = 0.0
    let checkPlusMargin: CGFloat = 5.0
    var plusButtonOffset: CGFloat = 0.0
    var addScreenUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        
        // Make buttons circles with little shadows under
        plusButton.clipsToBounds = true
        plusButton.layer.masksToBounds = false
        plusButton.layer.cornerRadius = plusButton.frame.width/2.0
        plusButton.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        plusButton.layer.shadowOpacity = 0.3
        plusButton.layer.shadowRadius = 1.0
        
        checkButton.clipsToBounds = true
        checkButton.layer.masksToBounds = false
        checkButton.layer.cornerRadius = checkButton.frame.width/2.0
        checkButton.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        checkButton.layer.shadowOpacity = 0.0 // Start 0
        checkButton.layer.shadowRadius = 1.0
        
        // Calculate plus button offset
        plusButtonOffset = UIScreen.mainScreen().bounds.height - plusButton.frame.origin.y - 5.0
        addScreenHeight = addScreenView.frame.height
        
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
            
            self.view.layoutIfNeeded()
            let angleInRadians: CGFloat = -5/4*3.14
            
            UIView.animateWithDuration(0.5, animations: {
                self.plusButtonBottomSpaceConstraint.constant += (self.addScreenView.frame.height - self.plusButtonOffset)
                self.plusButton.transform = CGAffineTransformMakeRotation(angleInRadians)
                self.addScreenView.transform = CGAffineTransformMakeTranslation(0.0, -self.addScreenHeight)

                // Transform button shadows
                self.plusButton.layer.shadowOffset = self.correctedShadowOffsetForRotatedView(Float(angleInRadians), anOffset: CGSizeMake(0.0, 2.0))

                // Add shadow to add view
                self.addScreenView.layer.masksToBounds = false
                self.addScreenView.layer.shadowOffset = CGSizeMake(0, -3.0)
                self.addScreenView.layer.shadowOpacity = 0.15
                self.addScreenView.layer.shadowRadius = 1.0
                
                self.view.layoutIfNeeded()
                
                }, completion: { finished in
                    
                    // Start the check button upside down so it can roll out
                    self.checkButton.transform = CGAffineTransformMakeRotation(3.14)
                    
                    UIView.animateWithDuration(0.3, animations: {
                    
                        self.checkButtonTrailingSpaceConstraint.constant -= (self.checkPlusMargin + self.plusButton.bounds.width)
                        self.checkButton.transform = CGAffineTransformMakeRotation(0.0)
                        self.checkButton.layer.shadowOpacity = 0.3
                        
                        self.view.layoutIfNeeded()
                        
                        }, completion: { finished in
                                self.checkButton.enabled = false
                    })
                    
            })
            addScreenUp = true
        } else {
            
            self.view.layoutIfNeeded()
            
            UIView.animateWithDuration(0.3, animations: {
                self.checkButton.transform = CGAffineTransformMakeRotation(3.14)
                self.checkButton.layer.shadowOpacity = 0.0
                self.checkButtonTrailingSpaceConstraint.constant += (self.checkPlusMargin + self.plusButton.bounds.width)
                
                self.view.layoutIfNeeded()
                
                }, completion: {finished in
            
                    UIView.animateWithDuration(0.5, animations: {
                        self.plusButton.transform = CGAffineTransformMakeRotation(0.0)
                        self.plusButtonBottomSpaceConstraint.constant -= (self.addScreenView.frame.height - self.plusButtonOffset)
                        self.addScreenView.transform = CGAffineTransformMakeTranslation(0.0, self.addScreenHeight)
                        
                        // Rotate shadow back
                        self.plusButton.layer.shadowOffset = self.correctedShadowOffsetForRotatedView(0.0, anOffset: CGSizeMake(0.0, 2.0))
                        
                        self.view.layoutIfNeeded()
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
    
    func correctedShadowOffsetForRotatedView(anAngle: Float, anOffset: CGSize) -> CGSize {
        let x: Float = Float(anOffset.height)*sinf(anAngle) + Float(anOffset.width)*cosf(anAngle);
        let y: Float = Float(anOffset.height)*cosf(anAngle) - Float(anOffset.width)*sinf(anAngle);
    
        return CGSizeMake(CGFloat(x), CGFloat(y));
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