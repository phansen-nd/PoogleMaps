//
//  AddTestimonialViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/25/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit

class AddTestimonialViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    
    var name: String = ""
    
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
    
    //
    // MARK: - IB Actions
    //
    
    @IBAction func testifyButtonPressed(sender: AnyObject) {
    
        // Validate fields
        
        
        // Create a Testimonial Object
        
        
        // Dismiss the view
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
}
