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
	var studentData: [String: Any] = [:]
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
		CharacterProfileText.text = studentData["ProfileIntroduction"] as? String
        CharacterSchoolText.text = LoadFile.shared.translateString(studentData["School"] as? String ?? "", mainKey: "SchoolLong")
		CharacterSchoolYear.text = studentData["SchoolYear"] as? String
		CharacterClub.text = LoadFile.shared.translateString(studentData["Club"] as? String ?? "", mainKey: "Club")
		CharacterAge.text = studentData["CharacterAge"] as? String
		CharacterBirthday.text = studentData["Birthday"] as? String
		CharacterCharHeightMetric.text = studentData["CharHeightMetric"] as? String
		CharacterHobby.text = studentData["Hobby"] as? String
		CharacterDesigner.text = studentData["Designer"] as? String
		CharacterIllustrator.text = studentData["Illustrator"] as? String
		CharacterCharacterVoice.text = studentData["CharacterVoice"] as? String
		CharacterWeaponType.text = studentData["WeaponType"] as? String
		let characterName: String = studentData["Name"] as? String ?? "null"
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
}
