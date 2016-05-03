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
    var testimonialObserver: FirebaseHandle?
    var attrDict: [String:[Float]] = ["clean": [], "spacious": [], "convenient": [], "secluded": []]
    var ratingCount = 0
    var ratings: [Float] = []
    var testimonials: [NSDictionary] = []
    
    // Create a reference to a Firebase location
    var root = Firebase(url:"https://poogle-maps.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start loading icon
        imageLoadingActivityIndicator.startAnimating()
        
        // Create url string
        let urlStr: String = "https://poogle-maps.firebaseio.com/largeImages/\(infoDict!["largeImage"] as! String)"
        
        // Load the image and stop the loading icon when finished
        let imageRef = Firebase(url:urlStr)
        imageRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.topImageView.image = self.decodedImage(snapshot.value as! String)
            self.imageLoadingActivityIndicator.stopAnimating()
        })

        // Give top image shadow
        topImageView.layer.shadowColor = UIColor.blackColor().CGColor
        topImageView.layer.shadowRadius = 10
        topImageView.layer.shadowOpacity = 1.0
        topImageView.layer.shadowOffset = CGSizeMake(5, 5)
        
        // Add swipe to dismiss gesture
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(PoogleViewController.swipedDown(_:)))
        swipeDown.direction = .Down
        topImageView.addGestureRecognizer(swipeDown)
        
        // Set listener for attributes to account for new testimonials
        let attrRef = root.childByAppendingPath("/testimonials/\(infoDict!["name"] as! String)")
        testimonialObserver = attrRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            
            // Update attributes
            let dict = snapshot.value["attributes"] as! [String:Float]
            self.attrDict["clean"]?.append(dict["clean"]! as Float)
            self.attrDict["spacious"]?.append(dict["spacious"]! as Float)
            self.attrDict["convenient"]?.append(dict["convenient"]! as Float)
            self.attrDict["secluded"]?.append(dict["secluded"]! as Float)
            
            // Update rating and ratings count
            self.ratingCount += 1
            self.ratings.append(snapshot.value["rating"] as! Float)
            
            // Add whole object to a local store
            self.testimonials.append(snapshot.value as! NSDictionary)
            
        })
    }
    
    // Reload whenever we return from adding a testimonial so we can see it
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    // Remove Firebase observers on unload
    deinit {
        root.removeObserverWithHandle(testimonialObserver!)
    }
    
    //
    // MARK: - Helper functions
    //
    
    func decodedImage (str: String) -> UIImage {
        let decodedData = NSData(base64EncodedString: str, options: .IgnoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData!)
        
        return decodedImage!
    }
    
    //
    // MARK: - Gesture Recognizer Actions
    //
    
    func swipedDown(recognizer: UISwipeGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // MARK: - TableViewDelegate
    //
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 160
        default:
            return 140
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Hard code alert!!!!!!!!!!!!!!!!!!!!!
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "Testimonials"
        default:
            return "Default"
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    // Add a basic info cell on top and all testimonial cells underneath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var basicCell: PoogleBasicInfoTableViewCell
        var testimonialCell: TestimonialTableViewCell
        
        switch indexPath.section {
        case 0:
            // Load basic info from Poogle and testimonial averages
            basicCell = tableView.dequeueReusableCellWithIdentifier("basicInfo", forIndexPath: indexPath) as! PoogleBasicInfoTableViewCell
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
            testimonialCell = tableView.dequeueReusableCellWithIdentifier("testimonial")! as! TestimonialTableViewCell
            testimonialCell.titleLabel.text = testimonials[indexPath.row]["title"] as? String
            testimonialCell.commentTextView.text = testimonials[indexPath.row]["comment"] as? String
            testimonialCell.userLabel.text = testimonials[indexPath.row]["creator"] as? String
            return testimonialCell
        default:
            basicCell = tableView.dequeueReusableCellWithIdentifier("basicInfo", forIndexPath: indexPath) as! PoogleBasicInfoTableViewCell
            return basicCell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
    }

    //
    // MARK: - Navigation
    //

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "addTestimonial" {
            // Check for user
            if root.authData == nil {
                // No user - warn and return
                let alert = UIAlertController(title: "Whoops", message: "You have to be logged in to add a Testimonial!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Pass the relevant info about the Poogle to the new VC
        let dest: AddTestimonialViewController = segue.destinationViewController as! AddTestimonialViewController
        dest.name = (infoDict!["name"] as? String)!
        dest.previousRatings = ratings
    }

}
