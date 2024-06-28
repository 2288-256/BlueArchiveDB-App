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
	UICollectionViewDelegateFlowLayout
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

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		loadAllStudentsVoice()
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
				switch reachability.connection
				{
				case .cellular, .wifi:
					if let url = URL(string: "https://static.schale.gg/voice/\(SoundFilePath)")
					{
						// http通信をし、200番台なら再生する
						if let data = try? Data(contentsOf: url)
						{
							playSound(from: url)
						} else
						{
							let alert = UIAlertController(title: "エラー", message: "原因不明のエラーで再生できませんでした。", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "OK", style: .default))
							present(alert, animated: true, completion: nil)
						}
					}
				case .unavailable:
					let alert = UIAlertController(title: "エラー", message: "ネットワークに接続されていないため再生できません。", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default))
					present(alert, animated: true, completion: nil)
				}
			}
		}
	}

	func playSound(from url: URL)
	{
		let playerItem = AVPlayerItem(url: url)
		player = AVPlayer(playerItem: playerItem)
		player?.play()
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
			groupLabel?.text = translateString(group)
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

	func loadAllStudentsVoice()
	{
		// JSONを読み込み、解析する処理を想定しています。
		// このメソッドで、jsonArrays配列に適切なデータを設定する必要があります。
		// 以下は仮のコードで、実際のJSON読み込み処理には置き換えてください。
		let fileManager = FileManager.default
		if let documentsURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
		{
			let voiceFileURL = documentsURL.appendingPathComponent("assets/data/jp/voice.json")
			do
			{
				let data = try Data(contentsOf: voiceFileURL)
				let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
				if let dict = jsonObject as? [String: Any]
				{
					// 特定のキーに対応するデータを取得
					if let user = dict["\(unitId)"] as? [String: Any]
					{
						jsonArray = [user]
					}
				}
			} catch
			{
				print("Error reading voice JSON file: \(error)")
			}
		}
	}

	func translateString(_ input: String) -> String?
	{
		// Load the contents of localization.json
		let fileManager = FileManager.default
		let documentDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
		let localizationFileURL = documentDirectory?.appendingPathComponent("assets/data/jp/localization.json")

		guard let path = localizationFileURL,
		      let fileData = fileManager.contents(atPath: path.path),
		      let json = try? JSONSerialization.jsonObject(with: fileData, options: []),
		      let localization = json as? [String: Any] else
		{
			return nil
		}

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
			for (key, value) in localization
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

		// Search using the key without trailing numbers
		if let translation = searchForKey(keyToSearch)
		{
			return translation
		} else
		{
			// If not found, search again using the entire key including trailing numbers
			let inputNew = String(input.dropLast())
			return searchForKey(inputNew) ?? "Error" // Translation not found
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
