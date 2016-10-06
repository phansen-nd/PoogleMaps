//
//  LoginViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var upperLabel: UILabel!
    
    // Create a reference to a Firebase location
    var root = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Configure sign-in button look/feel.
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func signOut() {
        if (FIRAuth.auth()?.currentUser) != nil {
            // Logout
            try! FIRAuth.auth()!.signOut()
            
        }
    }
}
