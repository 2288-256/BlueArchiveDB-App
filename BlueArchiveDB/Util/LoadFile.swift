//
//  LoadFile.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/07/05
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation

class LoadFile
{
    static let shared = LoadFile()

    private var studentsData: [[String: Any]] = []
    private var voiceData: [[String: Any]] = []
    private var localizationData: [String: Any] = [:]

    private init()
    {
        loadInitialData()

        // NotificationCenterのオブザーバーを登録
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLocalizationDataGenerated),
            name: Notification.Name("LocalizationDataGenerated"),
            object: nil
        )
    }

    deinit
    {
        // オブザーバーを削除
        NotificationCenter.default.removeObserver(self)
    }

    // 初期データ読み込み処理
    private func loadInitialData()
    {
        loadAllStudents()
        loadLocalizationData()
    }

    private func loadAllStudents()
    {
        do
        {
            let fileManager = FileManager.default
            let documentsURL = try fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let studentsFileURL = documentsURL.appendingPathComponent("assets/data/jp/students.json")

            let data = try Data(contentsOf: studentsFileURL)
            studentsData = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            print("ロードした生徒数:\(studentsData.count)")
        } catch
        {
            print("Error reading students JSON file: \(error)")
        }
    }

    func loadAllStudentsVoice(unitId: String)
    {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
        {
            let voiceFileURL = documentsURL.appendingPathComponent("assets/data/jp/voice.json")
            do
            {
                let data = try Data(contentsOf: voiceFileURL)
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let dict = jsonObject as? [String: Any],
                   let user = dict[unitId] as? [String: Any]
                {
                    voiceData = [user] // データを格納
                }
            } catch
            {
                print("Error reading voice JSON file: \(error)")
            }
        }
    }

    private func loadLocalizationData()
    {
        do
        {
            let fileManager = FileManager.default
            let libraryDirectoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
            if let localizationFileURL = libraryDirectoryURL?.appendingPathComponent("assets/data/jp/localization.json")
            {
                let fileData = try Data(contentsOf: localizationFileURL)
                let json = try JSONSerialization.jsonObject(with: fileData, options: [])
                if let localization = json as? [String: Any]
                {
                    localizationData = localization
                }
            } else
            {
                print("Localization file not found at path.")
            }
        } catch
        {
            print("Error loading localization JSON from Documents directory: \(error)")
        }
    }

    // 翻訳関数
    func translateString(_ input: String, mainKey: String? = nil) -> String?
    {
        // Convert the input string to an array of characters
        let characters = Array(input)
        // Manually extract the trailing numbers from the input string if any
        var trailingNumberString = ""
        var keyToSearch = input
        for character in characters.reversed()
        {
            if character.isNumber
            {
                trailingNumberString.insert(character, at: trailingNumberString.startIndex)
            } else
            {
                break
            }
        }
        // Remove the trailing numbers from the input to get the key to search
        if !trailingNumberString.isEmpty
        {
            keyToSearch.removeLast(trailingNumberString.count)
        }

        // Define a helper function to search for the key in the localization dictionary
        func searchForKey(_ searchKey: String) -> String?
        {
            for (key, value) in localizationData
            {
                if let translations = value as? [String: String],
                   let translatedString = translations[searchKey]
                {
                    // Check if the translated string has a placeholder "{0}" for the trailing numbers
                    if translatedString.contains("{0}")
                    {
                        // Replace "{0}" with the trailing numbers
                        return translatedString.replacingOccurrences(of: "{0}", with: trailingNumberString)
                    }
                    return translatedString
                }
            }
            return nil
        }

        if let mainKey = mainKey
        {
            // If not found, search again using the entire key including trailing numbers
            let inputNew = String(input.dropLast())
            if
               let mainDictionary = localizationData[mainKey] as? [String: String],
               let translatedString = mainDictionary[input]
            {
                print("if:"+translatedString)
                return translatedString
            } else
            {
                // Search for the translation based on the input string
                for (_, value) in localizationData
                {
                    if let translations = value as? [String: String],
                       let translatedString = translations[input]
                    {
                        print("ifelse:"+translatedString)
                        return translatedString
                    }
                }
            }
        }else{
            // Search using the key without trailing numbers
            if let translation = searchForKey(keyToSearch)
            {
                return translation
            }else{
                return "Error: TNSK"
            }
        }
        return "Error: NIF"
    }

    func findMatchingKeys(searchText: String) -> [String]
    {
        var matchingKeys: [String] = []

        do
        {
            let fileManager = FileManager.default
            let documentsURL = try fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let localizationFileURL = documentsURL.appendingPathComponent("assets/data/jp/localization.json")

            let fileData = try Data(contentsOf: localizationFileURL)
            if let json = try JSONSerialization.jsonObject(with: fileData, options: []) as? [String: [String: String]]
            {
                let directoriesToSearch = ["School", "SchoolLong", "Club"]

                for directory in directoriesToSearch
                {
                    if let directoryData = json[directory]
                    {
                        for (key, value) in directoryData where value.contains(searchText)
                        {
                            matchingKeys.append(key)
                        }
                    }
                }
            }
        } catch
        {
            // Handle error
        }
        return matchingKeys
    }

    public func getStudents() -> [[String: Any]]
    {
        return studentsData
    }

    public func getVoiceData(forUnitId unitId: String) -> [String: Any]?
    {
        loadAllStudentsVoice(unitId: unitId)
        if !voiceData.isEmpty
        {
            return voiceData[0]
        } else
        {
            return nil
        }
    }

    @objc private func handleLocalizationDataGenerated()
    {
        // localization.jsonのデータを読み込み直す
        loadInitialData()
    }
}
