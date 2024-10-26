//
//  ViewController.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/22.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//
import AVFoundation
import CoreSpotlight
import Foundation
import MobileCoreServices
import Reachability
import UIKit
import os.log

class ViewController: UIViewController, UICollectionViewDataSource,
	UICollectionViewDelegateFlowLayout
{
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Logger")
	var player: AVPlayer?
	let reachability = try! Reachability()
	@IBOutlet var versionLabel: UILabel!
	@IBOutlet var studentCountLabel: UILabel!
	@IBOutlet var CharacterImage: UIImageView!
	@IBOutlet var collectionView: UICollectionView!
    var jsonArrays: [String : [String : Any]] = [:]
    var studentArrays: [[String: Any]] = []
	var voiceArrays: [[String: Any]] = []
	var sevenDaysBirthDay: [[String: Any]] = []
	var nextVoice: Bool = false
	var nextVoiceNumber: Int = 0
	var playedVoiceNumber: String = ""
	var firstVoice: Bool = false
	var audioPlayer: AVAudioPlayer?
	var downloadLoadingView = UIView(frame: UIScreen.main.bounds)
	var downloadLoadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 30))

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
		   let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
		{
			versionLabel.text = "Version: \(version) Build: \(build)"
		}
		CharacterImage.isUserInteractionEnabled = true
		// タップジェスチャーレコグナイザーの初期化
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CharacterTapped))
		let CharacterImageHeight = CharacterImage.frame.size.height
		// イメージビューにタップジェスチャーレコグナイザーを追加
		CharacterImage.addGestureRecognizer(tapGestureRecognizer)
        jsonArrays = LoadFile.shared.getStudents()
        studentArrays = Array(LoadFile.shared.getStudents().values)
		loadVoice()
        print("ロードした生徒数:\(self.studentArrays.count)")
		print(voiceArrays)
		firstVoice = true
		if jsonArrays.count > 0
		{
			studentCountLabel.text = "生徒数: \(studentArrays.count)"
		} else
		{
			studentCountLabel.text = "生徒数: 0"
		}
		var days7: [String] = []
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d"

		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())

		for i in 0 ..< 7
		{
			if let nextDate = calendar.date(byAdding: .day, value: i, to: today)
			{
				days7.append(dateFormatter.string(from: nextDate))
			}
		}
        sevenDaysBirthDay = Array(jsonArrays.values).filter { person in
            guard let birthDay = person["BirthDay"] as? String,
                  let name = person["Name"] as? String,
                  !name.contains("（"),
                  !name.contains("）") else {
                return false
            }
            return days7.contains(birthDay)
        }

		// Assuming 'sevenDaysBirthDay' is an array of dictionaries like 'jsonArrays'.

		// First, let's create a function to convert a "BirthDay" string to a Date object.
		func birthDayToDate(_ birthDay: String) -> Date?
		{
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "M/d"
			dateFormatter.timeZone = TimeZone.current

			let currentYear = Calendar.current.component(.year, from: Date())
			let birthDayWithCurrentYear = "\(birthDay)/\(currentYear)"
			dateFormatter.dateFormat = "M/d/yyyy"

			return dateFormatter.date(from: birthDayWithCurrentYear)
		}

		// Now, sort 'sevenDaysBirthDay' based on the "BirthDay" field.
		sevenDaysBirthDay.sort
		{ firstPerson, secondPerson in
			guard let firstBirthDay = firstPerson["BirthDay"] as? String,
			      let secondBirthDay = secondPerson["BirthDay"] as? String,
			      let firstDate = birthDayToDate(firstBirthDay),
			      let secondDate = birthDayToDate(secondBirthDay) else
			{
				return false
			}

			let calendar = Calendar.current

			// Extract month and day components from the dates.
			let firstMonth = calendar.component(.month, from: firstDate)
			let firstDay = calendar.component(.day, from: firstDate)
			let secondMonth = calendar.component(.month, from: secondDate)
			let secondDay = calendar.component(.day, from: secondDate)

			// Handle the scenario where one date is in January and the other is in December.
			if firstMonth == 1 && secondMonth == 12
			{
				return false // January comes after December, so the first date should be after the second.
			} else if firstMonth == 12 && secondMonth == 1
			{
				return true // December comes before January, so the first date should be before the second.
			}

			// If both dates are in the same month or neither is January or December, sort by date.
			if firstMonth == secondMonth
			{
				return firstDay < secondDay // Same month: sort by day.
			} else
			{
				return firstMonth < secondMonth // Different months: sort by month.
			}
		}
		print(sevenDaysBirthDay.count)
		let characterID = UserDefaults.standard.string(forKey: "CharacterID") ?? "10066"
		let fileManager = FileManager.default
		let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
		let imagePath = libraryDirectory.appendingPathComponent("assets/images/student/portrait/\(characterID).webp")
		if let image = UIImage(contentsOfFile: imagePath.path)
		{
			DispatchQueue.main.async
			{
				self.CharacterImage.image = image
				self.CharacterImage.contentMode = .scaleAspectFit
				let height = self.CharacterImage.frame.size.width * (image.size.height / image.size.width)
				self.CharacterImage.heightAnchor.constraint(equalToConstant: height).isActive = true
			}
		}
		// sevenDaysBirthDay.countが0の時
		if sevenDaysBirthDay.count == 0
		{
			// collectionView.dequeueReusableCell(withReuseIdentifier: "birthday-cell", for: indexPath)の中心にlabelを入れる
			let label = UILabel()
			label.text = "生徒はいません"
			label.textAlignment = .center
			label.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
			collectionView.backgroundView = label
		}
		downloadLoadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

		let activityIndicator = UIActivityIndicatorView(style: .large)
		activityIndicator.center = downloadLoadingView.center
		activityIndicator.color = .white
		activityIndicator.startAnimating()
		downloadLoadingView.addSubview(activityIndicator)

		downloadLoadingLabel.frame = CGRect(x: 0, y: 0, width: 400, height: 30)
		downloadLoadingLabel.center = CGPoint(x: activityIndicator.frame.midX, y: activityIndicator.frame.midY + 90)
		downloadLoadingLabel.textColor = .white
		downloadLoadingLabel.textAlignment = .center
		downloadLoadingLabel.text = "ダウンロードの準備中"
		downloadLoadingView.addSubview(downloadLoadingLabel)
	}

	override func restoreUserActivityState(_ activity: NSUserActivity)
	{
		super.restoreUserActivityState(activity)

		if activity.activityType == CSSearchableItemActionType,
		   let uniqueIdentifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String
		{
			print("Restore User Activity: \(uniqueIdentifier)")
		}
	}

	func insert(id: String, title: String, summary: String, keywords: [String])
	{
		let attributeSet = CSSearchableItemAttributeSet(contentType: .text)

		// ①タイトル
		attributeSet.title = title

		// ②説明文
		attributeSet.contentDescription = summary

		// ③画像
		let fileManager = FileManager.default
		let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
		let studentImgDirectory = libraryDirectory.appendingPathComponent("assets/images/student/collection/\(id).webp")
		let imagePath = studentImgDirectory
		if let image = UIImage(contentsOfFile: imagePath.path)
		{
			attributeSet.thumbnailData = image.pngData()
		}

		// キーワード（表示されないが、タイトルや説明文に入ってない文言をここに入れておけば、検索した時に引っかかるようになる）
		attributeSet.keywords = keywords

		/*
		 uniqueIdentifierはAppDelegateで取り出すことができるので、
		 Spotlight検索経由でアプリを開いた時のためのURLスキームを入れておく
		 */
		let item = CSSearchableItem(
			uniqueIdentifier: "studentData_\(id)",
			domainIdentifier: "com.github.2288-256.BlueArchiveDB.Spotlight",
			attributeSet: attributeSet
		)
		CSSearchableIndex.default().indexSearchableItems([item])
		{ error in
			if let e = error
			{
				print("\(e)")
			}
		}
	}

	func destinationWindow()
	{
		// "「未実装です」というアラートを表示"
		let alert = UIAlertController(title: "エラー", message: "まだ実装されていない機能です", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let testCell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "birthday-cell", for: indexPath)

		let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
		let label = testCell.contentView.viewWithTag(2) as! UILabel
		if sevenDaysBirthDay.count > indexPath.row
		{
			let characterInfo = sevenDaysBirthDay[indexPath.row]
			if let unitId = characterInfo["Id"] as? Int,
			   let name = characterInfo["BirthDay"] as? String
			{
				testCell.tag = unitId
				// libraryにある画像を読み込む
				let fileManager = FileManager.default
				let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
				let imagePath = libraryDirectory.appendingPathComponent("assets/images/student/collection/\(unitId).webp")
				imageView.image = UIImage(contentsOfFile: imagePath.path)
				label.text = name
			}
		}

		return testCell
	}

	func collectionView(_: UICollectionView,
	                    layout _: UICollectionViewLayout,
	                    sizeForItemAt _: IndexPath) -> CGSize
	{
		let horizontalSpace: CGFloat = 8
		let cellSize: CGFloat = (view.bounds.width - (horizontalSpace * 8)) / 8
		return CGSize(width: cellSize, height: 165)
	}

	//    func collectionView(_ collectionView: UICollectionView,
	//                       layout collectionViewLayout: UICollectionViewLayout,
	//                       insetForSectionAt section: Int) -> UIEdgeInsets {
	//        return UIEdgeInsets(top: 0, left: 0, bottom: 11, right: 0)
	//    }

	func numberOfSections(in _: UICollectionView) -> Int
	{
		// section数は１つ
		return 1
	}

	func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int
	{
		return sevenDaysBirthDay.count
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
		// 選択されたセルを取得
		let selectedCell = collectionView.cellForItem(at: indexPath)

		// セルのtagを取得
		let cellTag = selectedCell?.tag
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterInfo") as? CharacterInfo
		{
			// 引き渡したい変数を設定する
			viewController.unitId = Int(cellTag!)
			viewController.modalTransitionStyle = .crossDissolve
			viewController.modalPresentationStyle = .fullScreen
			present(viewController, animated: false, completion: nil)
		} else
		{
			print("Error: Failed to instantiate CharacterSelect")
		}
		// セル選択の解除
		collectionView.deselectItem(at: indexPath, animated: true)
	}

	func resizeImageHeight(image: UIImage, targetHeight: CGFloat) -> UIImage
	{
		let aspectRatio = image.size.width / image.size.height
		let targetWidth = targetHeight * aspectRatio
		let size = CGSize(width: targetWidth, height: targetHeight)

		let renderer = UIGraphicsImageRenderer(size: size)
		let image = renderer.image
		{ _ in
			image.draw(in: CGRect(origin: .zero, size: size))
		}
		return image
	}

	@IBAction func presentButton(sender: UIButton)
	{
		// ボタンのTitleを取得してswitch文で処理を分岐
		let title = sender.titleLabel?.text!
		switch title
		{
		case "キャラ":
			// キャラクター選択画面
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterSelect") as? CharacterSelect
			{
				viewController.modalTransitionStyle = .crossDissolve
				viewController.modalPresentationStyle = .fullScreen
				present(viewController, animated: false, completion: nil)
			}
		case "設定":
			// 設定画面
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			if let viewController = storyboard.instantiateViewController(withIdentifier: "Setting") as? Setting
			{
				viewController.modalTransitionStyle = .crossDissolve
				viewController.modalPresentationStyle = .fullScreen
				present(viewController, animated: false, completion: nil)
			}
		default:
			destinationWindow()
		}
	}

    @IBAction func downloadZip() {
            updateDownloadStatus("ダウンロードの準備中")
            
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.addSubview(downloadLoadingView)
            }
            
            updateDownloadStatus("ダウンロード中...")
            
            // ダウンロード処理開始
            DownloadFile.shared.downloadDataFile(urls: DataFileURLs.urls) {
                self.updateDownloadStatus("生徒の画像をダウンロード中...")
                
                DownloadFile.shared.processStudentImages(jsonFile: "students.min.json", progressTextView: self.downloadLoadingLabel) {
                    self.updateDownloadStatus("その他の画像をダウンロード中...")
                    
                    DownloadFile.shared.processUniqueImages(jsonFile: "students.min.json", progressTextView: self.downloadLoadingLabel) {
                        self.updateDownloadStatus("")
                        self.showDownloadCompletionAlert(title: "更新完了",
                                                         message: "基本データのダウンロードが完了しました。\n続けてボイスデータをダウンロードしますか？\n(ボイスデータをダウンロードしない場合はオフラインでの再生ができなくなります)") { [weak self] in
                            self?.updateDownloadStatus("ボイスデータをダウンロード中...")
                            
                            DownloadFile.shared.processVoiceData(jsonFile: "students.min.json", progressTextView: self!.downloadLoadingLabel) {
                                self?.finalizeDownload()
                            }
                        }
                    }
                }
            }
        }
        
        // ダウンロード状況の更新
        private func updateDownloadStatus(_ status: String) {
            DispatchQueue.main.async {
                self.downloadLoadingLabel.text = status
            }
        }
        
        // ダウンロード完了後のアラート表示
        private func showDownloadCompletionAlert(title: String, message: String, continueAction: @escaping () -> Void) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "ダウンロード", style: .default, handler: { _ in
                    continueAction()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    self.finalizeDownload()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        // ダウンロード完了後の処理の最終化
        private func finalizeDownload() {
            DispatchQueue.main.async {
                self.downloadLoadingView.removeFromSuperview()
                
                let completionAlert = UIAlertController(title: "更新完了", message: "更新が完了しました。", preferredStyle: .alert)
                completionAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.loadView()
                    self.viewDidLoad()
                }))
                
                self.present(completionAlert, animated: true, completion: nil)
            }
        }

	@objc func CharacterTapped(_: Any)
	{
		print("CharacterTapped")
		if firstVoice == true
		{
			firstVoice = false
			let random = Int.random(in: 1 ... 2)
			let VoiceKey = "UILobbyEnter\(random)"
			playVoiceForKey(VoiceKey, in: voiceArrays)
		} else
		{
			if nextVoice == false
			{
				let random = Int.random(in: 1 ... 5)
				let VoiceKey = "UILobbyIdle\(random)"
				print(VoiceKey)
				let matchingCount = voiceArrays.filter { $0["Group"] as? String == VoiceKey }.count
				if matchingCount >= 2
				{
					nextVoice = true
					nextVoiceNumber = random
				}
				playVoiceForKey(VoiceKey, in: voiceArrays)
			} else
			{
				// 続きのボイス
				print("Continued voice")
				nextVoice = false
				let VoiceKey = "UILobbyIdle\(nextVoiceNumber)"
				if let firstIndex = voiceArrays.firstIndex(where: { $0["Group"] as? String == VoiceKey })
				{
					let nextIndex = voiceArrays.index(after: firstIndex)
					if nextIndex < voiceArrays.endIndex
					{
						let secondMatchingDict = voiceArrays[nextIndex]
						if let audioClip = secondMatchingDict["AudioClip"] as? String
						{
                            playSound(SoundFilePath: audioClip)
						} else
						{
							print("AudioClip not found in second matching item")
						}
					} else
					{
						print("There is no second item matching the VoiceKey")
					}
				} else
				{
					print("No items matching the VoiceKey found")
				}
			}
		}
	}

	func playVoiceForKey(_ VoiceKey: String, in voiceArrays: [[String: Any]])
	{
		if let matchingDict = voiceArrays.first(where: { $0["Group"] as? String == VoiceKey })
		{
			let audioText: String = matchingDict["Transcription"] as! String
			print(audioText)
			if playedVoiceNumber == VoiceKey
			{
				print("VoiceKey already played")
				CharacterTapped(self)
			} else
			{
				playedVoiceNumber = VoiceKey
				let audioClip: String = matchingDict["AudioClip"] as! String
                playSound(SoundFilePath: audioClip)
			}
		} else
		{
			// 再度CharacterTappedを実行する
			print("VoiceKey not found")
			CharacterTapped(self)
		}
	}

    func playSound(SoundFilePath: String) {
        let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let soundFilePath = libraryDirectory.appendingPathComponent("assets/voice/\(SoundFilePath)").path
        let soundFileURL = URL(fileURLWithPath: soundFilePath)

        // ファイルの存在確認
        if !FileManager.default.fileExists(atPath: soundFilePath) {
            print("Error: ファイルが存在しません: \(soundFilePath)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundFileURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("音源ファイルの再生に失敗しました: \(error)")
        }
    }

	func loadVoice()
	{
		let characterID = UserDefaults.standard.string(forKey: "CharacterID") ?? "10066"
		let fileManager = FileManager.default
		if let documentsURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
		{
			let voiceFileURL = documentsURL.appendingPathComponent("assets/data/jp/voice.min.json")
			do
			{
				let data = try Data(contentsOf: voiceFileURL)
				let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
				if let dict = jsonObject as? [String: Any]
				{
					// characterIDに対応するデータを取得し、Lobbyキーの配列をvoiceArraysに格納
					if let user = dict["\(characterID)"] as? [String: Any], let lobbyArray = user["Lobby"] as? [[String: Any]]
					{
						voiceArrays = lobbyArray
					}
				}
			} catch
			{
				print("Error reading voice JSON file: \(error)")
			}
		}
	}
}
