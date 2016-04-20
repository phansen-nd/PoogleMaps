//
//  LoginViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Create a reference to a Firebase location
    var root = Firebase(url:"https://poogle-maps.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //
    // MARK: - IBActions
    //
    
    @IBAction func signInButtonTouched(sender: AnyObject) {
        /*
        if emailTextField.text == "" || passwordTextField.text == "" {
            return
        }*/
        
        root.authUser(emailTextField.text, password: passwordTextField.text, withCompletionBlock: { error, authData in
            
            if error != nil {
                let alert = UIAlertController(title: "Whoops", message: "Error logging in: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        })
        
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // MARK: - TextFieldDelegate
    //
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 1 {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else  if textField.tag == 2 {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
