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
	var jsonArrays: [[String: Any]] = []
	var studentStatus: [[String: Any]] = []
	var SkillArrays: [[String: Any]] = []
	var ExSkillLevel: Int = 0
	var SkillLevel: Int = 0
	var SkillCellPosition: Int = 0
	var LightArmorColor: UIColor = .init(
		red: 167 / 255, green: 12 / 255, blue: 25 / 255, alpha: 1.0
	)
	var HeavyArmorColor: UIColor = .init(
		red: 178 / 255, green: 109 / 255, blue: 31 / 255, alpha: 1.0
	)
	var UnarmedColor: UIColor = .init(red: 33 / 255, green: 111 / 255, blue: 156 / 255, alpha: 1.0)
	var ElasticArmorColor: UIColor = .init(
		red: 148 / 255, green: 49 / 255, blue: 165 / 255, alpha: 1.0
	)
	var NormalColor: UIColor = .init(red: 72 / 255, green: 85 / 255, blue: 130 / 255, alpha: 1.0)
	var OldLevelSliderValue: Int = 0

	//    @IBOutlet weak var collectionView: UICollectionView!
	// 親のSkillView
	@IBOutlet var ContainerSkillView: UIView!
	override func viewDidLoad()
	{
		super.viewDidLoad()
		studentStatus = jsonArrays.filter { $0["Id"] as? Int == unitId }
		SkillArrays = studentStatus.first?["Skills"] as! [[String: Any]]
		SkillArrays.removeAll
		{ skillDict in
			guard let skillType = skillDict["SkillType"] as? String else { return false }
			return skillType.contains("gear") || skillType.contains("weapon")
		}
		print("count", SkillArrays.count)
		SkillCellPosition = 0
		for i in 0 ..< SkillArrays.count
		{
			loadAllSkillCell(skillIndex: i, SkillArrays: SkillArrays)
		}
		print(SkillCellPosition + 10)
		let heightConstraint = NSLayoutConstraint(item: ContainerSkillView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(SkillCellPosition + 10))
		heightConstraint.isActive = true
	}

	@objc func sliderDidChangeValue(_ sender: UISlider)
	{
		// 1ごとにスライダーの値を更新
		sender.value = round(sender.value)
		let tag = sender.tag
		let SkillLevelSlider = view.viewWithTag(tag) as! UISlider
		let SkillDesc = view.viewWithTag(tag - 1) as! UITextView
		let SkillArray = SkillArrays[(tag - 5) / 100]
        let SkillLevelLabel = view.viewWithTag(tag+1) as! UILabel
        SkillLevelLabel.text = "Lv.\(Int(sender.value)+1)"
		SkillDescValueChange(SkillArray: SkillArray, nowSkillLevel: Int(sender.value), skillDescTextView: SkillDesc)
	}

	func loadAllSkillCell(skillIndex: Int, SkillArrays: [[String: Any]] = [])
	{
		let fileManager = FileManager.default
		let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
		var mainView = UIView()
		mainView.tag = skillIndex * 100
        mainView.backgroundColor = .white.withAlphaComponent(CGFloat(0.5))
		mainView.frame = CGRect(x: 0, y: SkillCellPosition, width: 564, height: 200)
		var skillImageView = UIImageView()
		skillImageView.tag = skillIndex * 100 + 1
		mainView.addSubview(skillImageView)
		skillImageView.frame = CGRect(x: 5, y: 5, width: 88, height: 88)
		skillImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 5).isActive = true
		skillImageView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 5).isActive = true
		var skillName = UILabel()
		skillName.tag = skillIndex * 100 + 2
		mainView.addSubview(skillName)
		skillName.frame = CGRect(x: 98, y: 10, width: 461, height: 35)
		skillName.leftAnchor.constraint(equalTo: mainView.rightAnchor, constant: 10).isActive = true
		skillName.leftAnchor.constraint(equalTo: skillImageView.leftAnchor, constant: 5).isActive = true
		var skillDesc = UILabel()
		skillDesc.tag = skillIndex * 100 + 3
		mainView.addSubview(skillDesc)
		skillDesc.frame = CGRect(x: 98, y: 53, width: 461, height: 35)
		skillDesc.topAnchor.constraint(equalTo: skillName.topAnchor, constant: 8).isActive = true
		skillDesc.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 8).isActive = true
		var skillDescTextView = UITextView()
		let SkillArray = SkillArrays[skillIndex]
		var SkillDescTemp: String
		var nowSkillLevel = 1
		if SkillArray["SkillType"] as! String != "autoattack"
		{
            skillDescTextView.backgroundColor = .clear
			skillDescTextView.isEditable = false
			skillDescTextView.isSelectable = false
			skillDescTextView.tag = skillIndex * 100 + 4
			mainView.addSubview(skillDescTextView)
			skillDescTextView.frame = CGRect(x: 0, y: 101, width: 564, height: 56)
			skillDescTextView.topAnchor.constraint(equalTo: skillImageView.topAnchor, constant: 8)
				.isActive = true
			skillDescTextView.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 0)
				.isActive = true
			skillDescTextView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 0).isActive =
				true

			let SkillLevelSlider = UISlider()
			SkillLevelSlider.tag = skillIndex * 100 + 5
			mainView.addSubview(SkillLevelSlider)
			//                 SkillLevelSlider.topAnchor.constraint(equalTo: skillDescTextView.bottomAnchor, constant: )
			//                .isActive = true
			SkillLevelSlider.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 5)
				.isActive = true
			SkillLevelSlider.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 5)
				.isActive = true
			SkillLevelSlider.frame = CGRect(x: 0, y: 165, width: 459, height: 20)
			SkillLevelSlider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
			if SkillArray["SkillType"] as? String == "ex"
			{
				SkillLevelSlider.maximumValue = Float(4)
			} else
			{
				SkillLevelSlider.maximumValue = Float(9)
			}
			let SkillLevelLabel = UILabel()
			SkillLevelLabel.tag = skillIndex * 100 + 6
			mainView.addSubview(SkillLevelLabel)
			SkillLevelLabel.frame = CGRect(x: 467, y: 165, width: 79, height: 20)
			SkillLevelLabel.rightAnchor.constraint(equalTo: SkillLevelSlider.leftAnchor, constant: 8)
				.isActive = true
			SkillLevelLabel.leftAnchor.constraint(equalTo: mainView.rightAnchor, constant: 8)
				.isActive = true
			SkillLevelLabel.text = "Lv.1"
            SkillLevelLabel.textAlignment = .center
		} else
		{
			mainView.frame.size.height = 95
		}
		SkillDescValueChange(SkillArray: SkillArray, nowSkillLevel: 1, skillDescTextView: skillDescTextView)
		// // Repeat until the input text doesn't change anymore
		// if SkillArray["SkillType"] as? String == "ex" {
		//     nowSkillLevel = ExSkillLevel
		// }else{
		//     SkillLevelSlider.isHidden = true
		//     nowSkillLevel = SkillLevel
		// }
		if let radius = SkillArray["Radius"] as? [[String: Any]],
		   let type = radius[0]["Type"] as? String
		{
			switch type
			{
			case "Circle":
				let Desc = translateString("skill_normalattack_circle")
				let IconImagePath = libraryDirectory.appendingPathComponent(
					"assets/images/skill/COMMON_SKILLICON_CIRCLE.webp")
				skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
			case "Obb":
				let Desc = translateString("skill_normalattack_line")
				let IconImagePath = libraryDirectory.appendingPathComponent(
					"assets/images/skill/COMMON_SKILLICON_LINE.webp")
				skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
			case "Fan":
				let Desc = translateString("skill_normalattack_fan")
				let IconImagePath = libraryDirectory.appendingPathComponent(
					"assets/images/skill/COMMON_SKILLICON_FAN.webp")
				skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
			default:
				break
			}
		} else
		{
			let Desc = translateString("skill_normalattack_target")
			let IconImagePath = libraryDirectory.appendingPathComponent(
				"assets/images/skill/COMMON_SKILLICON_TARGET.webp")
			skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
		}
		if SkillArray["Icon"] != nil
		{
			let IconImagePath = libraryDirectory.appendingPathComponent(
				"assets/images/skill/\(SkillArray["Icon"]!).webp")

			skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
		}
		if let bulletType = studentStatus.first?["BulletType"] as? String
		{
			switch bulletType
			{
			case "Explosion":
				skillImageView.backgroundColor = LightArmorColor
			case "Pierce":
				skillImageView.backgroundColor = HeavyArmorColor
			case "Mystic":
				skillImageView.backgroundColor = UnarmedColor
			case "Sonic":
				skillImageView.backgroundColor = ElasticArmorColor
			default:
				skillImageView.backgroundColor = NormalColor
			}
		}
		if SkillArray["Name"] != nil
		{
			skillName.text = SkillArray["Name"] as! String
		} else if SkillArray["SkillType"] as! String == "autoattack"
		{
			skillName.text = "通常攻撃"
		}
		switch SkillArray["SkillType"] as! String
		{
		case "autoattack":
			var RadiusType: String
			if let radius = SkillArray["Radius"] as? [[String: Any]],
			   let type = radius[0]["Type"] as? String
			{
				if type == "Obb"
				{
					RadiusType = "line"
				} else
				{
					RadiusType = type.lowercased()
				}
			} else
			{
				RadiusType = "target"
			}
			var AutoAttackDescTemp = SkillDescReplace(
				SkillDesc: translateString("skill_normalattack_\(RadiusType)") ?? "null",
				regexPattern: "<b:([a-zA-Z0-9_]+)>", replaceOf: "b:", replaceWithCategory: "Buff_",
				replaceWithKey: "BuffName"
			)
			AutoAttackDescTemp = SkillDescReplace(
				SkillDesc: AutoAttackDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:",
				replaceWithCategory: "Debuff_", replaceWithKey: "BuffName"
			)
			AutoAttackDescTemp = SkillDescReplace(
				SkillDesc: AutoAttackDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:",
				replaceWithCategory: "CC_", replaceWithKey: "BuffName"
			)
			do
			{
				let regex = try NSRegularExpression(pattern: "<?([0-9]+)>")
				let nsRange = NSRange(
					AutoAttackDescTemp.startIndex ..< AutoAttackDescTemp.endIndex, in: AutoAttackDescTemp
				)

				if let match = regex.firstMatch(in: AutoAttackDescTemp, options: [], range: nsRange)
				{
					let matchedRange = match.range(at: 1) // Capture group 1 range

					if let swiftRange = Range(matchedRange, in: AutoAttackDescTemp)
					{
						let matchedText = String(AutoAttackDescTemp[swiftRange]) // The text between <? and >
						// print("Matched text: \(matchedText)") // Do something with matched text

						// Replace the matched text with an empty string or any replacement text
						let Parameters = SkillArray["Parameters"] as? [[Any]]
						if AutoAttackDescTemp
							!= AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%")
						{
							AutoAttackDescTemp = AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%")
						}
					}
				}
			} catch
			{
				print("Regex error: \(error.localizedDescription)")
			}

			skillDesc.text = AutoAttackDescTemp

		case "ex":
			skillDesc.text = translateString("student_skill_ex") ?? "null"
			let Cost = SkillArray["Cost"] as? [Any]
			skillDesc.text! += "・コスト\(Cost?[0] as! Int)"

		case "normal":
			skillDesc.text = translateString("student_skill_normal") ?? "null"

		case "gearnormal":
			skillDesc.text = translateString("student_skill_gearnormal") ?? "null"

		case "passive":
			skillDesc.text = translateString("student_skill_passive") ?? "null"

		case "weaponpassive":
			skillDesc.text = translateString("student_skill_weaponpassive") ?? "null"

		case "sub":
			skillDesc.text = translateString("student_skill_sub") ?? "null"

		default:
			break
		}
		ContainerSkillView.addSubview(mainView)
		SkillCellPosition += Int(mainView.frame.height) + 5
	}

	func SkillDescValueChange(SkillArray: [String: Any], nowSkillLevel: Int, skillDescTextView: UITextView)
	{
		var SkillDescTemp = SkillDescReplace(
			SkillDesc: SkillArray["Desc"] as? String ?? "nil", regexPattern: "<b:([a-zA-Z0-9_]+)>",
			replaceOf: "b:", replaceWithCategory: "Buff_", replaceWithKey: "BuffName"
		)
		SkillDescTemp = SkillDescReplace(
			SkillDesc: SkillDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:",
			replaceWithCategory: "Debuff_", replaceWithKey: "BuffName"
		)
		SkillDescTemp = SkillDescReplace(
			SkillDesc: SkillDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:",
			replaceWithCategory: "CC_", replaceWithKey: "BuffName"
		)
		SkillDescTemp = SkillDescReplace(
			SkillDesc: SkillDescTemp, regexPattern: "<s:([a-zA-Z0-9_]+)>", replaceOf: "s:",
			replaceWithCategory: "Special_", replaceWithKey: "BuffName"
		)
		SkillDescTemp = SkillKbValueReplace(
			SkillDesc: SkillDescTemp, regexPattern: "<kb:([0-9]+)>", replaceOf: "kb:",
			nowSkillLevel: nowSkillLevel, SkillArray: SkillArray
		)
		SkillDescTemp = SkillDescValueReplace(
			SkillDesc: SkillDescTemp, regexPattern: "<?([0-9]+)>", replaceOf: "?",
			nowSkillLevel: nowSkillLevel, SkillArray: SkillArray
		)
		if SkillArray["SkillType"] as! String != "autoattack"
		{
			skillDescTextView.text = SkillDescTemp
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

	//    @IBAction func LevelSliderChanged(_ sender: UISlider) {
	//        sender.value = round(sender.value)
	//        ExSkillLevel = Int(sender.value)
	//        var cellTag = 1
	//        if let cell = getParentCell(of: sender), let indexPath = collectionView.indexPath(for: cell) {
	//                    cellTag = cell.tag
	//                }
	////        print(cellTag)
	//        collectionView.reloadItems(at: [IndexPath(item: cellTag/100, section: 0)])
	//
	//        //        let reusableview = self.view.viewWithTag(100) as! UICollectionReusableView
	//        //        let label = reusableview.viewWithTag(2) as! UILabel
	//        //        label.text = "Lv.\(Int(sender.value))"
	//
	//    }
	func SkillDescReplace(
		SkillDesc: String, regexPattern: String, replaceOf: String, replaceWithCategory: String,
		replaceWithKey: String? = nil
	) -> String
	{
		var Desc = SkillDesc
		var valueChanged = true
		while valueChanged
		{
			valueChanged = false

			do
			{
				let regex = try NSRegularExpression(pattern: regexPattern)
				let nsRange = NSRange(Desc.startIndex ..< Desc.endIndex, in: Desc)

				if let match = regex.firstMatch(in: Desc, options: [], range: nsRange)
				{
					let matchedRange = match.range(at: 1) // Capture group 1 range

					if let swiftRange = Range(matchedRange, in: Desc)
					{
						let matchedText = String(Desc[swiftRange]) // The text between <b: and >
						// print("Matched text: \(matchedText)") // Do something with matched text

						// Replace the matched text with an empty string or any replacement text
						let replacementText =
							translateString("\(replaceWithCategory)\(matchedText)", mainKey: replaceWithKey) ?? ""
						if Desc
							!= Desc.replacingOccurrences(
								of: "<\(replaceOf)\(matchedText)>", with: replacementText
							)
						{
							Desc = Desc.replacingOccurrences(
								of: "<\(replaceOf)\(matchedText)>", with: replacementText
							)
							valueChanged = true
						}
					}
				}
			} catch
			{
				print("Regex error: \(error.localizedDescription)")
			}
		}
		return Desc
	}

	func SkillKbValueReplace(
		SkillDesc: String, regexPattern: String, replaceOf: String, nowSkillLevel: Int,
		SkillArray: [String: Any]
	) -> String
	{
		var Desc = SkillDesc
		var BuffValuechanged = true
		while BuffValuechanged
		{
			BuffValuechanged = false
			do
			{
				let regex = try NSRegularExpression(pattern: regexPattern)
				let nsRange = NSRange(Desc.startIndex ..< Desc.endIndex, in: Desc)

				if let match = regex.firstMatch(in: Desc, options: [], range: nsRange)
				{
					let matchedRange = match.range(at: 1) // Capture group 1 range

					if let swiftRange = Range(matchedRange, in: Desc)
					{
						let matchedText = String(Desc[swiftRange]) // The text between <? and >
						// print("Matched text: \(matchedText)") // Do something with matched text

						// Replace the matched text with an empty string or any replacement text
						let Effects = SkillArray["Effects"] as! [[String: Any]]
						let filter = Effects.filter { $0["Type"] as! String == "Knockback" }
						let replacementText = filter.first?["Scale"] as! [Int]
						if Desc
							!= Desc.replacingOccurrences(
								of: "<\(replaceOf)\(matchedText)>", with: String(replacementText[nowSkillLevel])
							)
						{
							Desc = Desc.replacingOccurrences(
								of: "<\(replaceOf)\(matchedText)>", with: String(replacementText[nowSkillLevel])
							)
							BuffValuechanged = true
						}
					}
				}
			} catch
			{
				print("Regex error: \(error.localizedDescription)")
			}
		}
		return Desc
	}

	func SkillDescValueReplace(
		SkillDesc: String, regexPattern: String, replaceOf: String, nowSkillLevel: Int,
		SkillArray: [String: Any]
	) -> String
	{
		var Desc = SkillDesc
		var BuffValuechanged = true
		while BuffValuechanged
		{
			BuffValuechanged = false
			do
			{
				let regex = try NSRegularExpression(pattern: regexPattern)
				let nsRange = NSRange(Desc.startIndex ..< Desc.endIndex, in: Desc)

				if let match = regex.firstMatch(in: Desc, options: [], range: nsRange)
				{
					let matchedRange = match.range(at: 1) // Capture group 1 range

					if let swiftRange = Range(matchedRange, in: Desc)
					{
						let matchedText = String(Desc[swiftRange]) // The text between <? and >
						// print("Matched text: \(matchedText)") // Do something with matched text

						// Replace the matched text with an empty string or any replacement text
						let Parameters = SkillArray["Parameters"] as? [[Any]]
						let replacementText: String =
							Parameters?[Int(matchedText)! - 1][nowSkillLevel] as! String
						if Desc
							!= Desc.replacingOccurrences(
								of: "<\(replaceOf)\(matchedText)>", with: replacementText
							)
						{
							Desc = Desc.replacingOccurrences(
								of: "<\(replaceOf)\(matchedText)>", with: replacementText
							)
							BuffValuechanged = true
							//                            print(replacementText)
						}
					}
				}
			} catch
			{
				print("Regex error: \(error.localizedDescription)")
			}
		}
		return Desc
	}

	// func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
	//     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "skill-cell", for: indexPath)
	//     cell.tag = indexPath.row * 100
	//     print(indexPath.row)
	//     let skillTypeIconImagePath = cell.contentView.viewWithTag(1) as! UIImageView
	//     skillTypeIconImagePath.image = nil
	//     let SkillName = cell.contentView.viewWithTag(2) as! UILabel
	//     SkillName.text = nil
	//     let SkillTypeName = cell.contentView.viewWithTag(3) as! UILabel
	//     SkillTypeName.text = nil
	//     let SkillDesc = cell.contentView.viewWithTag(4) as! UITextView
	//     SkillDesc.text = nil
	//     let SkillLevelSlider = cell.contentView.viewWithTag(5) as! UISlider
	//     SkillLevelSlider.value = Float(ExSkillLevel)

	//     let fileManager = FileManager.default
	//     let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
	//     if SkillArrays.count > indexPath.row {
	//         let SkillArray = SkillArrays[indexPath.row]
	//         var SkillDescTemp : String
	//         var nowSkillLevel : Int
	//         // Repeat until the input text doesn't change anymore
	//         if SkillArray["SkillType"] as? String == "ex" {
	//             nowSkillLevel = ExSkillLevel
	//         }else{
	//             SkillLevelSlider.isHidden = true
	//             nowSkillLevel = SkillLevel
	//         }
	//         SkillDescTemp = SkillDescReplace(SkillDesc: SkillArray["Desc"] as? String ?? "nil", regexPattern: "<b:([a-zA-Z0-9_]+)>", replaceOf: "b:", replaceWithCategory: "Buff_", replaceWithKey: "BuffName")
	//         SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:", replaceWithCategory: "Debuff_", replaceWithKey: "BuffName")
	//         SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:", replaceWithCategory: "CC_", replaceWithKey: "BuffName")
	//         SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<s:([a-zA-Z0-9_]+)>", replaceOf: "s:", replaceWithCategory: "Special_", replaceWithKey: "BuffName")
	//         SkillDescTemp = SkillKbValueReplace(SkillDesc: SkillDescTemp, regexPattern: "<kb:([0-9]+)>", replaceOf: "kb:", nowSkillLevel: nowSkillLevel, SkillArray: SkillArray)
	//         SkillDescTemp = SkillDescValueReplace(SkillDesc: SkillDescTemp, regexPattern: "<?([0-9]+)>", replaceOf: "?", nowSkillLevel: nowSkillLevel,SkillArray:SkillArray)
	//         if (SkillArray["SkillType"] as! String != "autoattack") {
	//             SkillDesc.isHidden = false
	//             SkillDesc.text = SkillDescTemp
	//         }else{
	//             SkillDesc.text = nil
	//             SkillDesc.isHidden = true
	//             cell.frame.size.height = 125
	//         }
	//         if let radius = SkillArray["Radius"] as? [[String: Any]], let type = radius[0]["Type"] as? String {
	//             switch type {
	//             case "Circle":
	//                 let Desc  = translateString("skill_normalattack_circle")
	//                 let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_CIRCLE.webp")
	//                 skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//             case "Obb":
	//                 let Desc  = translateString("skill_normalattack_line")
	//                 let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_LINE.webp")
	//                 skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//             case "Fan":
	//                 let Desc  = translateString("skill_normalattack_fan")
	//                 let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_FAN.webp")
	//                 skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//             default:
	//                 break
	//             }
	//         } else {
	//             let Desc  = translateString("skill_normalattack_target")
	//             let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_TARGET.webp")
	//             skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//         }
	//         if (SkillArray["Icon"] != nil){
	//             let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/\(SkillArray["Icon"]!).webp")
	//             skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//         }
	//         if let bulletType = studentStatus.first?["BulletType"] as? String {
	//             switch bulletType {
	//             case "Explosion":
	//                 skillTypeIconImagePath.backgroundColor = LightArmorColor
	//             case "Pierce":
	//                 skillTypeIconImagePath.backgroundColor = HeavyArmorColor
	//             case "Mystic":
	//                 skillTypeIconImagePath.backgroundColor = UnarmedColor
	//             case "Sonic":
	//                 skillTypeIconImagePath.backgroundColor = ElasticArmorColor
	//             default:
	//                 skillTypeIconImagePath.backgroundColor = NormalColor
	//             }
	//         }
	//         if (SkillArray["Name"] != nil){
	//             SkillName.text = SkillArray["Name"] as! String
	//         }else if (SkillArray["SkillType"] as! String == "autoattack"){
	//             SkillName.text = "通常攻撃"
	//         }
	//         switch SkillArray["SkillType"] as! String {
	//         case "autoattack":
	//             var RadiusType:String
	//             if let radius = SkillArray["Radius"] as? [[String: Any]], let type = radius[0]["Type"] as? String {

	//                 if type == "Obb"{
	//                     RadiusType = "line"
	//                 }else{
	//                     RadiusType = type.lowercased()
	//                 }
	//             }else{
	//                 RadiusType = "target"
	//             }
	//             var AutoAttackDescTemp = SkillDescReplace(SkillDesc: translateString("skill_normalattack_\(RadiusType)") ?? "null", regexPattern: "<b:([a-zA-Z0-9_]+)>", replaceOf: "b:", replaceWithCategory: "Buff_", replaceWithKey: "BuffName")
	//             AutoAttackDescTemp = SkillDescReplace(SkillDesc: AutoAttackDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:", replaceWithCategory: "Debuff_", replaceWithKey: "BuffName")
	//             AutoAttackDescTemp = SkillDescReplace(SkillDesc: AutoAttackDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:", replaceWithCategory: "CC_", replaceWithKey: "BuffName")
	//             do {
	//                 let regex = try NSRegularExpression(pattern: "<?([0-9]+)>")
	//                 let nsRange = NSRange(AutoAttackDescTemp.startIndex..<AutoAttackDescTemp.endIndex, in: AutoAttackDescTemp)

	//                 if let match = regex.firstMatch(in: AutoAttackDescTemp, options: [], range: nsRange) {
	//                     let matchedRange = match.range(at: 1) // Capture group 1 range

	//                     if let swiftRange = Range(matchedRange, in: AutoAttackDescTemp) {
	//                         let matchedText = String(AutoAttackDescTemp[swiftRange]) // The text between <? and >
	//                         // print("Matched text: \(matchedText)") // Do something with matched text

	//                         // Replace the matched text with an empty string or any replacement text
	//                         let Parameters = SkillArray["Parameters"] as? [[Any]]
	//                         if AutoAttackDescTemp != AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%") {
	//                             AutoAttackDescTemp = AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%")
	//                         }
	//                     }
	//                 }
	//             } catch {
	//                 print("Regex error: \(error.localizedDescription)")
	//             }

	//             SkillTypeName.text = AutoAttackDescTemp
	//         case "ex":
	//             SkillTypeName.text = translateString("student_skill_ex") ?? "null"
	//             let Cost = SkillArray["Cost"] as? [Any]
	//             SkillTypeName.text! += "・コスト\(Cost?[0] as! Int)"
	//         case "normal":
	//             SkillTypeName.text = translateString("student_skill_normal") ?? "null"

	//         case "gearnormal":
	//             SkillTypeName.text = translateString("student_skill_gearnormal") ?? "null"

	//         case "passive":
	//             SkillTypeName.text = translateString("student_skill_passive") ?? "null"

	//         case "weaponpassive":
	//             SkillTypeName.text = translateString("student_skill_weaponpassive") ?? "null"

	//         case "sub":
	//             SkillTypeName.text = translateString("student_skill_sub") ?? "null"

	//         default:
	//             break
	//         }

	//     }
	//     return cell
	// }
	// func numberOfSections(in collectionView: UICollectionView) -> Int {
	//     // section数は１つ
	//     return 1
	// }

	// func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
	//     studentStatus = jsonArrays.filter { $0["Id"] as? Int == unitId }
	//     SkillArrays = studentStatus.first?["Skills"] as! [[String: Any]]
	//     SkillArrays.removeAll { skillDict in
	//         guard let skillType = skillDict["SkillType"] as? String else { return false }
	//         return skillType.contains("gear") || skillType.contains("weapon")
	//     }
	//     return SkillArrays.count
	// }
	// func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
	//     // Existing width calculation is maintained
	//     let cellWidth = collectionView.frame.width

	//     // Default cell height
	//     var cellHeight: CGFloat = 184

	//     if SkillArrays[indexPath.row]["SkillType"] as! String == "ex" {
	//         cellHeight = 226
	//     }

	//     // Determine if there is a transcription for the specific indexPath
	//     if SkillArrays[indexPath.row]["SkillType"] as! String == "autoattack" {
	//         cellHeight = 125
	//     }

	//     return CGSize(width: cellWidth, height: cellHeight)
	// }
	func translateString(_ input: String, mainKey: String? = nil) -> String?
	{
		// Load the contents of localization.json from the Documents directory
		let fileManager = FileManager.default
		do
		{
			let libraryDirectoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
			if let localizationFileURL = libraryDirectoryURL?.appendingPathComponent(
				"assets/data/jp/localization.json")
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
