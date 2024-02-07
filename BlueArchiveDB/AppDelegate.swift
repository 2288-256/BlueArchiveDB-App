//
//  AppDelegate.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/22.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import UIKit
import CoreSpotlight

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            let uniqueIdentifier = userActivity.userInfo? [CSSearchableItemActivityIdentifier] as? String
            print(uniqueIdentifier)
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

