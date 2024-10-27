//
//  AppDelegate.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/22.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import CoreSpotlight
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    private func application(application _: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler _: ([AnyObject]?) -> Void) -> Bool
    {
        if userActivity.activityType == CSSearchableItemActionType
        {
            let uniqueIdentifier = userActivity.userInfo? [CSSearchableItemActivityIdentifier] as? String
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>)
    {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // アプリ起動時に一度だけ実行する処理
        checkDBFile()
        return true
    }
    func checkDBFile(){
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let studentsFileURL = libraryDirectory.appendingPathComponent("assets/data/jp/students.min.json")
        if !fileManager.fileExists(atPath: studentsFileURL.path)
        {
            let alert = UIAlertController(title: "エラー", message: "DBファイルが見つかりませんでした。\nデータを今すぐダウンロードしますか？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
                NotificationCenter.default.post(name: Notification.Name("DownloadDatabase"), object: nil)
            }))
            alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                if let topController = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last?.rootViewController {
                    topController.present(alert, animated: true, completion: nil)
                }
                
            }
        }else{
            fetchBuildFromRemote { remoteBuild in
                guard let remoteBuild = remoteBuild else {
                    Logger.standard.fault("Failed to fetch remote build")
                    return
                }
                
                self.fetchBuildFromLocalFile { localBuild in
                    guard let localBuild = localBuild else {
                        Logger.standard.fault("Failed to fetch local build")
                        return
                    }
                    
                    // 比較
                    if remoteBuild > localBuild {
                        let alert = UIAlertController(title: "更新", message: "DBファイルが更新されています。\nデータを今すぐ更新しますか？", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
                            NotificationCenter.default.post(name: Notification.Name("DownloadDatabase"), object: nil)
                        }))
                        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
                        DispatchQueue.main.async {
                            if let topController = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).last?.rootViewController {
                                topController.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                
            }
        }
    }
    // Buildの取得
    func fetchBuildFromRemote(completion: @escaping (Int?) -> Void) {
        let url = URL(string: "https://schaledb.com/data/config.min.json")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                Logger.standard.fault("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let build = json["build"] as? Int {
                    completion(build)
                } else {
                    completion(nil)
                }
            } catch {
                Logger.standard.fault("Error parsing JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // ローカルファイルからBuildを取得
    func fetchBuildFromLocalFile(completion: @escaping (Int?) -> Void) {
        let fileURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("assets/data/config.min.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let build = json["build"] as? Int {
                completion(build)
            } else {
                completion(nil)
            }
        } catch {
            print("Error reading local file: \(error.localizedDescription)")
            completion(nil)
        }
    }
}
