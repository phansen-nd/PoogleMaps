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

class MapViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addScreenView: UIView!
    @IBOutlet weak var plusButtonBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkButtonTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var takeImageButton: UIButton!
    
    let locationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    var addScreenHeight: CGFloat = 0.0
    let checkPlusMargin: CGFloat = 5.0
    var plusButtonOffset: CGFloat = 0.0
    var addScreenUp = false
    
    // Create a reference to a Firebase location
    var root = Firebase(url:"https://poogle-maps.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        imagePicker.delegate = self
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
        
        // Clip image view
        imageView.clipsToBounds = true
        self.view.layoutIfNeeded()
        
        // Set text field delegates
        nameTextField.delegate = self
        
        // Add bottom line to text fields
        let underline: CALayer = CALayer()
        underline.frame = CGRectMake(5.0, nameTextField.frame.height - 1, nameTextField.frame.width - 20, 1.0)
        underline.backgroundColor = UIColor(netHex: 0x0b0b7a).CGColor
        underline.opacity = 0.5
        nameTextField.layer.addSublayer(underline)
        
        /*
        // Get initial locale
        let ref = root.childByAppendingPath("/locales/Chicago")
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let lat = snapshot.value["lat"] as! Double
            let long = snapshot.value["long"] as! Double
            let loc = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let loctype: LocationType = ((snapshot.value["type"] as! String) == "City") ? .City : .Campus
            let zoom = snapshot.value["zoomLevel"] as! Float
            let name = snapshot.value["name"] as! String
            let snippet = snapshot.value["snippet"] as! String
            
            self.currentLocale = Locale(type: loctype, center: loc, zoom: zoom, name: name, snippet: snippet)
            
            let camera = GMSCameraPosition.cameraWithLatitude((self.currentLocale?.center.latitude)!,
                longitude: (self.currentLocale?.center.longitude)!, zoom: (self.currentLocale?.zoomLevel)!)
            self.mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
            //self.mapView.myLocationEnabled = true
            
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake((self.currentLocale?.center.latitude)!, (self.currentLocale?.center.longitude)!)
            print(marker.position)
            marker.title = self.currentLocale?.name
            marker.snippet = self.currentLocale?.snippet
            marker.map = self.mapView
            
        })*/
        
        //let camera = GMSCameraPosition.cameraWithLatitude((self.currentLocale.center.latitude),
        //    longitude: (self.currentLocale.center.longitude), zoom: (self.currentLocale.zoomLevel))
        
        //self.mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        
        self.mapView.myLocationEnabled = true
        
        // Initial locale marker
        
        
        // Load all currently stored Poogles
        let newref = root.childByAppendingPath("/poogles/")
        newref.observeEventType(.Value, withBlock: { snapshot in
            if let dict = snapshot.value as! NSDictionary? {
                self.preloadMarkers(dict)
            }
        })
    }
    
    //
    // MARK: - Actions
    //
    
    @IBAction func takeImageButtonTouched(sender: AnyObject) {
    
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadImageButtonTouched(sender: AnyObject) {

        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func plusButtonTouched(sender: AnyObject) {

        if !addScreenUp {
            showAddView()
        } else {
            hideAddView()
        }
        
    }
    
    @IBAction func checkButtonTouched(sender: AnyObject) {
        
        // Get current map location
        // Currently just takes center of the screen -- eventually put in crosshairs
        let loc: CLLocationCoordinate2D = mapView.projection.coordinateForPoint(mapView.center)
        
        // Get gender from segmented control
        var gender = "Men"
        if genderSegmentedControl.selectedSegmentIndex == 1 {
            gender = "Mixed"
        } else if genderSegmentedControl.selectedSegmentIndex == 2 {
            gender = "Women"
        }
        
        // Create image object
        let imageRef = root.childByAppendingPath("images/\(nameTextField.text!)")
        imageRef.setValue(encodedImage(imageView.image!))
        
        // Create Poogle object
        let poo = Poogle(name: nameTextField.text!, creator: "phansen-nd", lat: loc.latitude, long: loc.longitude, owner: "phansen-nd", image: nameTextField.text!, locale: "Campus", gender: gender)
        
        
        // Upload to Firebase
        let newRef = root.childByAppendingPath("poogles/\(nameTextField.text!)")
        newRef.setValue(poo.toDict())
        
        /*
        // Sign up user
        myRootRef.createUser(ownerTextField.text!, password: "correcthorsebatterystaple",
            withValueCompletionBlock: { error, result in
                
                if error != nil {
                    // There was an error creating the account
                } else {
                    let uid = result["uid"] as? String
                    print("Successfully created user account with uid: \(uid)")
                }
        })*/
        
        // Create map marker
        let marker = GMSMarker()
        marker.position = loc
        marker.title = nameTextField.text!
        marker.snippet = poo.creator
        marker.icon = UIImage(named: "toilet-icon")
        marker.map = mapView
        
        // Hide add controller
        hideAddView()
        
        // Clear text fields
        nameTextField.text = ""
        imageView.image = UIImage(named: "wide_placeholder")
        
    }
    
    //
    // MARK: - Class helper functions
    //
    
    func encodedImage (image: UIImage) -> String {
        
        let imageData: NSData = UIImageJPEGRepresentation(image, 0.7)!
        let str = imageData.base64EncodedStringWithOptions([.Encoding64CharacterLineLength])
        return str
    }
    
    func decodedImage (str: String) -> UIImage {
        let decodedData = NSData(base64EncodedString: str, options: .IgnoreUnknownCharacters)
        
        let decodedImage = UIImage(data: decodedData!)
        
        return decodedImage!
    }
    
    func preloadMarkers (poogles: NSDictionary) {
        
        let pooglesList: [NSDictionary] = poogles.allValues as! [NSDictionary]
        let icon = UIImage(named: "toilet-icon")
        
        
        for dict: NSDictionary in pooglesList {
            
            // Create Poogle
            let poo = Poogle(dict: dict)
            
            // Create map marker
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(poo.lat!, poo.long!)
            marker.title = poo.name
            marker.snippet = poo.creator
            //marker.infoWindowAnchor = CGPointMake(0.0, 0.4)
            marker.icon = icon
            marker.map = self.mapView
        }
    }
    
    func showAddView() {
        // Pre layout to ensure any pending changes take place before animation
        self.view.layoutIfNeeded()
        
        // Keep track of 5pi/4
        let angleInRadians: CGFloat = -5/4*3.14
        
        UIView.animateWithDuration(0.5, animations: {
            
            // Plus button pushes up from bottom and spins
            self.plusButtonBottomSpaceConstraint.constant += (self.addScreenView.frame.height - self.plusButtonOffset)
            self.plusButton.transform = CGAffineTransformMakeRotation(angleInRadians)
            
            // Transform button shadow along with spin
            self.plusButton.layer.shadowOffset = self.correctedShadowOffsetForRotatedView(Float(angleInRadians), anOffset: CGSizeMake(0.0, 2.0))
            
            // Show add screen and add shadow
            self.addScreenView.transform = CGAffineTransformMakeTranslation(0.0, -self.addScreenHeight)
            self.addScreenView.layer.masksToBounds = false
            self.addScreenView.layer.shadowOffset = CGSizeMake(0, -3.0)
            self.addScreenView.layer.shadowOpacity = 0.15
            self.addScreenView.layer.shadowRadius = 1.0
            
            // Enact constraint changes
            self.view.layoutIfNeeded()
            
            }, completion: { finished in
                
                // Start the check button upside down so it can roll out
                self.checkButton.transform = CGAffineTransformMakeRotation(3.14)
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    // Check button pushes out from plus button, spins, and grows shadow
                    self.checkButtonTrailingSpaceConstraint.constant += (self.checkPlusMargin + self.plusButton.bounds.width)
                    self.checkButton.transform = CGAffineTransformMakeRotation(0.0)
                    self.checkButton.layer.shadowOpacity = 0.3
                    
                    // Enact constraint changes again
                    self.view.layoutIfNeeded()
                    
                    }, completion: { finished in
                        
                        // Initially, disable the add button - enable once the fields are filled out
                        self.checkButton.enabled = false
                })
        })
        
        // Update switch
        addScreenUp = true
        
    }
    
    func hideAddView() {
        // Undo everything
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.3, animations: {
            self.checkButton.transform = CGAffineTransformMakeRotation(3.14)
            self.checkButton.layer.shadowOpacity = 0.0
            self.checkButtonTrailingSpaceConstraint.constant -= (self.checkPlusMargin + self.plusButton.bounds.width)
            
            self.view.layoutIfNeeded()
            
            }, completion: {finished in
                
                UIView.animateWithDuration(0.5, animations: {
                    self.plusButton.transform = CGAffineTransformMakeRotation(0.0)
                    self.plusButtonBottomSpaceConstraint.constant -= (self.addScreenView.frame.height - self.plusButtonOffset)
                    
                    self.plusButton.layer.shadowOffset = self.correctedShadowOffsetForRotatedView(0.0, anOffset: CGSizeMake(0.0, 2.0))
                    
                    self.addScreenView.transform = CGAffineTransformMakeTranslation(0.0, self.addScreenHeight)
                    
                    self.view.layoutIfNeeded()
                })
        })
        
        addScreenUp = false
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        // Get address from coordinate
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                self.locationLabel.text = lines.joinWithSeparator("\n")
            }
        }
    }
    
    func correctedShadowOffsetForRotatedView(anAngle: Float, anOffset: CGSize) -> CGSize {
        let x: Float = Float(anOffset.height)*sinf(anAngle) + Float(anOffset.width)*cosf(anAngle);
        let y: Float = Float(anOffset.height)*cosf(anAngle) - Float(anOffset.width)*sinf(anAngle);
        
        return CGSizeMake(CGFloat(x), CGFloat(y));
    }
    
    /*
    *  Text Field functions
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.checkButton.enabled = true
        
        return false
    }
    
    // 
    // MARK: - Image Picker Delegate
    //
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFill
            imageView.image = pickedImage
            imageView.clipsToBounds = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // MARK: - Navigation
    //
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //
    }
    
    
    
}

// CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
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
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
}

// GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        
        // Reverse geocodes the center of the screen
        // Could switch position.target to a custom location based on crosshairs or something
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        let ref = root.childByAppendingPath("/poogles/\(marker.title!)")
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let poogleVC: PoogleViewController = storyboard.instantiateViewControllerWithIdentifier("PoogleViewController") as! PoogleViewController
            
            // Set value of poogle's infoDict
            poogleVC.infoDict = snapshot.value as? NSDictionary
            
            self.presentViewController(poogleVC, animated: true, completion: nil)
        })
        
        return true
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
