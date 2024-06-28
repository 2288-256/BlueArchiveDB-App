//
//  Setting.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/01/11.
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class Setting: UIViewController
{
	var jsonArrays: [[String: Any]] = []
	@IBOutlet var Name: UILabel!

	override func viewDidLoad()
	{
		super.viewDidLoad()
		loadAllStudents()
		if let characterIdString = UserDefaults.standard.string(forKey: "CharacterID")
		{
			if let characterId = Int(characterIdString)
			{
				let matchingCharacters = jsonArrays.filter { $0["Id"] as? Int == characterId }
				Name.text = matchingCharacters.first?["Name"] as? String
			}
		} else
		{
			let defaultCharacterId = 10066 // Assuming the default ID is an Int
			let matchingCharacters = jsonArrays.filter { $0["Id"] as? Int == defaultCharacterId }
			Name.text = matchingCharacters.first?["Name"] as? String
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
			print("Error: Failed to instantiate CharacterSelect")
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

	func loadAllStudents()
	{
		do
		{
			let fileManager = FileManager.default
			let documentsURL = try fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let studentsFileURL = documentsURL.appendingPathComponent("assets/data/jp/students.json")

			let data = try Data(contentsOf: studentsFileURL)
			jsonArrays = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
			print("ロードした生徒数:\(jsonArrays.count)")
		} catch
		{
			print("Error reading students JSON file: \(error)")
		}
	}
}
