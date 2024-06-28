//
//  CharacterProfilePage.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/12/01.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import Foundation
import Reachability
import SwiftSoup
import UIKit

class CharacterProfilePage: UIViewController
{
	let reachability = try! Reachability()
	var unitId: Int = 100
	var jsonArrays: [[String: Any]] = []
	var AcquisitionMethodText: String = "取得できませんでした"
	@IBOutlet var CharacterProfileText: UITextView!
	// キャラクターの入手方法を記載するUITextView
	@IBOutlet var CharacterAcquisitionMethodText: UITextView!
	@IBOutlet var CharacterSchoolText: UILabel!
	@IBOutlet var CharacterSchoolYear: UILabel!
	@IBOutlet var CharacterClub: UILabel!
	@IBOutlet var CharacterAge: UILabel!
	@IBOutlet var CharacterBirthday: UILabel!
	@IBOutlet var CharacterCharHeightMetric: UILabel!
	@IBOutlet var CharacterHobby: UILabel!
	@IBOutlet var CharacterDesigner: UILabel!
	@IBOutlet var CharacterIllustrator: UILabel!
	@IBOutlet var CharacterCharacterVoice: UILabel!
	@IBOutlet var CharacterWeaponType: UILabel!
	override func viewDidLoad()
	{
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
		let characterName: String = matchingStudents.first?["Name"] as? String ?? "null"
		let urlString = "https://bluearchive.wikiru.jp/?\(characterName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "null")"
		if let url = URL(string: urlString)
		{
			switch reachability.connection
			{
			case .wifi, .cellular:
				fetchHTML(from: url)
				{ result in
					DispatchQueue.main.async
					{
						switch result
						{
						case let .success(htmlString):
							do
							{
								if let contents = try self.findContentByTitleInTable(html: htmlString, title: "入手方法")
								{
									self.CharacterAcquisitionMethodText.text = contents.first
								} else
								{}
							} catch
							{
								print("エラーが発生しました: \(error)")
							}
						case let .failure(error):
							print("HTMLの取得に失敗しました: \(error)")
						}
					}
				}
			case .unavailable:
				print("ネットワークに接続されていません。")
				CharacterAcquisitionMethodText.text = "オンライン環境で取得できます"
			}
		}
	}

	func fetchHTML(from url: URL, completion: @escaping (Result<String, Error>) -> Void)
	{
		let task = URLSession.shared.dataTask(with: url)
		{ data, response, error in
			if let error = error
			{
				completion(.failure(error))
				return
			}

			guard let httpResponse = response as? HTTPURLResponse,
			      (200 ... 299).contains(httpResponse.statusCode),
			      let mimeType = httpResponse.mimeType, mimeType == "text/html",
			      let data = data,
			      let htmlString = String(data: data, encoding: .utf8) else
			{
				completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response or data."])))
				return
			}

			completion(.success(htmlString))
		}
		task.resume()
	}

	func findContentByTitleInTable(html: String, title: String) throws -> [String]?
	{
		let doc: Document = try SwiftSoup.parse(html)
		let table = try doc.select("div#body table").first()
		if let table = table
		{
			let elements: Elements = try table.select("tr")
			var foundTh = false
			for element in elements
			{
				if foundTh
				{
					let tds = try element.select("td")
					let htmlStrings = try tds.array().map { try $0.outerHtml() }
					return cleanHtmlStrings(htmlStrings)
				}
				let ths = try element.select("th")
				if let thText = try ths.first()?.text(), thText == title
				{
					foundTh = true
				}
			}
		}
		return nil
	}

	func cleanHtmlStrings(_ htmlStrings: [String]) -> [String]
	{
		return htmlStrings.map
		{ htmlString in
			var cleanString = htmlString
			cleanString = cleanString.replacingOccurrences(of: "<td[^>]*>", with: "", options: .regularExpression, range: nil)
			cleanString = cleanString.replacingOccurrences(of: "</td>", with: "")
			cleanString = cleanString.replacingOccurrences(of: "<br[^>]*>", with: "\n", options: .regularExpression, range: nil)
			cleanString = cleanString.replacingOccurrences(of: "<.[^>]*>|</.>", with: "", options: .regularExpression, range: nil)
			cleanString = cleanString.replacingOccurrences(of: "\\((?<!\\n)(\\d{4}/\\d{2}/\\d{2}( \\d{2}:\\d{2})?)", with: "\n($1", options: .regularExpression, range: nil)
			return cleanString
		}
	}

	override func observeValue(forKeyPath _: String?, of object: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?)
	{
		if let textView = object as? UITextView
		{
			var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
			topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
			textView.contentInset.top = topCorrect
		}
	}

	deinit
	{
		CharacterProfileText.removeObserver(self, forKeyPath: "contentSize")
	}

	func translateString(_ input: String, mainKey: String? = nil) -> String?
	{
		// Load the contents of localization.json from the Documents directory
		let fileManager = FileManager.default
		do
		{
			let libraryDirectoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
			if let localizationFileURL = libraryDirectoryURL?.appendingPathComponent("assets/data/jp/localization.json")
			{
				let fileData = try Data(contentsOf: localizationFileURL)
				let json = try JSONSerialization.jsonObject(with: fileData, options: [])
				if let localization = json as? [String: Any]
				{
					// If mainKey is provided, search within the nested dictionary
					if let mainKey = mainKey,
					   let mainDictionary = localization[mainKey] as? [String: String],
					   let translatedString = mainDictionary[input]
					{
						return translatedString
					} else
					{
						// Search for the translation based on the input string
						for (_, value) in localization
						{
							if let translations = value as? [String: String],
							   let translatedString = translations[input]
							{
								return translatedString
							}
						}
					}
				}
			} else
			{
				print("")
			}
		} catch
		{
			print("Error loading localization JSON from Documents directory: \(error)")
			return nil
		}

		return "Error" // Translation not found
	}
}
