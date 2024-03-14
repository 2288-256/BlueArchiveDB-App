//
//  CharacterProfilePage.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/12/01.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import UIKit
import Foundation
import SwiftSoup
import Reachability

class CharacterProfilePage: UIViewController {
    let reachability = try! Reachability()
    var unitId: Int = 100
    var jsonArrays: [[String: Any]] = []
    var AcquisitionMethodText:String = "取得できませんでした"
    @IBOutlet weak var CharacterProfileText: UITextView!
    //キャラクターの入手方法を記載するUITextView
    @IBOutlet weak var CharacterAcquisitionMethodText: UITextView!
    @IBOutlet weak var CharacterSchoolText: UILabel!
    @IBOutlet weak var CharacterSchoolYear: UILabel!
    @IBOutlet weak var CharacterClub: UILabel!
    @IBOutlet weak var CharacterAge: UILabel!
    @IBOutlet weak var CharacterBirthday:UILabel!
    @IBOutlet weak var CharacterCharHeightMetric: UILabel!
    @IBOutlet weak var CharacterHobby: UILabel!
    @IBOutlet weak var CharacterDesigner: UILabel!
    @IBOutlet weak var CharacterIllustrator: UILabel!
    @IBOutlet weak var CharacterCharacterVoice: UILabel!
    @IBOutlet weak var CharacterWeaponType: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        CharacterProfileText.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        CharacterAcquisitionMethodText.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        let matchingStudents = jsonArrays.filter { $0["Id"] as? Int == unitId }
        CharacterProfileText.text = matchingStudents.first?["ProfileIntroduction"] as? String
        CharacterSchoolText.text = translateString((matchingStudents.first?["School"])! as! String, mainKey: "SchoolLong")
        CharacterSchoolYear.text = matchingStudents.first?["SchoolYear"] as? String
        CharacterClub.text = translateString((matchingStudents.first?["Club"])! as! String)
        CharacterAge.text = matchingStudents.first?["CharacterAge"] as? String
        CharacterBirthday.text = matchingStudents.first?["Birthday"] as? String
        CharacterCharHeightMetric.text = matchingStudents.first?["CharHeightMetric"] as? String
        CharacterHobby.text = matchingStudents.first?["Hobby"] as? String
        CharacterDesigner.text = matchingStudents.first?["Designer"] as? String
        CharacterIllustrator.text = matchingStudents.first?["Illustrator"] as? String
        CharacterCharacterVoice.text = matchingStudents.first?["CharacterVoice"] as? String
        CharacterWeaponType.text = matchingStudents.first?["WeaponType"] as? String
        let characterName:String = matchingStudents.first?["Name"] as? String ?? "null"
        let urlString = "https://bluearchive.wikiru.jp/?\(characterName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "null")"
        if let url = URL(string: urlString) {
            switch reachability.connection {
            case .wifi, .cellular:
                fetchHTML(from: url) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let htmlString):
                            do {
                                if let contents = try self.findContentByTitleInTable(html: htmlString, title: "入手方法") {
                                    self.CharacterAcquisitionMethodText.text = contents.first
                                } else {
                                }
                            } catch {
                                print("エラーが発生しました: \(error)")
                            }
                        case .failure(let error):
                            print("HTMLの取得に失敗しました: \(error)")
                        }
                    }
                }
            case .unavailable:
                print("ネットワークに接続されていません。")
                self.CharacterAcquisitionMethodText.text = "オンライン環境で取得できます"
            }
        }
    }
    func fetchHTML(from url: URL, completion: @escaping (Result<String, Error>) -> Void) {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }
    func translateString(_ input: String, mainKey: String? = nil) -> String? {
        // Load the contents of localization.json from the Documents directory
        let fileManager = FileManager.default
        do {
            let libraryDirectoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
            if let localizationFileURL = libraryDirectoryURL?.appendingPathComponent("assets/data/jp/localization.json") {
                let fileData = try Data(contentsOf: localizationFileURL)
                let json = try JSONSerialization.jsonObject(with: fileData, options: [])
                if let localization = json as? [String: Any] {
                    // If mainKey is provided, search within the nested dictionary
                    if let mainKey = mainKey,
                       let mainDictionary = localization[mainKey] as? [String: String],
                       let translatedString = mainDictionary[input] {
                        return translatedString
                    } else {
                        // Search for the translation based on the input string
                        for (_, value) in localization {
                            if let translations = value as? [String: String],
                               let translatedString = translations[input] {
                                return translatedString
                            }
                        }
                    }
                }
            }else{
                print("")
            }
        } catch {
            print("Error loading localization JSON from Documents directory: \(error)")
            return nil
        }
        
        return "Error" // Translation not found
    }
}
