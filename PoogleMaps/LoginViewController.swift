//
//  LoginViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var upperLabel: UILabel!
    
    private var loginManager: LoginManager = LoginManager()
    
    // Create a reference to a Firebase location
    var root = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = loginManager
        
        // Configure sign-in button look/feel.
    }
    
    @IBAction func logoutButtonTouched(_ sender: AnyObject) {
        loginManager.signOut()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
