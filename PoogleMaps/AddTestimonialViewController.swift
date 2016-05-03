//
//  AddTestimonialViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/25/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

class AddTestimonialViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    
    // Rating view
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    // Sliders
    @IBOutlet weak var cleanlinessSlider: UISlider!
    @IBOutlet weak var seclusionSlider: UISlider!
    @IBOutlet weak var convenienceSlider: UISlider!
    @IBOutlet weak var spaciousnessSlider: UISlider!
    
    var name: String = ""
    var currentRating = 0
    var initial: Bool = false
    var previousRatings: [Float] = []
    
    var root = Firebase(url:"https://poogle-maps.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name
        textView.delegate = self
        addToolBar(textView)
        textField.delegate = self
    }

    //
    // MARK: - TextViewDelegate
    //
    
    func textViewDidBeginEditing(textView: UITextView) {
        // Essentially make "Add a comment..." function as placeholder text
        if textView.text == "Add a comment..." {
            textView.text = ""
        }
    }
    
    //
    // MARK: - TextFieldDelegate
    //
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //
    // MARK: - Helper functions
    //
    
    // Add a tool bar to enable Done button that exits editing in TextView
    func addToolBar(textView: UITextView) {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .Default
        toolBar.translucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(AddTestimonialViewController.donePressed))
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        
        textView.inputAccessoryView = toolBar
    }
    
    func donePressed() {
        textView.endEditing(true)
    }
    
    func setRating (rating: Int) {
        
        star1.image = UIImage(named: "star-empty")
        star2.image = UIImage(named: "star-empty")
        star3.image = UIImage(named: "star-empty")
        star4.image = UIImage(named: "star-empty")
        star5.image = UIImage(named: "star-empty")
        
        if rating >= 1 {
            star1.image = UIImage(named: "star")
            if rating >= 2 {
                star2.image = UIImage(named: "star")
                if rating >= 3 {
                    star3.image = UIImage(named: "star")
                    if rating >= 4 {
                        star4.image = UIImage(named: "star")
                        if rating >= 5 {
                            star5.image = UIImage(named: "star")
                            
                        }
                    }
                }
            }
        }
    }
    
    //
    // MARK: - IB Actions
    //
    
    // Check for touch in rating view and set accordingly
    @IBAction func ratingsViewTouched(sender: AnyObject) {
    
        let w = sender.view?.frame.width
        
        if sender.locationInView(sender.view).x < w!/5 {
            setRating(1)
            currentRating = 1
        } else if sender.locationInView(sender.view).x < 2*w!/5 {
            setRating(2)
            currentRating = 2
        } else if sender.locationInView(sender.view).x < 3*w!/5 {
            setRating(3)
            currentRating = 3
        } else if sender.locationInView(sender.view).x < 4*w!/5 {
            setRating(4)
            currentRating = 4
        } else {
            setRating(5)
            currentRating = 5
        }
    
    }
    
    @IBAction func cancelButtonTouched(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func testifyButtonPressed(sender: AnyObject) {
    
        // Validate fields
        if textField.text == "" || textView.text == "" || textView.text == "Add a comment..." || currentRating == 0 {
            let alert = UIAlertController(title: "Whoops", message: "All fields are required to submit a Testimonial!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // Create a Testimonial Object
        //
        // Get username
        var username = ""
        let newref = self.root.childByAppendingPath("/users/\(root.authData.uid)")
        newref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let dict = snapshot.value as! NSDictionary? {
                username = dict["name"] as! String
                
                // Get attribute values
                let attr = ["clean": self.cleanlinessSlider.value, "secluded": self.seclusionSlider.value, "convenient": self.convenienceSlider.value, "spacious": self.spaciousnessSlider.value]
                
                // Create the rest of the object
                let testimonial = Testimonial(creator: username, title: self.textField.text!, subject: self.name, attributes: attr, rating: Float(self.currentRating), comment: self.textView.text!)
                
                // Upload object to Firebase
                // Upload to Firebase
                let newRef = self.root.childByAppendingPath("testimonials/\(self.name)/\(self.textField.text!)")
                newRef.setValue(testimonial.toDict())
            }
        })
        
        // Set Poogle initial rating or update considering all previous ratings
        let poogleRef = self.root.childByAppendingPath("/poogles/\(name)/rating")
    
        if initial {
            poogleRef.setValue(currentRating)
        } else {
            previousRatings.append(Float(currentRating))
            var avg: Float = 0.0
            for num in previousRatings {
                avg += num
            }
            avg /= Float(previousRatings.count)
            
            poogleRef.setValue(avg)
        }
        
        // Dismiss the view
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
}
