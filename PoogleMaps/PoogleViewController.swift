//
//  PoogleViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/7/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

class PoogleViewController: UIViewController {

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageLoadingActivityIndicator: UIActivityIndicatorView!
    
    var infoDict: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start loading icon
        imageLoadingActivityIndicator.startAnimating()
        
        // Create url string
        let urlStr: String = "https://poogle-maps.firebaseio.com/images/\(infoDict!["image"] as! String)"
        
        let imageRef = Firebase(url:urlStr)
        imageRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.topImageView.image = self.decodedImage(snapshot.value as! String)
            self.imageLoadingActivityIndicator.stopAnimating()
        })

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
