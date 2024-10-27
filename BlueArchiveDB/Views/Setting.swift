//
//  Setting.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/01/11.
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit
import UserNotifications

class Setting: UIViewController
{
    var jsonArrays: [[String: Any]] = []
    @IBOutlet var HomeCharacter: UILabel!
    @IBOutlet var NotificationSettings: UILabel!
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        jsonArrays = Array(LoadFile.shared.getStudents().values)
        if let characterIdString = UserDefaults.standard.string(forKey: "CharacterID")
        {
            if let characterId = Int(characterIdString)
            {
                let matchingCharacters = jsonArrays.filter { $0["Id"] as? Int == characterId }
                HomeCharacter.text = matchingCharacters.first?["Name"] as? String
            }
        } else
        {
            let defaultCharacterId = 10066 // Assuming the default ID is an Int
            let matchingCharacters = jsonArrays.filter { $0["Id"] as? Int == defaultCharacterId }
            HomeCharacter.text = matchingCharacters.first?["Name"] as? String
        }
        updateNotificationSetting()
    }
    func updateNotificationSetting(){
        if let NotificationSetting = UserDefaults.standard.string(forKey: "NotificationSettings")
        {
            Logger.standard.debug("\(NotificationSetting)")
            if NotificationSetting == "true" {
                NotificationSettings.text = "許可"
            }else{
                NotificationSettings.text = "拒否"
            }
        } else
        {
            NotificationSettings.text = "拒否"
        }
    }
    
    @IBAction func BackButton(_: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "Home") as? ViewController
        {
            present(viewController, animated: false, completion: nil)
        } else
        {
            Logger.standard.fault("Error: Failed to instantiate CharacterSelect")
        }
    }
    
    @IBAction func CharacterSelectPagePresent(_: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "SettingCharacterSelect") as? SettingCharacterSelect
        {
            present(viewController, animated: false, completion: nil)
        }
    }
    @IBAction func toggleNotificationSettings(_: Any)
    {
        let NotificationSetting = UserDefaults.standard.string(forKey: "NotificationSettings")
        if NotificationSetting == "true" {
            UserDefaults.standard.set("false", forKey: "NotificationSettings")
            updateNotificationSetting()
        }else{
            center.getNotificationSettings { settings in
                // メインスレッドでの処理
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .notDetermined:
                        self.requestNotificationAuthorization()
                    case .denied:
                        if let url = URL(string: "App-Prefs:root=NOTIFICATIONS_ID&path=\(String(describing: Bundle.main.bundleIdentifier))") {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:]) { success in
                                    if !success {
                                        let alert = UIAlertController(title: "エラー", message: "設定を開けませんでした。\nTrollStoreを使用している場合は一時的にUser Registrationにして再度実行してください。", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            } else {
                                let success = UIApplication.shared.openURL(url)
                                if !success {
                                    let alert = UIAlertController(title: "エラー", message: "設定を開けませんでした。\nTrollStoreを使用している場合は一時的にUser Registrationにして再度実行してください。", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }

                    case .authorized:
                        UserDefaults.standard.set("true", forKey: "NotificationSettings")
                        self.updateNotificationSetting()
                    default:
                        ()
                    }
                }
            }
        }
    }
    func requestNotificationAuthorization() {
        // 通知センターのインスタンス
        let center = UNUserNotificationCenter.current()
        
        // 権限のリクエスト
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // メインスレッドでの処理
            DispatchQueue.main.async {
                if let error = error {
                    // エラーハンドリング
                    print("通知の権限取得エラー: \(error.localizedDescription)")
                } else if granted {
                    UserDefaults.standard.set("true", forKey: "NotificationSettings")
                    self.updateNotificationSetting()
                } else {
                    print("通知の権限が拒否されました。")
                }
            }
        }
    }
}
