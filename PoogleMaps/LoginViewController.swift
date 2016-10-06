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

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailConstraint: NSLayoutConstraint!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var upperButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var lowerButtonLabel: UILabel!
    @IBOutlet weak var lowerButton: UIButton!
    @IBOutlet weak var lowerContainerView: UIView!
    
    // Create a reference to a Firebase location
    var root = FIRDatabase.database().reference()
    
    // Default to login mode for now
    var mode: Mode = .login
    
    var hiddenSignUpConstraint: CGFloat?
    var hiddenEmailConstraint: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        hiddenSignUpConstraint = confirmPasswordConstraint.constant
        hiddenEmailConstraint = emailConstraint.constant
    }
    
    //
    // MARK: - IBActions
    //
    
    @IBAction func signInButtonTouched(_ sender: AnyObject) {
        
        if mode == .login {
            FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { user, error in
                
                // May need to do something with user?
                
                if error != nil {
                    let alert = UIAlertController(title: "Whoops", message: "Error logging in: \(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
        } else if mode == .signup {
            
            // Make sure passwords match
            if passwordTextField.text != confirmPasswordTextField.text {
                let alert = UIAlertController(title: "Whoops", message: "Error signing up: the passwords you entered did not match!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Try creating a user, if successful, log them in
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { user, error in

                if error != nil {
                    let alert = UIAlertController(title: "Whoops", message: "Error signing up: \(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    // Create a username based on email
                    let username = self.emailTextField.text?.components(separatedBy: "@")[0]
                    
                    // Create a user object in Firebase
                    let newUser: [String: AnyObject] = ["name": username! as AnyObject, "auth": user!]
                    let newUserRef = self.root.child("/users/\(user?.uid)")
                    newUserRef.setValue(newUser)
                    
                    // If sign up was a success, log the user in
                    FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { user, error in
                        
                        if error != nil {
                            let alert = UIAlertController(title: "Whoops", message: "Error logging in: \(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            
            })

        } else {
            print("Not in login or sign-up mode")
        }
        
    }

    @IBAction func toggleSignUpLogin(_ sender: AnyObject) {
    
        if mode == .login {
            mode = .signup
            passwordTextField.returnKeyType = .next

            // Update button titles and labels
            self.upperLabel.text = "SIGN UP"
            self.upperButton.setTitle("Sign Up", for: UIControlState())
            self.middleButton.setTitle("", for: UIControlState())
            self.lowerButton.setTitle("Log in!", for: UIControlState())
            self.lowerButtonLabel.text = "Already signed up?"
            
            // Show confirm password text field
            self.confirmPasswordConstraint.constant += 42
            self.emailConstraint.constant -= 42
            
            UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
            
                self.confirmPasswordTextField.alpha = 1.0
                self.emailTextField.alpha = 1.0
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
            
        } else  if mode == .signup {
            mode = .login
            passwordTextField.returnKeyType = .done
            
            // Update button titles and labels
            self.upperLabel.text = "SIGN IN"
            self.upperButton.setTitle("Sign In", for: UIControlState())
            self.middleButton.setTitle("Forgot password?", for: UIControlState())
            self.lowerButton.setTitle("Sign up!", for: UIControlState())
            self.lowerButtonLabel.text = "Need an account?"
            
            // Hide confirm password text field
            self.confirmPasswordConstraint.constant -= 42
            self.emailConstraint.constant += 42
            
            UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
            
                self.emailTextField.alpha = 0.0
                self.confirmPasswordTextField.alpha = 0.0
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
            
        }
        
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //
    // MARK: - TextFieldDelegate
    //
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField.tag == 1 {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField.tag == 2 && mode == .signup {
            confirmPasswordTextField.becomeFirstResponder()
        }
        return true
    }
    
}

enum Mode {
    case login
    case signup
}
