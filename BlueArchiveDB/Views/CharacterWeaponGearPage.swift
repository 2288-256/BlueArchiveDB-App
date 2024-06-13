//
//  CharacterWeaponGearPage.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/04/26
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterWeaponGearPage: UIViewController
{
	var unitId: Int = 0
	var jsonArrays: [[String: Any]] = []
	var studentStatus: [[String: Any]] = []
	var GearArrays: [[String: Any]] = []
	@IBOutlet var GearSwitchButton: UIButton!

	@IBOutlet var ContainerView: UIView!
	@IBOutlet var WeaponView: UIView!
	@IBOutlet var GearView: UIView!

	override func viewDidLoad()
	{
		super.viewDidLoad()
		ContainerView.bringSubviewToFront(WeaponView)
		WeaponView.isHidden = false
		GearView.isHidden = true
		studentStatus = jsonArrays.filter { $0["Id"] as? Int == unitId }
		let GearData = studentStatus.first?["Gear"] as? [[String: Any]] ?? []
		GearSwitchButton.isEnabled = !GearData.isEmpty
	}

	override func prepare(for segue: UIStoryboardSegue, sender _: Any?)
	{
		switch (segue.identifier, segue.destination)
		{
		case let ("toWeaponPage"?, destination as CharacterWeapon):
			destination.unitId = unitId
			destination.jsonArrays = jsonArrays
		default:
			()
		}
	}
}
