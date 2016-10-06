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
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addScreenView: UIView!
    @IBOutlet weak var plusButtonBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var takeImageButton: UIButton!
    @IBOutlet weak var addScreenTopContraint: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    var addScreenHeight: CGFloat = 0.0
    let checkPlusMargin: CGFloat = 5.0
    var initialBottomConstraintConstant: CGFloat = 0.0
    var addScreenUp = false
    var localPoogles: [AnyHashable:Any] = [:]
    
    // Create a reference to a Firebase location
    var root = FIRDatabase.database().reference()//Firebase(url:"https://poogle-maps.firebaseio.com/")
    var currentUsername: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        imagePicker.delegate = self
        mapView.delegate = self
        
        // Store initial values for animation
        //initialBottomConstraintConstant = plusButtonBottomSpaceConstraint.constant
        addScreenHeight = addScreenView.frame.height
        
        // Clip image view
        imageView.clipsToBounds = true
        self.view.layoutIfNeeded()
        
        // Set text field delegates
        nameTextField.delegate = self
        
        // Add bottom line to text fields
        let underline: CALayer = CALayer()
        underline.frame = CGRect(x: 5.0, y: nameTextField.frame.height - 1, width: nameTextField.frame.width - 20, height: 1.0)
        underline.backgroundColor = UIColor(netHex: 0x0b0b7a).cgColor
        underline.opacity = 0.5
        nameTextField.layer.addSublayer(underline)
        
        // Enable location
        self.mapView.isMyLocationEnabled = true
        
        // Update AddScreenView place
        addScreenTopContraint.constant = UIScreen.main.bounds.height
        
        // Load all currently stored Poogles 
        // Eventually this will need to be JUST local Poogles
        let newref = root.child("/poogles/")
        newref.observe(.value, with: { snapshot in
            if let dict = snapshot.value as! NSDictionary? {
                self.localPoogles = dict as! [AnyHashable : Any]
                self.preloadMarkers(dict)
            }
        })
        
        // Set observer for auth updates
        FIRAuth.auth()?.addStateDidChangeListener {auth, user in
            if let user = user {
                
                // Get username
                let newref = self.root.child("/users/\(user.uid)")
                newref.observeSingleEvent(of: .value, with: { snapshot in
                    if let dict = snapshot.value as! NSDictionary? {
                        self.currentUsername = dict["name"] as! String
                    }
                })
            }
        }
    }
    
    //
    // MARK: - Actions
    //
    
    @IBAction func takeImageButtonTouched(_ sender: AnyObject) {
    
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadImageButtonTouched(_ sender: AnyObject) {

        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func plusButtonTouched(_ sender: AnyObject) {

        for view in mapView.subviews {
            for v in view.subviews {
                print("\n\n\(v) frame: \(v.frame)\n\n")
            }
        }
        
        if !addScreenUp {
            // Check for user
            if (FIRAuth.auth()?.currentUser) != nil {
                //showAddView()
            } else {
                // No user - warn and return
                let alert = UIAlertController(title: "Whoops", message: "You have to be logged in to create a Poogle!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            //hideAddView()
        }
        
    }
    
    @IBAction func login(_ sender: AnyObject) {
        
        if (FIRAuth.auth()?.currentUser) != nil {
            // Logout
            try! FIRAuth.auth()!.signOut()

        } else {
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC: LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.present(loginVC, animated: true, completion: nil)

        
        }
    }
    
    @IBAction func checkButtonTouched(_ sender: AnyObject) {
        
        // Get current map location
        // Currently just takes center of the screen -- eventually put in crosshairs
        let loc: CLLocationCoordinate2D = mapView.projection.coordinate(for: mapView.center)
        
        // Get gender from segmented control
        var gender = "Men"
        if genderSegmentedControl.selectedSegmentIndex == 1 {
            gender = "Mixed"
        } else if genderSegmentedControl.selectedSegmentIndex == 2 {
            gender = "Women"
        }
        
        // Create a small image object
        let smallImageRef = root.child("smallImages/\(nameTextField.text!)")
        smallImageRef.setValue(encodedImage(imageView.image!, compressionFactor: 0.1))
        
        // Create a large image object
        let largeImageRef = root.child("largeImages/\(nameTextField.text!)")
        largeImageRef.setValue(encodedImage(imageView.image!, compressionFactor: 0.7))
        
        // Create Poogle object
        let poo = Poogle(name: nameTextField.text!, creator: currentUsername, lat: loc.latitude, long: loc.longitude, owner: currentUsername, smallImage: nameTextField.text!, largeImage: nameTextField.text!, locale: "Campus", gender: gender)
        
        // Upload to Firebase
        let newRef = root.child("poogles/\(nameTextField.text!)")
        newRef.setValue(poo.toDict())
        
        // Create map marker
        let marker = GMSMarker()
        marker.position = loc
        marker.title = nameTextField.text!
        marker.snippet = poo.creator
        marker.icon = UIImage(named: "toilet-icon")
        marker.map = mapView
        
        // Hide add controller
        //hideAddView()
        
        // Launch Testimonial view to get initial values
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let testimonialVC: AddTestimonialViewController = storyboard.instantiateViewController(withIdentifier: "AddTestimonial") as! AddTestimonialViewController
        testimonialVC.name = nameTextField.text!
        testimonialVC.initial = true
        self.present(testimonialVC, animated: true, completion: nil)
        
        // Clear text fields
        nameTextField.text = ""
        imageView.image = UIImage(named: "wide_placeholder")
        
    }
    
    //
    // MARK: - Class helper functions
    //
    
    func encodedImage (_ image: UIImage, compressionFactor: CGFloat) -> String {
        
        let imageData: Data = UIImageJPEGRepresentation(image, compressionFactor)!
        let str = imageData.base64EncodedString(options: [.lineLength64Characters])
        return str
    }
    
    func decodedImage (_ str: String) -> UIImage {
        let decodedData = Data(base64Encoded: str, options: .ignoreUnknownCharacters)
        
        let decodedImage = UIImage(data: decodedData!)
        
        return decodedImage!
    }
    
    func preloadMarkers (_ poogles: NSDictionary) {
        
        let pooglesList: [NSDictionary] = poogles.allValues as! [NSDictionary]
        let icon = UIImage(named: "toilet-icon")

        for dict: NSDictionary in pooglesList {
            
            // Create Poogle
            let poo = Poogle(dict: dict)
            
            // Create map marker
            let coordinates = CLLocationCoordinate2D(latitude: poo.lat, longitude: poo.long)
            let marker = GMSMarker(position: coordinates)
            marker?.map = self.mapView
            marker?.icon = icon
            marker?.infoWindowAnchor = CGPoint(x: 0.6, y: 0.0)
            marker?.title = poo.name
            
        }
    }
    /*
    func showAddView() {
        // Pre layout to ensure any pending changes take place before animation
        self.view.layoutIfNeeded()
        
        // Keep track of 5pi/4
        let angleInRadians: CGFloat = -5/4*3.14
        
        UIView.animate(withDuration: 0.5, animations: {
            
            // Plus button pushes up from bottom and spins
            self.plusButtonBottomSpaceConstraint.constant += (self.addScreenView.frame.height - self.initialBottomConstraintConstant - 10.0)
            self.plusButton.transform = CGAffineTransform(rotationAngle: angleInRadians)
            
            // Transform button shadow along with spin
            self.plusButton.layer.shadowOffset = self.correctedShadowOffsetForRotatedView(Float(angleInRadians), anOffset: CGSize(width: 0.0, height: 2.0))
            
            // Show add screen and add shadow
            self.addScreenView.transform = CGAffineTransform(translationX: 0.0, y: -self.addScreenHeight)
            self.addScreenView.layer.masksToBounds = false
            self.addScreenView.layer.shadowOffset = CGSize(width: 0, height: -3.0)
            self.addScreenView.layer.shadowOpacity = 0.15
            self.addScreenView.layer.shadowRadius = 1.0
            
            // Enact constraint changes
            self.view.layoutIfNeeded()
            
            }, completion: { finished in
                
                // Start the check button upside down so it can roll out
                self.checkButton.transform = CGAffineTransform(rotationAngle: 3.14)
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    // Check button pushes out from plus button, spins, and grows shadow
                    self.checkButtonTrailingSpaceConstraint.constant += (self.checkPlusMargin + self.plusButton.bounds.width)
                    self.checkButton.transform = CGAffineTransform(rotationAngle: 0.0)
                    self.checkButton.layer.shadowOpacity = 0.3
                    
                    // Enact constraint changes again
                    self.view.layoutIfNeeded()
                    
                    }, completion: { finished in
                        
                        // Initially, disable the add button - enable once the fields are filled out
                        self.checkButton.isEnabled = false
                })
        })
        
        // Update switch
        addScreenUp = true
        
    }
    
    func hideAddView() {
        // Undo everything
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.checkButton.transform = CGAffineTransform(rotationAngle: 3.14)
            self.checkButton.layer.shadowOpacity = 0.0
            self.checkButtonTrailingSpaceConstraint.constant -= (self.checkPlusMargin + self.plusButton.bounds.width)
            
            self.view.layoutIfNeeded()
            
            }, completion: {finished in
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.plusButton.transform = CGAffineTransform(rotationAngle: 0.0)
                    self.plusButtonBottomSpaceConstraint.constant = self.initialBottomConstraintConstant
                    
                    self.plusButton.layer.shadowOffset = self.correctedShadowOffsetForRotatedView(0.0, anOffset: CGSize(width: 0.0, height: 2.0))
                    
                    self.addScreenView.transform = CGAffineTransform(translationX: 0.0, y: self.addScreenHeight)
                    
                    self.view.layoutIfNeeded()
                })
        })
        
        addScreenUp = false
    }*/
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        // Get address from coordinate
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let lines = address.lines! as! [String]
            }
        }
    }
    
    func correctedShadowOffsetForRotatedView(_ anAngle: Float, anOffset: CGSize) -> CGSize {
        let x: Float = Float(anOffset.height)*sinf(anAngle) + Float(anOffset.width)*cosf(anAngle);
        let y: Float = Float(anOffset.height)*cosf(anAngle) - Float(anOffset.width)*sinf(anAngle);
        
        return CGSize(width: CGFloat(x), height: CGFloat(y));
    }
    
    //
    //  MARK: - Text Field functions
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
    // 
    // MARK: - Image Picker Delegate
    //
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.image = pickedImage
            imageView.clipsToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

// CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    // Called when user authorizes or deauthorizes app to use location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // If it's positive authorization:
        if status == .authorizedWhenInUse {
            
            // Start udpating
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
        }
    }
    
    // Once location manager starts receiving locations
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
        
        // Reverse geocodes the center of the screen
        // Could switch position.target to a custom location based on crosshairs or something
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView!, didTap marker: GMSMarker!) -> Bool {
        
        // Get small image from Firebase, show marker when it arrives
        let smallImageRef = root.child("smallImages/\(marker.title)")
        smallImageRef.observeSingleEvent(of: .value, with: { snapshot in
            marker.snippet = snapshot.value as! String
            mapView.selectedMarker = marker
        })
        
        // Center camera
        mapView.animate(toLocation: marker.position)

        return true
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        // Get Poogle info from dict
        let info = localPoogles[marker.title]
        
        let infoWindow: CustomInfoWindow = Bundle.main.loadNibNamed("InfoWindow", owner: self, options: nil)![0] as! CustomInfoWindow
        //infoWindow.nameLabel.text = info!["name"] as? String
        //infoWindow.userLabel.text = info!["creator"] as? String
        //infoWindow.setRating(Int((info!["rating"] as? Float)!))
        infoWindow.imageView.image = decodedImage(marker.snippet)
        
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let ref = root.child("/poogles/\(marker.title!)")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let poogleVC: PoogleViewController = storyboard.instantiateViewController(withIdentifier: "PoogleViewController") as! PoogleViewController
            
            // Set value of poogle's infoDict
            poogleVC.infoDict = snapshot.value as? NSDictionary
            
            self.present(poogleVC, animated: true, completion: nil)
            mapView.selectedMarker = nil
        })
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
