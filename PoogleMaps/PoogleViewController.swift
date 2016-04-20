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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start loading icon
        imageLoadingActivityIndicator.startAnimating()
        
        // Create url string
        let urlStr: String = "https://poogle-maps.firebaseio.com/largeImages/\(infoDict!["largeImage"] as! String)"
        
        let imageRef = Firebase(url:urlStr)
        imageRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.topImageView.image = self.decodedImage(snapshot.value as! String)
            self.imageLoadingActivityIndicator.stopAnimating()
        })

        // Set image background
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "blue-back")!)        
        
        // Add swipe to dismiss gesture
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(PoogleViewController.swipedDown(_:)))
        swipeDown.direction = .Down
        topImageView.addGestureRecognizer(swipeDown)
        
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
            // Ultimately return count of [Testimonials]
            return 5
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 140
        default:
            return 160
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Eventually, if indexpath is greater than 0, launch testimonial VC
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var basicCell: PoogleBasicInfoTableViewCell
        var testimonialCell: TestimonialTableViewCell
        
        switch indexPath.section {
        case 0:
            basicCell = tableView.dequeueReusableCellWithIdentifier("basicInfo", forIndexPath: indexPath) as! PoogleBasicInfoTableViewCell
            basicCell.nameLabel.text = infoDict!["name"] as? String
            basicCell.genderLabel.text = infoDict!["gender"] as? String
            basicCell.userLabel.text = infoDict!["creator"] as? String
            basicCell.setRating((infoDict!["rating"] as? Int)!)
            return basicCell
        case 1:
            testimonialCell = tableView.dequeueReusableCellWithIdentifier("testimonial")! as! TestimonialTableViewCell
            return testimonialCell
        default:
            basicCell = tableView.dequeueReusableCellWithIdentifier("basicInfo", forIndexPath: indexPath) as! PoogleBasicInfoTableViewCell
            return basicCell
        }
    }

    /*
    //
    // MARK: - Navigation
    //

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
