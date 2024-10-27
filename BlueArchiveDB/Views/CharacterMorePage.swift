//
//  CharacterMorePage.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/12/04.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//
import AVFoundation
import Foundation
import Reachability
import UIKit

class CharacterMorePage: UIViewController, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, AVAudioPlayerDelegate
{
    let reachability = try! Reachability()
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var progressView: UIProgressView!
    // 一般ボタン
    @IBOutlet var normalVoiceButton: UIButton!
    // 戦闘
    @IBOutlet var battleVoiceButton: UIButton!
    // ホーム
    @IBOutlet var homeVoiceButton: UIButton!
    // イベント
    @IBOutlet var eventVoiceButton: UIButton!
    var jsonArray: [[String: Any]] = []
    var jsonArrays: [[String: Any]] = []
    var tempJson: [[String: Any]] = []
    var unitId: Int = 0
    var player: AVPlayer?
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        jsonArray = LoadFile.shared.getVoiceData(forUnitId: "\(unitId)") ?? []
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        {
            layout.minimumInteritemSpacing = 10 // セルの間の隙間を10ポイントに設定
            layout.minimumLineSpacing = 10 // 行の間の隙間を10ポイントに設定
            collectionView.collectionViewLayout = layout
        }
        updateVoiceButton(button: normalVoiceButton, withKey: "Normal")
        updateVoiceButton(button: battleVoiceButton, withKey: "Battle")
        updateVoiceButton(button: homeVoiceButton, withKey: "Lobby")
        updateVoiceButton(button: eventVoiceButton, withKey: "Event")

        if let normalArray = jsonArray.first?["Normal"] as? [[String: Any]]
        {
            jsonArrays = normalArray
        } else
        {
            // Handle the case where the optional does not contain a value
            jsonArrays = []
        }
    }

    private func updateVoiceButton(button: UIButton, withKey key: String)
    {
        let voiceData = jsonArray.first?[key] as? [[String: Any]] ?? []
        button.isEnabled = !voiceData.isEmpty
    }

    @IBAction func normalVoiceButton(_: Any)
    {
        jsonArrays = jsonArray.first?["Normal"] as? [[String: Any]] ?? []
        // 空の場合は更新しない
        if jsonArrays.count > 0
        {
            collectionView.reloadData()
        }
    }

    @IBAction func battleVoiceButton(_: Any)
    {
        jsonArrays = jsonArray.first?["Battle"] as? [[String: Any]] ?? []
        // 空の場合は更新しない
        if jsonArrays.count > 0
        {
            collectionView.reloadData()
        }
    }

    @IBAction func homeVoiceButton(_: Any)
    {
        jsonArrays = jsonArray.first?["Lobby"] as? [[String: Any]] ?? []
        // 空の場合は更新しない
        if jsonArrays.count > 0
        {
            collectionView.reloadData()
        }
    }

    @IBAction func eventVoiceButton(_: Any)
    {
        jsonArrays = jsonArray.first?["Event"] as? [[String: Any]] ?? []
        // 空の場合は更新しない
        if jsonArrays.count > 0
        {
            collectionView.reloadData()
        }
    }

    @IBAction func backButton(_: Any)
    {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func homeButton(_: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "Home") as! ViewController
        present(nextVC, animated: false, completion: nil)
    }

    // UIButtonが属するUICollectionViewCellを見つけるためのヘルパーメソッド
    func getParentCell(of view: UIView) -> UICollectionViewCell?
    {
        var superview = view.superview
        while let view = superview, !(view is UICollectionViewCell)
        {
            superview = view.superview
        }
        return superview as? UICollectionViewCell
    }

    // ボタンが押されたときに呼ばれるアクション
    @IBAction func buttonPressed(_ sender: UIButton)
    {
        // UIButtonのsuperviewからUICollectionViewCellを見つける
        if let cell = getParentCell(of: sender), let indexPath = collectionView.indexPath(for: cell)
        {
            // cellのタグを取得
            let cellTag = cell.tag
            if let SoundFilePath = jsonArrays[cellTag]["AudioClip"] as? String
            {
                let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
                let soundFilePath = libraryDirectory.appendingPathComponent("assets/voice/\(SoundFilePath)").path
                if !FileManager.default.fileExists(atPath: soundFilePath)
                {
                    playSound(SoundFilePath: SoundFilePath, type: "server")
                    //                    let alert = UIAlertController(title: "エラー", message: "ファイルが見つかりませんでした。", preferredStyle: .alert)
                    //                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    //                    present(alert, animated: true, completion: nil)
                    //                    return
                }
                playSound(SoundFilePath: SoundFilePath, type: "local")
            }
        }
    }

    // func playSound(from url: URL)
    // {

    // 	let playerItem = AVPlayerItem(url: url)
    // 	player = AVPlayer(playerItem: playerItem)
    // 	player?.play()
    // }
    func playSound(SoundFilePath: String, type: String)
    {
        switch type
        {
        case "local":
            let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
            let soundFilePath = libraryDirectory.appendingPathComponent("assets/voice/\(SoundFilePath)").path
            let soundFileURL = URL(fileURLWithPath: soundFilePath)

            do
            {
                audioPlayer = try AVAudioPlayer(contentsOf: soundFileURL)
                audioPlayer?.prepareToPlay()
                Logger.standard.info("Play assets/voice/\(SoundFilePath) voice")
                audioPlayer?.play()
            } catch
            {
                Logger.standard.fault("音源ファイルの再生に失敗しました: \(error)")
            }

        case "server":
            if let url = URL(string: "https://r2.schaledb.com/voice/\(SoundFilePath)")
            {
                // URLSessionを使用してContent-Typeを確認
                var request = URLRequest(url: url)
                request.httpMethod = "HEAD" // ヘッダーのみを取得するためHEADリクエストを使用

                URLSession.shared.dataTask(with: request)
                { _, response, error in
                    if let error = error as? URLError
                    {
                        // オフラインの場合のエラーメッセージ
                        let errorMessage = error.code == .notConnectedToInternet ? "オフラインです。インターネット接続を確認してください。" : "リクエストエラー: \(error.localizedDescription)"

                        DispatchQueue.main.async
                        {
                            self.showAlert(title: "エラー", message: errorMessage)
                        }
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse,
                       let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
                       contentType.contains("audio")
                    {
                        // Content-Typeにaudioが含まれていれば再生開始
                        DispatchQueue.main.async
                        {
                            let playerItem = AVPlayerItem(url: url)
                            self.player = AVPlayer(playerItem: playerItem)
                            self.player?.play()
                        }
                    } else
                    {
                        // Content-Typeにaudioが含まれていない場合、アラート表示
                        DispatchQueue.main.async
                        {
                            self.showAlert(title: "再生エラー", message: "指定されたファイルは音声ファイルではありません。")
                        }
                    }
                }.resume()
            }

        default:
            ()
        }
    }

    func showAlert(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // メインの表示しているビューコントローラーでアラートを表示
        present(alertController, animated: true, completion: nil)
    }

    // JSONデータを含む配列

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "voice-cell", for: indexPath)
        cell.tag = indexPath.row
        cell.contentView.layer.borderColor = UIColor.gray.cgColor // 枠線の色をグレーに設定
        cell.contentView.layer.borderWidth = 1.0 // 枠線の太さを1ポイントに設定
        cell.contentView.layer.cornerRadius = 5.0 // 角丸の半径を5ポイントに設定
        cell.contentView.clipsToBounds = true // 角丸を適用するために必要

        // Reset the content of the cell
        let groupLabel = cell.contentView.viewWithTag(1) as? UILabel
        groupLabel?.text = nil // Reset to default text or empty string
        let transcriptionLabel = cell.contentView.viewWithTag(2) as? UILabel
        // 区切り線
        let separator = cell.contentView.viewWithTag(3) as? UIView
        separator?.frame.size.width = cell.frame.size.width
        // Get the Group information.
        if let group = jsonArrays[indexPath.row]["Group"] as? String
        {
            groupLabel?.text = LoadFile.shared.translateString(group)
        }

        // Get the Transcription information.
        if var transcription = jsonArrays[indexPath.row]["Transcription"] as? String
        {
            var result = ""
            var startIndex = transcription.startIndex
            // 40文字ごとに改行コードを入れる
            if !transcription.contains("\n")
            {
                while startIndex < transcription.endIndex
                {
                    let endIndex = transcription.index(startIndex, offsetBy: 45, limitedBy: transcription.endIndex) ?? transcription.endIndex
                    let range = startIndex ..< endIndex
                    result += transcription[range]
                    if endIndex < transcription.endIndex
                    {
                        result += "\n"
                    }
                    startIndex = endIndex
                }
            } else
            {
                result = transcription
            }
            transcription = result
            transcriptionLabel?.text = transcription
            transcriptionLabel?.isHidden = false
            if transcription.contains("\n")
            {
                transcriptionLabel?.numberOfLines = transcription.components(separatedBy: "\n").count
            } else
            {
                transcriptionLabel?.numberOfLines = 1
            }
            separator?.isHidden = false
            // Adjust label width
            transcriptionLabel?.sizeToFit()
            transcriptionLabel?.frame.size.width = 532
            cell.frame.size.height = groupLabel!.frame.size.height + transcriptionLabel!.frame.size.height + 15
        } else
        {
            transcriptionLabel?.isHidden = true
            transcriptionLabel?.text = nil
            separator?.isHidden = true
            // Set cell height if no transcription
            cell.frame.size.height = 37
        }
        return cell
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int
    {
        // jsonArrayが0ではない場合
        if jsonArrays.count > 0
        {
            return jsonArrays.count
        } else
        {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // Existing width calculation is maintained
        let cellWidth = collectionView.frame.width

        // Default cell height
        var cellHeight: CGFloat = 37

        // Determine if there is a transcription for the specific indexPath
        if let transcription = jsonArrays[indexPath.row]["Transcription"] as? String,
           !transcription.isEmpty
        {
            // Calculate height based on the content
            let groupLabelHeight: CGFloat = 20 // Assuming a default height for the group label
            let transcriptionHeight = heightForText(transcription, havingWidth: cellWidth, andFont: UIFont.systemFont(ofSize: 14))
            cellHeight = groupLabelHeight + transcriptionHeight + 20
        }

        return CGSize(width: cellWidth, height: cellHeight)
    }

    // Helper function to calculate the height of the text
    func heightForText(_ text: String, havingWidth width: CGFloat, andFont font: UIFont) -> CGFloat
    {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}
