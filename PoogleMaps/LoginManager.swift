//
//  LoginManager.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/6/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation
import Firebase

protocol LoginManagerDelegate {
    func didSignInSuccessfully()
}

class LoginManager : NSObject, GIDSignInDelegate {
 
    var delegate: LoginManagerDelegate?
    var currentUser: User?
    var root = FIRDatabase.database().reference()
    
    private var dataDownloader = DataDownloader()
    private var fileSaver = FileSaver()

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
                    
                    // User info stored already, repeat sign-in.
                    // Grab data and update current user object.
                    if let firUser = FIRAuth.auth()?.currentUser {
                        self.root.child("/users/\(firUser.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                            self.currentUser = User(withSnapshot: snapshot, andUID: firUser.uid)
                            self.currentUser?.profilePhoto = self.fileSaver.loadImage(named: firUser.uid)
                            self.delegate?.didSignInSuccessfully()
                        })
                    }
                } else {
                    
                    print("User info doesn't exist, store it.")
                    
                    // User info doesn't exist yet, first time sign-in.
                    // Data will already be stored in current user object from the function below,
                    //  so no need to fetch it from Firebase. Nice!
                    self.storeUserInfoInDatabase(with: user) {
                        self.delegate?.didSignInSuccessfully()
                    }
                    
                    // TODO: Something awesome welcoming the person!
                }
            })
        }
    }
    
    func signOut(withCompletion completion: () -> Void) {
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
            
            // Do whatever the caller wants done (probably to the UI).
            completion()
        } else {
            print("No one was signed in.")
        }
    }
    
    //
    // MARK: - Helper functions.
    //
    
    func storeUserInfoInDatabase(with user: FIRUser, completion: @escaping () -> Void) {
        for profile in user.providerData {
            let providerID = profile.providerID
            let uid = profile.uid
            let name = profile.displayName
            let email = profile.email
            let photoURL = profile.photoURL
            let appDisplayNames = self.getDisplayNames(with: name!)
            let dateString = self.getFormattedDate()
            
            // Debug info.
            print("\(providerID) info for \(name!):\nEmail address: \(email!)\nURL for photo: \(photoURL!)\nUID: \(uid)\nPoogle display name: \(appDisplayNames[0]), firstName: \(appDisplayNames[1]), dateJoined: \(dateString)")
            
            // Download and store the profile photo locally for easy access. Everything else
            //  should wait until it's safely saved (or not) to continue.
            dataDownloader.downloadAndSaveImage(withURL: photoURL!, name: user.uid) {
            
                // Create a user (dictionary of strings) and store in the database.
                let newUser: [String:String] = ["name": name!, "providerUID": uid, "email": email!, "photoURL": "\(photoURL!)", "displayName": appDisplayNames[0], "firstName": appDisplayNames[1], "dateJoined": dateString]
                let newUserRef = self.root.child("/users/\(user.uid)")
                newUserRef.setValue(newUser)
                
                // Create current user for access from Login VC.
                self.currentUser = User(withData: newUser, andUID: user.uid)
                self.currentUser?.profilePhoto = self.fileSaver.loadImage(named: user.uid)
                
                // Execute the completion so UI can be updated right away.
                // It's going to be UI, so make sure it's on main thread.
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func getDisplayNames(with name: String) -> [String] {
        
        let arr = name.components(separatedBy: " ")
        let appName = "\(arr[0]) \(arr[1].characters.first!)"
        let firstName = arr[0]
        return [appName, firstName]
    }
    
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        
        let dateString = formatter.string(from: Date())
        
        return dateString
    }
}
