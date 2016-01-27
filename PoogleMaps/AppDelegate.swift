//
//  AppDelegate.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 1/26/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios/guide#local-datastore
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("M4m6JzD1LQZtY8xcbdZwwkNhAzNPr91GWlPepqIm",
            clientKey: "zlf7PPPz2nGUriSYGdLu3iyu4muidvTMT3FPm426")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        return true
    }
}

