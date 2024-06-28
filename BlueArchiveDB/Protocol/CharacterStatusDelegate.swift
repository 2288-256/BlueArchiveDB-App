//
//  Protocol.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/02/15
//  Copyright (c) 2024 2288-256 All Rights Reserved
//
import Foundation

protocol CharacterStatusDelegate: AnyObject
{
	func dataBack(EquipmentTier: [Int: String], WeaponLevel: Int, nowLevel: Int, EquipmentToggleButtonStatus: Bool, StarTier: Int)
}

extension CharacterStatus: CharacterStatusDelegate
{
	func dataBack(EquipmentTier: [Int: String], WeaponLevel: Int, nowLevel: Int, EquipmentToggleButtonStatus: Bool, StarTier: Int)
	{
		self.EquipmentTier = EquipmentTier
		nowWeaponLevel = WeaponLevel
		self.nowLevel = nowLevel
		nowWeaponLevel = WeaponLevel
		LevelSlider.value = Float(nowLevel)
		LevelSliderLabel.text = "Lv.\(nowLevel)"
		stargrade = StarTier
		fromStatusMore = true
		updateStar(selStarGrade: stargrade)
		if EquipmentToggleButtonStatus == true
		{
			EquipmentToggleButton.isSelected = true
		} else
		{
			EquipmentToggleButton.isSelected = false
		}
		if stargrade >= 6
		{
			WeaponLevelLabel.text = "Lv.\(WeaponLevel)"
			WeaponImage.image = WeaponImage.image?.withRenderingMode(.alwaysOriginal)
			WeaponImage.tintColor = .clear
		} else
		{
			WeaponLevelLabel.text = ""
			WeaponImage.image = WeaponImage.image?.withRenderingMode(.alwaysTemplate)
			WeaponImage.tintColor = .gray
		}
		setupEquipment()
		LabelSetUp(level: Int(LevelSlider.value))
	}
}
