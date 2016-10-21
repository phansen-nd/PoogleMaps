//
//  MapViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 3/29/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import CoreLocation

class MapViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addOverlayView: PassThroughableView!
    
    let locationManager = CLLocationManager()
    var root = FIRDatabase.database().reference()
    var isAdding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable delegates.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        // UI changes.
        profileButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        
        // Enable map settings.
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        
        // Set observer for auth updates.
        FIRAuth.auth()?.addStateDidChangeListener {auth, user in
            if let user = user {
                print("User is signed in: \(user.displayName!)")
            } else {
                print("No one is signed in at the moment.")
            }
        }
    }
    
    //
    // MARK: - Actions
    //
    
    @IBAction func plusButtonTouched(_ sender: AnyObject) {
        animatePlusButtonTouch()
        isAdding = !isAdding
    }
    
    // Launch the Login VC.
    // Eventually, this may be in a slide menu (from the side), but that's not MVP.
    // Today, we're all about MVP.
    @IBAction func userButtonTouched(_ sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC: LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    // 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showAdd":
            print("Add")
        default:
            print("Unrecognized segue.")
        }
    }
    
    // 
    // MARK: - Helper functions
    // 
    
    // Do UI things to enable/disable adding.
    func animatePlusButtonTouch() {
        if !isAdding {
            UIView.animate(withDuration: 0.5, animations: {
                
                // Swap alphas.
                self.profileButton.alpha = 0.0;
                self.addOverlayView.alpha = 1.0;
                
                // Rotate plus button to make it an 'X'.
                self.plusButton.transform = CGAffineTransform(rotationAngle: (5.0 * 3.14159265 / 4.0))
                self.plusButton.layer.shadowOpacity = 0.0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.profileButton.alpha = 1.0;
                self.addOverlayView.alpha = 0.0;
                self.plusButton.transform = CGAffineTransform(rotationAngle: 0.0)
                self.plusButton.layer.shadowOpacity = 0.25
            })
        }
    }
}

// CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    // Called when user authorizes or deauthorizes app to use location.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // If it's positive authorization:
        if status == .authorizedWhenInUse {
            // Start udpating.
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    // Once location manager starts receiving locations.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            // Update the camera to user's location
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // Then stop updating after initial location grab
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error finding location: \(error.localizedDescription)")
    }
}

// GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView!, didTap marker: GMSMarker!) -> Bool {
        // Center camera.
        mapView.animate(toLocation: marker.position)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow: CustomInfoWindow = Bundle.main.loadNibNamed("InfoWindow", owner: self, options: nil)![0] as! CustomInfoWindow
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
    }
}

// UIColor extension
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
