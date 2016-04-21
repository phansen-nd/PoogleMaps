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
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var upperButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var lowerButtonLabel: UILabel!
    @IBOutlet weak var lowerButton: UIButton!
    @IBOutlet weak var lowerContainerView: UIView!
    // Create a reference to a Firebase location
    var root = Firebase(url:"https://poogle-maps.firebaseio.com/")
    
    // Default to login mode for now
    var mode: Mode = .Login
    
    var hiddenSignUpConstraint: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        hiddenSignUpConstraint = confirmPasswordConstraint.constant
    }
    
    //
    // MARK: - IBActions
    //
    
    @IBAction func signInButtonTouched(sender: AnyObject) {
        
        if mode == .Login {
            root.authUser(emailTextField.text, password: passwordTextField.text, withCompletionBlock: { error, authData in
                
                if error != nil {
                    let alert = UIAlertController(title: "Whoops", message: "Error logging in: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
            })
        } else if mode == .Signup {
            
            // Make sure passwords match
            if passwordTextField.text != confirmPasswordTextField.text {
                let alert = UIAlertController(title: "Whoops", message: "Error signing up: the passwords you entered did not match!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            // Try creating a user, if successful, log them in
            root.createUser(emailTextField.text, password: passwordTextField.text, withValueCompletionBlock: { error, result in

                if error != nil {
                    let alert = UIAlertController(title: "Whoops", message: "Error signing up: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    
                    // Create a username based on email
                    let username = self.emailTextField.text?.componentsSeparatedByString("@")[0]
                    
                    // Create a user object in Firebase
                    let newUser: [String: AnyObject] = ["name": username!, "auth": result]
                    let newUserRef = self.root.childByAppendingPath("/users/\(result["uid"]!)")
                    newUserRef.setValue(newUser)
                    
                    // If sign up was a success, log the user in
                    self.root.authUser(self.emailTextField.text, password: self.passwordTextField.text, withCompletionBlock: { error, authData in
                    
                        if error != nil {
                            let alert = UIAlertController(title: "Whoops", message: "Error logging in: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                }
            
            })

        } else {
            print("Not in login or sign-up mode")
        }
        
    }

    @IBAction func toggleSignUpLogin(sender: AnyObject) {
    
        if mode == .Login {
            mode = .Signup
            passwordTextField.returnKeyType = .Next

            // Update button titles and labels
            self.upperLabel.text = "SIGN UP"
            self.upperButton.setTitle("Sign Up", forState: .Normal)
            self.middleButton.setTitle("", forState: .Normal)
            self.lowerButton.setTitle("Log in!", forState: .Normal)
            self.lowerButtonLabel.text = "Already signed up?"
            
            // Show confirm password text field
            self.confirmPasswordConstraint.constant = -2.0
            
            UIView.animateWithDuration(0.8, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
            
        } else  if mode == .Signup {
            mode = .Login
            passwordTextField.returnKeyType = .Done
            
            // Update button titles and labels
            self.upperLabel.text = "SIGN IN"
            self.upperButton.setTitle("Sign In", forState: .Normal)
            self.middleButton.setTitle("Forgot password?", forState: .Normal)
            self.lowerButton.setTitle("Sign up!", forState: .Normal)
            self.lowerButtonLabel.text = "Need an account?"
            
            // Hide confirm password text field
            self.confirmPasswordConstraint.constant = self.hiddenSignUpConstraint!
            
            UIView.animateWithDuration(0.8, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
            
        }
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // MARK: - TextFieldDelegate
    //
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField.tag == 1 {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField.tag == 2 && mode == .Signup {
            confirmPasswordTextField.becomeFirstResponder()
        }
        return true
    }
    
}

enum Mode {
    case Login
    case Signup
}
