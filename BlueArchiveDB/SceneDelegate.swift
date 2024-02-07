//
//  SceneDelegate.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/22.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import UIKit
import CoreSpotlight

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print(userActivity.activityType)
        if userActivity.activityType == CSSearchableItemActionType {
            let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as! String
            print("uniqueIdentifier: \(uniqueIdentifier)")
            presentCharacterInfoViewController(with: uniqueIdentifier)
        } else if userActivity.activityType == CSQueryContinuationActionType {
            if let searchQuery = userActivity.userInfo?[CSSearchQueryString] as? String {
                print("「\(searchQuery)」で検索してたよ")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterSelect") as? CharacterSelect {
                    viewController.SearchString = searchQuery
                    viewController.modalTransitionStyle = .crossDissolve
                    viewController.modalPresentationStyle = .fullScreen
                    self.window?.rootViewController = viewController
                    self.window?.makeKeyAndVisible()
                }
            }
        }
    }
    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        print("URL Contexts: \(urlContexts)")
        guard let url = urlContexts.first?.url else {
            // No URL found
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            // Invalid URL
            return
        }
        
        let host = components.host
        
        switch host {
        case "home":
            // Home button pressed
            presentHomeViewController()
            
        default:
            break
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func presentHomeViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "Home") as? ViewController {
            window?.rootViewController = viewController
        } else {
            print("Error: Failed to instantiate HomeViewController")
        }
    }
    
    private func presentCharacterInfoViewController(with uniqueIdentifier: String) {
        print("uniqueIdentifier Func: \(uniqueIdentifier)")
        //もしunitIdが"studentData_"から始まる場合は
        if uniqueIdentifier.hasPrefix("studentData_") {
            //uniqueIdentifierの値のstudentData_以降の値を取得する
            let studentId = Int(uniqueIdentifier.dropFirst("studentData_".count))
            print("studentId: \(studentId)")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterInfo") as? CharacterInfo {
                viewController.unitId = studentId!
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .fullScreen
                self.window?.rootViewController = viewController
                self.window?.makeKeyAndVisible()
            }
        }
        
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
            // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
            // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
            guard let _ = (scene as? UIWindowScene) else { return }
        }
        
        func sceneDidDisconnect(_ scene: UIScene) {
            // Called as the scene is being released by the system.
            // This occurs shortly after the scene enters the background, or when its session is discarded.
            // Release any resources associated with this scene that can be re-created the next time the scene connects.
            // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        }
        
        func sceneDidBecomeActive(_ scene: UIScene) {
            // Called when the scene has moved from an inactive state to an active state.
            // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        }
        
        func sceneWillResignActive(_ scene: UIScene) {
            // Called when the scene will move from an active state to an inactive state.
            // This may occur due to temporary interruptions (ex. an incoming phone call).
        }
        
        func sceneWillEnterForeground(_ scene: UIScene) {
            // Called as the scene transitions from the background to the foreground.
            // Use this method to undo the changes made on entering the background.
        }
        
        func sceneDidEnterBackground(_ scene: UIScene) {
            // Called as the scene transitions from the foreground to the background.
            // Use this method to save data, release shared resources, and store enough scene-specific state information
            // to restore the scene back to its current state.
        }
        
        
    }
    
}
