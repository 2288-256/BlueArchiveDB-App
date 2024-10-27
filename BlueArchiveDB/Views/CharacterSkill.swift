//
//  CharacterSkill.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/04/17
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterSkill: UIViewController
{
	var unitId: Int = 0
	var studentData: [String: Any] = [:]
	var studentStatus: [[String: Any]] = []
	var SkillArrays: [String: Any] = [:]
	var ExSkillLevel: Int = 0
	var SkillLevel: Int = 0
	var SkillCellPosition: Int = 0
	var OldLevelSliderValue: Int = 0
	var SkillList: [String] = ["Normal", "Ex", "Public", "Passive", "ExtraPassive"]

	// 親のSkillView
	@IBOutlet var ContainerSkillView: UIView!
	override func viewDidLoad()
	{
		super.viewDidLoad()
		SkillArrays = studentData["Skills"] as? [String: Any] ?? [:]
		SkillArrays = SkillArrays.filter
		{ _, value in
			guard let skillDict = value as? [String: Any],
			      let skillType = skillDict["SkillType"] as? String else
			{
				return true
			}
			return !(skillType.contains("gear") || skillType.contains("weapon"))
		}

        Logger.standard.debug("count: \(self.SkillArrays.count)")
		SkillCellPosition = 0

		for (index, key) in SkillList.enumerated()
		{
			guard let SkillArray = SkillArrays[key] else
			{
				// SkillArrayがnilでないことを確認
				continue
			}

			Logger.standard.debug("\(key)")
			let skillIndex = index // キーが整数として扱われる場合、Intに変換
			var mainView = LoadSkill.shared.loadAllSkillCell(
				studentStatus: studentData,
				skillIndex: skillIndex,
				SkillArray: SkillArray as! [String: Any],
				SkillCellPosition: SkillCellPosition, SkillName: key,
				action: #selector(sliderDidChangeValue(_:)),
				target: self
			)

			// returnでmainViewを返す
			ContainerSkillView.addSubview(mainView)
			SkillCellPosition += Int(mainView.frame.height) + 5
		}
		let heightConstraint = NSLayoutConstraint(item: ContainerSkillView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(SkillCellPosition + 10))
		heightConstraint.isActive = true
	}

	@objc func sliderDidChangeValue(_ sender: UISlider)
	{
		// 1ごとにスライダーの値を更新
		sender.value = round(sender.value)
		let tag = sender.tag

		// タグを使ってビューを取得
		guard let SkillLevelSlider = view.viewWithTag(tag) as? UISlider,
		      let SkillDesc = view.viewWithTag(tag - 1) as? UITextView,
		      let SkillLevelLabel = view.viewWithTag(tag + 1) as? UILabel else
		{
			return
		}
		// (tag - 5) / 100 から辞書のキーを決定する処理を追加
		let key = String((tag - 5) / 100) // キーが文字列であると仮定

		// スライダーの値をラベルに表示
		SkillLevelLabel.text = "Lv.\(Int(sender.value) + 1)"
		for (index, key) in SkillList.enumerated()
		{
			if index == (tag - 5) / 100
			{
				guard let SkillArray = SkillArrays[key] else
				{
					// SkillArrayがnilでないことを確認
					return
				}
				// SkillDescValueChangeメソッドを呼び出す
				LoadSkill.shared.SkillDescValueChange(
					SkillArray: SkillArray as! [String: Any],
					nowSkillLevel: Int(sender.value),
					skillDescTextView: SkillDesc,
					SkillName: key
				)
			}
		}
	}

	func getParentCell(of view: UIView) -> UICollectionViewCell?
	{
		var superview = view.superview
		while let view = superview, !(view is UICollectionViewCell)
		{
			superview = view.superview
		}
		return superview as? UICollectionViewCell
	}
}
