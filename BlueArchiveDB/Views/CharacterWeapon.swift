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
        jsonArrays = LoadFile.shared.getStudents()
        studentStatus = jsonArrays.filter { $0["Id"] as? Int == unitId }
	}
}
