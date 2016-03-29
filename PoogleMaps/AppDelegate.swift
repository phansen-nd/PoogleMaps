//
//  AppDelegate.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 1/26/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        GMSServices.provideAPIKey("AIzaSyBiOMNxLyvyRJtM0a5Y8VfDLjrceVCX9GI")
        
        return true
    }
}

