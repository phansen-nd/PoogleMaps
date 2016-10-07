//
//  LoginViewController.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 4/20/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var upperLabel: UILabel!
    
    // Create a reference to a Firebase location
    var root = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Configure sign-in button look/feel.
    }
    
    @IBAction func logoutButtonTouched(_ sender: AnyObject) {
        if (FIRAuth.auth()?.currentUser) != nil {
            // Logout
            do {
                try FIRAuth.auth()!.signOut()
            } catch let error {
                print("Error signing out: \(error.localizedDescription)")
                return
            }
            print("Successfully signed out.")
            GIDSignIn.sharedInstance().signOut()
        } else {
            print("No one was signed in.")
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error signing in to Google: \(error.localizedDescription)")
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        
        // Got Google credential, send to Firebase for login in-app.
        firebaseLogin(with: credential)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error disconnecting: \(error.localizedDescription)")
            return
        }
        print("User \(user) disconnected.")
        
    }
    
    func firebaseLogin(with credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            
            guard let user = user else {
                print("Error gettinguser from sign-in.")
                return
            }
            
            print("Successful sign in for \(user.displayName!)")
            
            // Store user info in database.
            // Only do this first time.
            self.root.child("users/\(user.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    print("User info already stored.")
                } else {
                    print("User info doesn't exist, store it.")
                    self.storeUserInfoInDatabase(with: user)
                }
            })
        }
    }
    
    func storeUserInfoInDatabase(with user: FIRUser) {
        for profile in user.providerData {
            let providerID = profile.providerID
            let uid = profile.uid
            let name = profile.displayName
            let email = profile.email
            let photoURL = profile.photoURL
            let appDisplayName = self.getDisplayName(with: name!)
            
            print("\(providerID) info for \(name!):\nEmail address: \(email!)\nURL for photo: \(photoURL!)\nUID: \(uid)\nPoogle display name: \(appDisplayName)")
            
            let newUser: [String:String] = ["name": name!, "providerUID": uid, "email": email!, "photoURL": "\(photoURL!)", "displayName": appDisplayName]
            let newUserRef = self.root.child("/users/\(user.uid)")
            newUserRef.setValue(newUser)
        }
    }
    
    func getDisplayName(with name: String) -> String {
        
        let arr = name.components(separatedBy: " ")
        let appName = "\(arr[0]) \(arr[1].characters.first!)"
        
        return appName
    }
}
