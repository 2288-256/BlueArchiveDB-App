//
//  DownloadFile.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/09/04
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class DownloadFile
{
    static let shared = DownloadFile()
    private let session: URLSession
    let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!

    private init(session: URLSession = .shared)
    {
        self.session = session
    }

    /// ファイルの保存処理
    ///
    /// ファイルをダウンロードし、すでに存在する場合は上書き保存する関数
    ///
    /// - Parameters:
    ///   - url: ダウンロードするURL
    ///   - completion: ダウンロード完了時に呼び出されるクロージャ
    func downloadFile(url: URL, baseURL: String, completion: @escaping (Result<URL, Error>) -> Void)
    {
        let downloadTask = session.downloadTask(with: url)
        { localURL, response, error in

            // エラーがある場合はエラーを返す
            if let error = error
            {
                completion(.failure(error))
                return
            }

            // レスポンスとローカルURLがnilでないことを確認
            guard let localURL = localURL, let response = response else
            {
                let error = NSError(domain: "DownloadManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid download response"])
                completion(.failure(error))
                return
            }

            do
            {
                var path = url.absoluteString

                if path.hasPrefix(baseURL)
                {
                    path = String(path.dropFirst(baseURL.count))
                }

                // ファイル名を取り除く
                if let lastSlashIndex = path.lastIndex(of: "/")
                {
                    path = String(path[..<lastSlashIndex]) + "/"
                }
                let destinationDirectory = self.libraryDirectory.appendingPathComponent("assets/\(path)", isDirectory: true)

                try? FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)

                // 保存先のファイルパスを生成
                let destinationURL = destinationDirectory.appendingPathComponent(url.lastPathComponent)

                // 既にファイルが存在する場合は削除
                if FileManager.default.fileExists(atPath: destinationURL.path)
                {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                // ファイルを保存
                try FileManager.default.moveItem(at: localURL, to: destinationURL)

                // ファイルサイズを取得してログに記録
                let fileSize = try FileManager.default.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64
                Logger.download.debug("Downloaded file size: \(fileSize ?? 0) bytes from \(url)")
                completion(.success(destinationURL))
            } catch
            {
                completion(.failure(error))
            }
        }
        downloadTask.resume()
    }

    /// DBデータのダウンロード処理
    ///
    ///
    ///
    /// - Parameters:
    ///   - urls: ダウンロードするURLの配列
    ///   - completion: ダウンロード完了時に呼び出されるクロージャ
    func downloadDataFile(urls: [URL], completion: @escaping () -> Void)
    {
        guard !urls.isEmpty else
        {
            completion()
            return
        }

        var remainingURLs = urls
        let currentURL = remainingURLs.removeFirst()

        downloadFile(url: currentURL, baseURL: "https://schaledb.com/")
        { result in
            switch result
            {
            case let .success(localURL):
                Logger.download.debug("Downloaded to: \(localURL)")
            case let .failure(error):
                Logger.util.fault("Failed to download from \(currentURL): \(error)")
            }

            // 次のファイルをダウンロード
            self.downloadDataFile(urls: remainingURLs, completion: completion)
        }
    }

    /// JsonFileから生徒IDを読み込む関数
    ///
    /// - Parameters:
    ///   - jsonFile: 処理するJSONファイル。
    ///   - completion: 生徒IDの配列を返すクロージャ
    private func loadStudentIDs(jsonFile: String, completion: @escaping ([Int]?) -> Void)
    {
        let fileManager = FileManager.default
        guard let url = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first?
            .appendingPathComponent("assets/data/jp/\(jsonFile)") else
        {
            Logger.util.fault("Failed to get URL for \(jsonFile)")
            completion(nil)
            return
        }

        do
        {
            let data = try Data(contentsOf: url)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]]
            let ids = jsonObject?.compactMap { Int($0.key) }
            completion(ids)
        } catch
        {
            Logger.util.fault("Error loading JSON: \(error)")
            completion(nil)
        }
    }

    // 画像をダウンロードし、指定したディレクトリに保存するメソッド

    /// 生徒の画像をダウンロードするメソッド
    ///
    /// - Parameters:
    ///   - id: 生徒ID
    ///   - completion: ダウンロード完了時に呼び出されるクロージャ
    private func downloadImages(id: Int, completion: @escaping (Result<[URL], Error>) -> Void)
    {
        var downloadedURLs: [URL] = []
        let dispatchGroup = DispatchGroup()

        for urlTemplate in StudentAssetURLs.urls
        {
            // URLのテンプレートにIDを埋め込む
            let urlString = urlTemplate.absoluteString
            let finalURLString = urlString.replacingOccurrences(of: "$ID", with: "\(id)")
            guard let url = URL(string: finalURLString) else
            {
                Logger.util.fault("Invalid URL: \(urlString)")
                continue
            }
            // ダウンロード開始前にファイルの存在確認
            let destinationPath = destinationPathForURL(url: url, baseURL: "https://schaledb.com/")
            if FileManager.default.fileExists(atPath: destinationPath.path)
            {
                Logger.util.warning("File already exists at: \(destinationPath.path). Skipping download.")
                continue
            }

            dispatchGroup.enter()

            downloadFile(url: url, baseURL: "https://schaledb.com/")
            { result in
                switch result
                {
                case let .success(localURL):
                    Logger.download.debug("Downloaded to: \(localURL)")
                    dispatchGroup.leave()
                case let .failure(error):
                    Logger.util.fault("Failed to download from \(url): \(error)")
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main)
        {
            completion(.success(downloadedURLs))
        }
    }

    /// 生徒の画像をダウンロードするメソッド
    ///
    /// StudentAssetURLsで定義している"collection", "icon", "portrait", "weapon", "gear"の画像をダウンロードする
    ///
    /// - Parameters:
    ///   - jsonFile: 生徒IDが記載されたJSONファイルの名前
    ///   - progressTextView: 画像処理の進捗を更新するためのテキストビュー
    ///   - completion: 画像処理が完了した際に呼び出されるクロージャ
    func processStudentImages(jsonFile: String, progressTextView: UILabel, completion: @escaping () -> Void)
    {
        loadStudentIDs(jsonFile: jsonFile)
        { [weak self] ids in
            guard let ids = ids, !ids.isEmpty else
            {
                Logger.util.fault("Failed to load student IDs or no IDs found.")
                completion()
                return
            }

            let totalCount = ids.count * StudentAssetURLs.urls.count
            var processedCount = 0

            let dispatchGroup = DispatchGroup()

            for id in ids
            {
                for urlTemplate in StudentAssetURLs.urls
                {
                    dispatchGroup.enter()
                    // URLのテンプレートにIDを埋め込む
                    let urlString = urlTemplate.absoluteString
                    let finalURLString = urlString.replacingOccurrences(of: "$ID", with: "\(id)")
                    guard let url = URL(string: finalURLString) else
                    {
                        Logger.util.fault("Invalid URL: \(urlString)")
                        dispatchGroup.leave()
                        continue
                    }
                    // ダウンロード開始前にファイルの存在確認
                    let destinationPath = self!.destinationPathForURL(url: url, baseURL: "https://schaledb.com/")
                    if FileManager.default.fileExists(atPath: destinationPath.path)
                    {
                        Logger.util.warning("File already exists at: \(destinationPath.path). Skipping download.")
                        dispatchGroup.leave()
                        continue
                    }

                    self!.downloadFile(url: url, baseURL: "https://schaledb.com/")
                    { result in
                        switch result
                        {
                        case let .success(localURL):
                            Logger.download.debug("Downloaded to: \(localURL)")
                        case let .failure(error):
                            Logger.util.fault("Failed to download from \(url): \(error)")
                        }
                        DispatchQueue.main.async
                        {
                            processedCount += 1
                            progressTextView.text = "生徒の画像をダウンロード中... \(processedCount)/\(totalCount)"
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main)
            {
                Logger.util.info("All students images Downloaded.")
                completion()
            }
        }
    }

    /// その他の画像を保存する処理
    ///
    /// UniqueAssetURLsで定義している"Equipment", "CollectionBG"の画像をダウンロードする
    ///
    /// - Parameters:
    ///   - jsonFile: 画像をダウンロードする生徒IDが記載されたJSONファイルの名前
    ///   - progressTextView: 画像処理の進捗を更新するためのテキストビュー
    ///   - completion: 画像処理が完了した際に呼び出されるクロージャ
    func processUniqueImages(jsonFile: String, progressTextView: UILabel, completion: @escaping () -> Void)
    {
        var EquipmentArray: [String] = []
        DispatchQueue.main.async
        {
            progressTextView.text = "その他の画像データを計算中..."
        }
        loadStudentIDs(jsonFile: jsonFile)
        { [weak self] ids in
            guard let self = self, let ids = ids, !ids.isEmpty else
            {
                Logger.util.fault("Failed to load student IDs or no IDs found.")
                completion()
                return
            }
            let dispatchGroup = DispatchGroup()
            let uniqueNameList = ["Equipment", "CollectionBG", "WeaponImg", "SkillIcon"]
            LoadFile.shared.loadInitialData()
            let jsonArrays: [String: [String: Any]] = LoadFile.shared.getStudents()
            var DownloadEquipmentArray: [String] = []
            var DownloadBGArray: [String] = []
            var DownloadWeaponArray: [String] = []
            var DownloadIconImageArray: [String] = []
            var totalCount = 0
            var processedCount = 0

            for id in ids
            {
                let studentData: [String: Any] = jsonArrays["\(id)"] ?? [:]
                let EquipmentArray = studentData["Equipment"] as? [String] ?? []
                let bgName = studentData["CollectionBG"] as? String ?? ""
                let wpName = studentData["WeaponImg"] as? String ?? ""
                let SkillIconArray = studentData["Skills"] as? [String: Any] ?? [:]
                for i in 0 ..< uniqueNameList.count
                {
                    switch i
                    {
                    case 0:
                        for equipmentName in EquipmentArray
                        {
                            for index in 1 ... 9
                            {
                                let equipmentFileName = "equipment_icon_\(equipmentName.lowercased())_tier\(index)"
                                if !DownloadEquipmentArray.contains(equipmentFileName)
                                {
                                    DownloadEquipmentArray.append(equipmentFileName)
                                    totalCount += 1
                                }
                            }
                        }
                    case 1:
                        if !DownloadBGArray.contains(bgName)
                        {
                            DownloadBGArray.append(bgName)
                            totalCount += 1
                        }
                    case 2:
                        if !DownloadWeaponArray.contains(wpName)
                        {
                            DownloadWeaponArray.append(wpName)
                            totalCount += 1
                        }
                    case 3:
                        for key in SkillIconArray.keys
                        {
                            let SkillArray = SkillIconArray[key] as! [String: Any]
                            if let IconName = SkillArray["Icon"] as? String
                            {
                                if !DownloadIconImageArray.contains(IconName)
                                {
                                    DownloadIconImageArray.append(IconName)
                                }
                            }
                        }
                    default:
                        ()
                    }
                }
            }
            let downloadTasks = [
                ("Equipment", DownloadEquipmentArray, "$FileName"),
                ("CollectionBG", DownloadBGArray, "$BGName"),
                ("WeaponImg", DownloadWeaponArray, "$WpName"),
                ("SkillIcon", DownloadIconImageArray, "$IconName"),
            ]
            for (key, fileArray, placeholder) in downloadTasks
            {
                for fileName in fileArray
                {
                    let urlString = UniqueAssetURLs.urls[key] ?? ""
                    guard let url = URL(string: urlString.replacingOccurrences(of: placeholder, with: "\(fileName)")) else
                    {
                        Logger.util.fault("Invalid URL: \(urlString)")
                        continue
                    }
                    // ダウンロード開始前にファイルの存在確認
                    let destinationPath = destinationPathForURL(url: url, baseURL: "https://schaledb.com/")
                    if FileManager.default.fileExists(atPath: destinationPath.path)
                    {
                        Logger.util.warning("File already exists at: \(destinationPath.path). Skipping download.")
                        continue
                    }
                    dispatchGroup.enter()
                    self.downloadFile(url: url, baseURL: "https://schaledb.com/")
                    { result in
                        switch result
                        {
                        case let .success(localURL):
                            Logger.download.debug("Downloaded to: \(localURL)")
                        case let .failure(error):
                            Logger.util.fault("Failed to download from \(url): \(error)")
                        }
                        processedCount += 1
                        DispatchQueue.main.async
                        {
                            progressTextView.text = "その他の画像をダウンロード中... \(processedCount)/\(totalCount)"
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main)
            {
                Logger.util.info("All unique images Downloaded.")
                completion()
            }
        }
    }

    /// 各生徒の音声データをダウンロードする関数
    ///
    ///
    /// - Parameters:
    ///   - progressTextView: 進捗を表示するためのテキストビュー
    ///   - completion: 音声データのダウンロードが完了した際に呼び出されるクロージャ
    func processVoiceData(jsonFile: String, progressTextView: UILabel, completion: @escaping () -> Void)
    {
        loadStudentIDs(jsonFile: jsonFile)
        { [weak self] ids in
            guard let self = self, let ids = ids, !ids.isEmpty else
            {
                Logger.util.fault("Failed to load student IDs or no IDs found.")
                completion()
                return
            }
            let dispatchGroup = DispatchGroup()
            let totalCount = ids.count
            var processedCount = 0
            for id in ids
            {
                let voiceArrays: [[String: Any]] = LoadFile.shared.getVoiceData(forUnitId: "\(id)")!
                for i in 0 ..< voiceArrays.count
                {
                    let test = voiceArrays[i]
                    let key = Array(test.keys)
                    for j in 0 ..< key.count
                    {
                        let test2: [[String: Any]] = voiceArrays[i]["\(key[j])"] as! [[String: Any]]
                        for k in 0 ..< test2.count
                        {
                            let filePath = test2[k]["AudioClip"] as! String
                            let urlString = UniqueAssetURLs.urls["Voice"] ?? ""
                            guard let url = URL(string: urlString.replacingOccurrences(of: "$path", with: filePath)) else
                            {
                                Logger.util.fault("Invalid URL: \(urlString)")
                                continue
                            }
                            let destinationPath = self.destinationPathForURL(url: url, baseURL: "https://r2.schaledb.com/")
                            if FileManager.default.fileExists(atPath: destinationPath.path)
                            {
                                Logger.util.warning("File already exists at: \(destinationPath.path). Skipping download.")
                                continue
                            }
                            dispatchGroup.enter()
                            self.downloadFile(url: url, baseURL: "https://r2.schaledb.com/")
                            { result in
                                switch result
                                {
                                case let .success(localURL):
                                    Logger.download.debug("Downloaded to: \(localURL)")
                                case let .failure(error):
                                    Logger.util.fault("Failed to download from \(url): \(error)")
                                }
                                processedCount += 1
                                DispatchQueue.main.async
                                {
                                    progressTextView.text = "ボイスデータをダウンロード中... \(processedCount)"
                                }
                                dispatchGroup.leave()
                            }
                        }
                        var filePath = ""
                    }
                }
            }
            dispatchGroup.notify(queue: .main)
            {
                Logger.util.info("All voice data downloaded.")
                completion()
            }
        }
    }

    /// ファイルの保存先を生成する関数
    ///
    /// - Parameters:
    ///   - url: ダウンロードするURL
    ///   - baseURL: ベースURL (https://schaledb.com/ など)
    /// - Returns: 保存先のURL
    func destinationPathForURL(url: URL, baseURL: String) -> URL
    {
        var path = url.absoluteString
        if path.hasPrefix(baseURL)
        {
            path = String(path.dropFirst(baseURL.count))
        }
        if let lastSlashIndex = path.lastIndex(of: "/")
        {
            path = String(path[..<lastSlashIndex])
        }

        let destinationDirectory = libraryDirectory.appendingPathComponent("assets/\(path)", isDirectory: true)
        let destinationURL = destinationDirectory.appendingPathComponent(url.lastPathComponent)

        return destinationURL
    }
}

enum DataFileURLs
{
    static let urls: [URL] = [
        URL(string: "https://schaledb.com/data/jp/students.min.json")!,
        URL(string: "https://schaledb.com/data/jp/voice.min.json")!,
        URL(string: "https://schaledb.com/data/jp/localization.min.json")!,
        URL(string: "https://schaledb.com/data/jp/stages.min.json")!,
        URL(string: "https://schaledb.com/data/jp/enemies.min.json")!,
        URL(string: "https://schaledb.com/data/jp/items.min.json")!,
        URL(string: "https://schaledb.com/data/jp/equipment.min.json")!,
        URL(string: "https://schaledb.com/data/jp/furniture.min.json")!,
        URL(string: "https://schaledb.com/data/jp/currency.min.json")!,
        URL(string: "https://schaledb.com/data/config.min.json")!,
    ]
}

enum StudentAssetURLs
{
    static let urls: [URL] = [
        URL(string: "https://schaledb.com/images/student/collection/$ID.webp")!,
        URL(string: "https://schaledb.com/images/student/icon/$ID.webp")!,
        URL(string: "https://schaledb.com/images/student/portrait/$ID.webp")!,
        URL(string: "https://schaledb.com/images/gear/full/$ID.webp")!,
        URL(string: "https://schaledb.com/images/gear/icon/$ID.webp")!,
    ]
}

enum UniqueAssetURLs
{
    static let urls: [String: String] = [
        "Equipment": "https://schaledb.com/images/equipment/icon/$FileName.webp",
        "CollectionBG": "https://schaledb.com/images/background/$BGName.jpg",
        "WeaponImg": "https://schaledb.com/images/weapon/$WpName.webp",
        "Voice": "https://r2.schaledb.com/voice/$path",
        "SkillIcon": "https://schaledb.com/images/skill/$IconName.webp",
    ]
}
