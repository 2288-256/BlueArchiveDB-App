//
//  CharacterWeapon.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/05/07
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterWeapon: UIViewController
{
	var unitId: Int = 0
	var studentStatus: [[String: Any]] = []
	var jsonArrays: [[String: Any]] = []
	var SkillArrays: [[String: Any]] = []

	override func viewDidLoad()
	{
		super.viewDidLoad()
		studentStatus = jsonArrays.filter { $0["Id"] as? Int == unitId }
		SkillArrays = studentStatus.first?["Skills"] as! [[String: Any]]
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
