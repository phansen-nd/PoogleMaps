//
//  AppDelegate.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 1/26/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var root: FIRDatabaseReference?

    override init() {
        super.init()
        
        FIRApp.configure()
        
        // Disable offline persistence until testing is done and data is complete.
        FIRDatabase.database().persistenceEnabled = false
        root = FIRDatabase.database().reference()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            let gmsApiKey = dict["GMS_API_KEY"] as! String
            GMSServices.provideAPIKey(gmsApiKey)
        } else {
            print("Error connecting to API")
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
}

