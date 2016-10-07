//
//  LoginManager.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/6/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation
import Firebase


class LoginManager : NSObject, GIDSignInDelegate {
 
    // Create a reference to a Firebase location
    var root = FIRDatabase.database().reference()

    //
    // MARK: - GIDSignInDelegate functions.
    //
    
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
    
    //
    // MARK: - Custom login functions.
    //
    
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
    
    func signOut() {
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
    
    //
    // MARK: - Helper functions.
    //
    
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
