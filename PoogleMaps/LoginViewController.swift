//
//  LoginViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, GIDSignInUIDelegate, LoginManagerDelegate {

    @IBOutlet weak var upperLabel: UILabel!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var googleSignInView: GIDSignInButton!
    @IBOutlet weak var promiseLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    private var loginManager: LoginManager = LoginManager()
    
    // Create a reference to a Firebase location
    var root = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = loginManager
        
        loginManager.delegate = self
        
        // Configure sign-in button look/feel.
        googleSignInView.colorScheme = .dark
        
        // If someone's already logged in, update the view.
        if let firUser = FIRAuth.auth()?.currentUser {
            root.child("/users/\(firUser.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                self.loginManager.currentUser = User(withSnapshot: snapshot, andUID: firUser.uid)
                self.showUserView(with: self.loginManager.currentUser!)
            })
        }
    }
    
    func didSignInSuccessfully() {
        self.showUserView(with: self.loginManager.currentUser!)
    }
    
    @IBAction func logoutButtonTouched(_ sender: AnyObject) {
        loginManager.currentUser = nil
        loginManager.signOut {
            showLoginView()
            print("Signing out")
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Call after a user has signed in.
    // Precondition: user exists.
    func showUserView(with user: User) {
        
        flipViews()
        
        // Set image.
        profileImageView.image = user.profilePhoto
        
        // Set start date label.
        startDateLabel.text = "Poogling since \(user.dateJoined)."
        
        // Set name label.
        nameLabel.text = user.firstName
    }
    
    // Call after a user has signed out.
    func showLoginView() {
        flipViews()
    }
    
    func flipViews() {
        instructionLabel.isHidden = !instructionLabel.isHidden
        googleSignInView.isHidden = !googleSignInView.isHidden
        promiseLabel.isHidden = !promiseLabel.isHidden
        
        profileImageView.isHidden = !profileImageView.isHidden
        nameLabel.isHidden = !nameLabel.isHidden
        startDateLabel.isHidden = !startDateLabel.isHidden
        logoutButton.isHidden = !logoutButton.isHidden
    }
}
