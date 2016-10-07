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
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var googleSignInView: GIDSignInButton!
    @IBOutlet weak var promiseLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var encapsulatingView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var loginManager: LoginManager = LoginManager()
    private var fileSaver: FileSaver = FileSaver()
    
    var root = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = loginManager
        
        loginManager.delegate = self
        
        // Configure sign-in button look/feel.
        googleSignInView.colorScheme = .dark
        
        encapsulatingView.layer.shadowColor = UIColor.black.cgColor
        
        // If someone's already logged in, update the view.
        if let firUser = FIRAuth.auth()?.currentUser {
            activityIndicatorView.startAnimating()
            
            // Get data from Firebase.
            root.child("/users/\(firUser.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                // Create user.
                self.loginManager.currentUser = User(withSnapshot: snapshot, andUID: firUser.uid)
                
                // Get image from phone and store in user object.
                // (If they're already logged in, it's already downloaded.)
                self.loginManager.currentUser?.profilePhoto = self.fileSaver.loadImage(named: firUser.uid)
                
                self.showUserView(with: self.loginManager.currentUser!)
                self.activityIndicatorView.stopAnimating()
            })
        }
    }
    
    func didSignInSuccessfully() {
        self.showUserView(with: self.loginManager.currentUser!)
        activityIndicatorView.stopAnimating()
    }
    
    @IBAction func logoutButtonTouched(_ sender: AnyObject) {
        loginManager.currentUser = nil
        activityIndicatorView.startAnimating()
        loginManager.signOut {
            
            // Make this wait a second so the user feels like they're actually logged out.
            let dispatchTime = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.activityIndicatorView.stopAnimating()
                self.showLoginView()
                print("Signing out")
            })
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        activityIndicatorView.stopAnimating()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func googleLoginButtonTouched(_ sender: AnyObject) {
        activityIndicatorView.startAnimating()
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
        encapsulatingView.isHidden = !encapsulatingView.isHidden
    }
}
