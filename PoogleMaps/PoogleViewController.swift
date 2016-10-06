//
//  PoogleViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/7/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

class PoogleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var imageLoadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var infoDict: NSDictionary?
    var testimonialObserver: FIRDatabaseHandle?
    var attrDict: [String:[Float]] = ["clean": [], "spacious": [], "convenient": [], "secluded": []]
    var ratingCount = 0
    var ratings: [Float] = []
    var testimonials: [NSDictionary] = []
    
    // Create a reference to a Firebase location
    var root = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start loading icon
        imageLoadingActivityIndicator.startAnimating()
        
        // Load the image and stop the loading icon when finished
        let imageRef = root.child("/largeImages/\(infoDict!["largeImage"] as! String)")
        imageRef.observeSingleEvent(of: .value, with: { snapshot in
            self.topImageView.image = self.decodedImage(snapshot.value as! String)
            self.imageLoadingActivityIndicator.stopAnimating()
        })

        // Give top image shadow
        topImageView.layer.shadowColor = UIColor.black.cgColor
        topImageView.layer.shadowRadius = 10
        topImageView.layer.shadowOpacity = 1.0
        topImageView.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        // Add swipe to dismiss gesture
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(PoogleViewController.swipedDown(_:)))
        swipeDown.direction = .down
        topImageView.addGestureRecognizer(swipeDown)
        
        // Set listener for attributes to account for new testimonials
        let attrRef = root.child("/testimonials/\(infoDict!["name"] as! String)")
        testimonialObserver = attrRef.observe(.childAdded, with: { snapshot in
            
            // Update attributes
            //let dict = snapshot.value["attributes"] as! [String:Float]
            //self.attrDict["clean"]?.append(dict["clean"]! as Float)
            //self.attrDict["spacious"]?.append(dict["spacious"]! as Float)
            //self.attrDict["convenient"]?.append(dict["convenient"]! as Float)
            //self.attrDict["secluded"]?.append(dict["secluded"]! as Float)
            
            // Update rating and ratings count
            self.ratingCount += 1
            //self.ratings.append(snapshot.value!["rating"] as! Float)
            
            // Add whole object to a local store
            self.testimonials.append(snapshot.value as! NSDictionary)
            
            self.tableView.reloadData()
        })
    }
    
    // Reload whenever we return from adding a testimonial so we can see it
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // Remove Firebase observers on unload
    deinit {
        root.removeObserver(withHandle: testimonialObserver!)
    }
    
    //
    // MARK: - Helper functions
    //
    
    func decodedImage (_ str: String) -> UIImage {
        let decodedData = Data(base64Encoded: str, options: .ignoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData!)
        
        return decodedImage!
    }
    
    //
    // MARK: - Gesture Recognizer Actions
    //
    
    func swipedDown(_ recognizer: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    //
    // MARK: - TableViewDelegate
    //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return testimonials.count
        default:
            return 0
        }
    }
    
    // Hard code alert!!!!!!!!!!!!!!!!!!!!!
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return 160
        default:
            return 140
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Hard code alert!!!!!!!!!!!!!!!!!!!!!
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "Testimonials"
        default:
            return "Default"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Add a basic info cell on top and all testimonial cells underneath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var basicCell: PoogleBasicInfoTableViewCell
        var testimonialCell: TestimonialTableViewCell
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            // Load basic info from Poogle and testimonial averages
            basicCell = tableView.dequeueReusableCell(withIdentifier: "basicInfo", for: indexPath) as! PoogleBasicInfoTableViewCell
            basicCell.nameLabel.text = infoDict!["name"] as? String
            basicCell.genderLabel.text = infoDict!["gender"] as? String
            basicCell.userLabel.text = infoDict!["creator"] as? String
            basicCell.setRating((infoDict!["rating"] as? Int)!)
            basicCell.setAttributes(attrDict)
            basicCell.setRatingCount(self.ratingCount)
            basicCell.updateRating(ratings)
            return basicCell
        case 1:
            // Load testimonials from the local store
            testimonialCell = tableView.dequeueReusableCell(withIdentifier: "testimonial")! as! TestimonialTableViewCell
            testimonialCell.titleLabel.text = testimonials[(indexPath as NSIndexPath).row]["title"] as? String
            testimonialCell.commentTextView.text = testimonials[(indexPath as NSIndexPath).row]["comment"] as? String
            testimonialCell.userLabel.text = testimonials[(indexPath as NSIndexPath).row]["creator"] as? String
            return testimonialCell
        default:
            basicCell = tableView.dequeueReusableCell(withIdentifier: "basicInfo", for: indexPath) as! PoogleBasicInfoTableViewCell
            return basicCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.black.withAlphaComponent(0.7)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }

    //
    // MARK: - Navigation
    //

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addTestimonial" {
            // Check for user
            if FIRAuth.auth()?.currentUser == nil {
                // No user - warn and return
                let alert = UIAlertController(title: "Whoops", message: "You have to be logged in to add a Testimonial!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Pass the relevant info about the Poogle to the new VC
        let dest: AddTestimonialViewController = segue.destination as! AddTestimonialViewController
        dest.name = (infoDict!["name"] as? String)!
        dest.previousRatings = ratings
    }

}
